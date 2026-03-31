# Python Supabase SDK

> 🔴🔴🔴 **警告**：本文档包含必须严格执行的工作流程。**禁止跳过任何步骤，禁止凭经验直接编码。**

***

## 架构说明（必须理解）

项目中有两套工具分工协作：

- **SQLAlchemy（迁移工具）**：仅用于定义表结构（`model.py`），通过 `coze-coding-ai db upgrade` 同步到 Postgres
- **Supabase SDK（数据操作工具）**：所有 CRUD 通过 HTTP（PostgREST）读写数据

结论：不要用 SQLAlchemy 写查询代码（如 `session.query()`），只用它定义表结构；所有读写都用 Supabase SDK。

## 环境变量与初始化（必须遵守）

- `COZE_SUPABASE_URL` 和 `COZE_SUPABASE_ANON_KEY` 由 Coze 平台自动注入
- 客户端模板会按顺序尝试：dotenv → coze_workload_identity SDK → 抛出错误
- **如果初始化失败**：说明项目尚未开通 Supabase 服务，必须向用户报告并提示去 Coze 平台开通，**禁止静默降级返回空数据/模拟数据**

## 强制工作流程（必须按顺序执行每一步）

### Step 1: 同步模型

```bash
coze-coding-ai db generate-models
```

🔴 **此命令从远端数据库拉取当前表结构并覆写本地 `model.py`。必须先执行此命令，再修改 `model.py`——顺序反了会导致你的修改被覆盖，`db upgrade` 也不会生效。**

### Step 2: 分析需求

阅读同步后的 `model.py` 模型文件，用 1-2 句话说明要做什么。

### Step 3: 创建/修改表（如需）

不涉及表结构变更则跳过此步。

🔴 先执行：
```
Read references/python/orm-model-guide.md
```

文档包含 Coze 环境特有约束（禁止删除 health_check 系统表否则迁移报权限错误、外键必须手动建索引、字段命名和类型规范等），凭经验写 model 几乎一定触发迁移失败。读完后再修改 `model.py`。

### Step 4: 同步到数据库

```bash
coze-coding-ai db upgrade
```

此命令对比本地 `model.py` 与远端数据库，生成并执行 DDL（CREATE TABLE、ALTER TABLE 等）将本地定义同步到远端。

### Step 5: 配置 RLS 策略

每个新建的表都必须配置 RLS。修改已有表（如加字段）时，已有的 RLS 策略仍然生效，无需重复配置。

🔴 先执行：
```
Read references/rls.md
```

RLS SQL 有严格的策略命名格式、函数必须用 SELECT 包裹、场景选择必须匹配 Auth 状态，写错会导致权限泄露或查询性能下降 100 倍。读完后根据决策表选择对应场景，使用 `execute_sql` 工具执行 RLS SQL。

### Step 6: 初始化客户端 & 读取 database.md

🔴 **这是最关键的一步。** 本步完成两件事：
1. **初始化客户端**：复制我们提供的模板文件，它包含环境变量多来源加载、HTTP 连接池优化、Token 认证等功能——手动编写几乎一定会遗漏这些，导致连接失败或功能缺失。
2. **必须读取 database.md**：Supabase SDK 有大量 Coze 环境特有的陷阱（delete 无 filter 删全表、默认 limit 1000 静默截断等），这些不是通用知识能覆盖的。不读这份文件直接写代码，大概率产出有严重 bug 的代码。

复制客户端模板文件到用户项目（已存在则跳过）：

```bash
TARGET_DIR=$([ -d "$WORKSPACE_PATH/server" ] && echo "$WORKSPACE_PATH/server" || echo "$WORKSPACE_PATH")/src/storage/database
[ ! -f "$TARGET_DIR/supabase_client.py" ] && cp /skills/public/prod/supabase/references/python/supabase_client.py "$TARGET_DIR/supabase_client.py"
```

在代码中引用：

```python
from storage.database.supabase_client import get_supabase_client

client = get_supabase_client()        # 公开操作
client = get_supabase_client(token)   # 带认证操作
```

然后执行：
```
Read references/python/database.md
```

### Step 7: 编写 CRUD 代码

基于 Step 6 读取的 database.md 编写 CRUD 代码。

如需调用 Edge Functions，另读 [edge-functions.md](edge-functions.md)。

### Step 8: 完成

向用户说明改动内容。**不要编写测试。**

***

## 约束

- **字段名必须使用 snake_case**：Supabase SDK 直接使用数据库列名，永远用 `snake_case`，禁止 `camelCase`
- **错误处理必须严格**：调用 SDK 时检查返回值与异常；捕获 `APIError` 等异常后应 `raise` 向上传递，禁止吞错/静默忽略
- **创建表必须设计索引**：外键字段、WHERE 过滤字段、ORDER BY 字段都需要索引；Postgres 不会自动为外键建索引（详见 ORM 模型规范的索引章节）
- 禁止在 `src/storage/database/shared/` 下新增文件，所有模型只放在 `model.py`（单文件便于 `coze-coding-ai db` 命令管理）

***

## 检查清单（提交前自检）

- **🔴 数据操作使用 Supabase SDK（`client.table()`），不用 SQLAlchemy ORM 语法**
- **🔴 字段名使用 snake_case（如 `created_at`）**
- 每次调用都 `try/except APIError` 并 raise
- 新建表已执行 `db upgrade` 并配置了 RLS
- `.delete()` / `.update()` 都带了 filter
- 不要编写测试文件
- **🔴 不要删除或修改 Supabase 内置 schema**（`auth`、`storage`、`realtime`、`extensions`）
