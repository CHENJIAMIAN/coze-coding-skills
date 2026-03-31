# Row Level Security (RLS) 策略配置

> **⚠️ 强制要求：所有表必须启用 RLS**
>
> 即使是公开数据表，也必须启用 RLS 并配置相应策略。未启用 RLS 的表可通过 anon key 直接读写所有数据，存在严重安全风险。

## 配置前决策流程

配置 RLS 前，按顺序完成以下判断：

### 步骤一：确认项目是否有登录功能

检查项目中是否实现了 Supabase Auth：
- 代码中是否有 `supabase.auth.signIn` / `signUp` 调用？
- 是否存在登录/注册页面？

```
有 Auth → 继续步骤二
无 Auth → 直接使用场景 A（公开读写）
```

> **关键**：无登录功能时，`auth.role()` 始终返回 `anon`，`auth.uid()` 始终返回 `NULL`。使用场景 B/C/D 会导致操作失败或数据不可见。

### 步骤二：确定数据归属类型

仅在项目已实现 Auth 时考虑：

| 数据归属 | 场景 | 示例 |
|:--|:--|:--|
| 所有人可读写 | A | 公告板、公共配置 |
| 所有人可读，登录用户可写 | B | 博客文章、商品展示 |
| 仅登录用户可读写 | C | 内部数据、会员内容 |
| 用户仅能操作自己的数据 | D | 订单、日记、私人设置 |

### 步骤三：场景 D 额外检查

选择场景 D 时，确认：
- 表中存在 `user_id` 字段
- `user_id` 已设置 `default: auth.uid()`

## 常见误区

| 误区 | 错误思路 | 正确思路 |
|:--|:--|:--|
| 业务直觉覆盖技术约束 | 日记是私人的 → 用场景 D | 项目无 Auth → 只能用场景 A |
| 见 user_id 就用场景 D | Schema 有 user_id → 用场景 D | 先判断 Auth 状态，再决定策略 |
| 追求"最安全"策略 | 场景 D 最严格 → 默认用 D | 无 Auth 用 D → 操作全部失败 |

> **核心原则**：安全策略必须匹配项目能力。没有 Auth 系统就无法区分用户身份。

## 策略速查表

| 场景 | 说明 | 需要 Auth | 需要 user_id |
|:--|:--|:--:|:--:|
| A. 公开读写 | 所有人可读写 | ✗ | ✗ |
| B. 公开读 + 登录写 | 所有人可读，登录用户可写 | ✓ | ✗ |
| C. 仅登录用户 | 登录用户才能读写 | ✓ | ✗ |
| D. 用户私有 | 用户只能操作自己的数据 | ✓ | ✓ |

**速记**：无 Auth = 场景 A，有 Auth 可选 B/C/D。

## 操作步骤

### 1. 启用 RLS

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

### 2. 创建策略

根据决策结果选择对应 SQL 模板执行。

> **幂等处理**：策略已存在时 `CREATE POLICY` 会报错，需先删除：
> ```sql
> DROP POLICY IF EXISTS "策略名称" ON table_name;
> CREATE POLICY "策略名称" ON table_name ...;
> ```

## 策略 SQL 模板

> **命名规范**：Policy 名称应包含表名前缀（如 `posts_允许公开读取`），便于管理。
>
> **⚠️ 性能关键**：所有模板中的 `auth.uid()` 和 `auth.role()` 都已用 `(SELECT ...)` 包裹。这不是可选优化——不包裹时函数每行调用一次，百万行表上有 100x+ 性能差距。同时确保策略引用的字段（如 `user_id`）上有索引。

### 场景 A：公开读写

适用于无登录功能的项目或公开数据表。

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "table_name_允许公开读取" ON table_name
  FOR SELECT USING (true);

CREATE POLICY "table_name_允许公开写入" ON table_name
  FOR INSERT WITH CHECK (true);

CREATE POLICY "table_name_允许公开更新" ON table_name
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "table_name_允许公开删除" ON table_name
  FOR DELETE USING (true);
```

### 场景 B：公开读 + 登录写

前提：项目已实现 Supabase Auth。

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "table_name_允许公开读取" ON table_name
  FOR SELECT USING (true);

CREATE POLICY "table_name_登录用户可写入" ON table_name
  FOR INSERT WITH CHECK ((SELECT auth.role()) = 'authenticated');

CREATE POLICY "table_name_登录用户可更新" ON table_name
  FOR UPDATE USING ((SELECT auth.role()) = 'authenticated')
  WITH CHECK ((SELECT auth.role()) = 'authenticated');

CREATE POLICY "table_name_登录用户可删除" ON table_name
  FOR DELETE USING ((SELECT auth.role()) = 'authenticated');
```

### 场景 C：仅登录用户

前提：项目已实现 Supabase Auth。

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "table_name_登录用户可读" ON table_name
  FOR SELECT USING ((SELECT auth.role()) = 'authenticated');

CREATE POLICY "table_name_登录用户可写入" ON table_name
  FOR INSERT WITH CHECK ((SELECT auth.role()) = 'authenticated');

CREATE POLICY "table_name_登录用户可更新" ON table_name
  FOR UPDATE USING ((SELECT auth.role()) = 'authenticated')
  WITH CHECK ((SELECT auth.role()) = 'authenticated');

CREATE POLICY "table_name_登录用户可删除" ON table_name
  FOR DELETE USING ((SELECT auth.role()) = 'authenticated');
```

### 场景 D：用户私有数据

前提：
1. 项目已实现 Supabase Auth
2. 表中包含 `user_id` 字段

**user_id 字段定义：**

TypeScript (Drizzle)：
```typescript
import { sql } from "drizzle-orm";
import { uuid } from "drizzle-orm/pg-core";

user_id: uuid("user_id").notNull().default(sql`auth.uid()`),
```

Python (SQLAlchemy)：
```python
from sqlalchemy import text
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy.dialects.postgresql import UUID

user_id: Mapped[str] = mapped_column(
    UUID(as_uuid=False),
    nullable=False,
    server_default=text("auth.uid()")
)
```

> 使用 `auth.uid()` 作为默认值，Supabase 会在插入时自动填充当前用户 ID，防止客户端伪造。

**RLS 策略：**

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "table_name_用户读取自己的数据" ON table_name
  FOR SELECT USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "table_name_用户插入自己的数据" ON table_name
  FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "table_name_用户更新自己的数据" ON table_name
  FOR UPDATE USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "table_name_用户删除自己的数据" ON table_name
  FOR DELETE USING ((SELECT auth.uid()) = user_id);
```

## 常见错误示例

```sql
-- ❌ 错误 1：忘记启用 RLS（表完全开放）
CREATE TABLE posts (id serial PRIMARY KEY, title text);
-- 缺少：ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- ❌ 错误 2：启用 RLS 但无策略（所有人都无法访问）
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
-- 缺少：CREATE POLICY ...

-- ❌ 错误 3：无 Auth 项目使用 auth.uid()
CREATE POLICY "用户私有" ON diaries
  FOR SELECT USING (auth.uid() = user_id);
-- auth.uid() 始终为 NULL，数据永远不可见

-- ❌ 错误 4：无 Auth 项目使用 auth.role() = 'authenticated'
CREATE POLICY "登录可写" ON posts
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
-- auth.role() 始终为 'anon'，写入永远失败

-- ✅ 正确：无 Auth 项目使用场景 A
CREATE POLICY "公开读写" ON diaries FOR SELECT USING (true);
CREATE POLICY "公开写入" ON diaries FOR INSERT WITH CHECK (true);
```

## 自检清单

- [ ] 确认项目是否有 Auth
- [ ] 场景选择是否匹配 Auth 状态
- [ ] 无 Auth 项目是否仅使用场景 A
- [ ] 场景 D 是否已添加 user_id 字段
- [ ] 策略中 auth.uid()/auth.role() 是否用 (SELECT ...) 包裹
- [ ] user_id 列是否有索引
- [ ] 是否测试了数据读写操作
