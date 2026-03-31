# Python ORM 模型定义规范

## 示例

```python
from sqlalchemy import BigInteger, Boolean, DateTime, Float, ForeignKey, Index, Integer, String, Text, JSON, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from typing import Optional
from datetime import datetime
from coze_coding_dev_sdk.database import Base

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, comment="用户邮箱")
    name: Mapped[str] = mapped_column(String(128), nullable=False)
    age: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    metadata_json: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), onupdate=func.now(), nullable=True)

    department_id: Mapped[Optional[int]] = mapped_column(Integer, ForeignKey("departments.id"), nullable=True)
    articles: Mapped[list["Article"]] = relationship("Article", back_populates="author")

    __table_args__ = (Index("ix_users_email", "email"),)
```

**mapped_column 常用参数**：`primary_key`, `unique`, `nullable`, `default`, `server_default`, `index`, `onupdate`, `ForeignKey`, `comment`

## 🔴 关键规则

### 主键和外键

`id` 必须用 `primary_key=True`，关联字段必须用 `ForeignKey()`。缺一不可，否则嵌套查询报错 `PGRST200`。

```python
# ✅ 正确
id: Mapped[int] = mapped_column(Integer, primary_key=True)
category_id: Mapped[int] = mapped_column(Integer, ForeignKey("categories.id"), nullable=False)

# ❌ 错误
id: Mapped[int] = mapped_column(Integer, nullable=False)       # 不是主键
category_id: Mapped[int] = mapped_column(Integer, nullable=False)  # 缺少 ForeignKey
```

> **检查规则**：每个 `_id` 字段（除主键 `id`），如果存储另一个表的主键值，必须加 `ForeignKey()`。

### 数据类型选择

- **时间必须用 `timezone=True`**：`DateTime(timezone=True)` — 不带时区在跨时区场景出错（存入的时间被当作 UTC 还是本地时间不确定）
- **金额用 `Numeric`，不用 `Float`**：浮点有精度问题（`0.1 + 0.2 != 0.3`），金融计算用 `Numeric(precision=10, scale=2)`
- **大表主键考虑 `BigInteger`**：`Integer` 在 21 亿行后溢出。小型项目 `Integer` 即可

### 🔴 创建表时必须设计索引

**Postgres 不会自动为外键创建索引。** 每次创建新表，必须为以下字段建索引：

1. **外键字段** — 缺失索引导致嵌套查询和 CASCADE 全表扫描
2. **常用 WHERE 过滤字段** — `.eq()`, `.gt()`, `.in()` 等过滤条件的列
3. **ORDER BY 字段** — 排序字段无索引需全表扫描后排序
4. **RLS 策略中的 user_id** — 每行检查都要查这个字段

```python
class Order(Base):
    __tablename__ = "orders"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    customer_id: Mapped[int] = mapped_column(Integer, ForeignKey("customers.id"), nullable=False)
    status: Mapped[str] = mapped_column(String(20), nullable=False, server_default="pending")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    __table_args__ = (
        Index("orders_customer_id_idx", "customer_id"),   # 外键必须有索引
        Index("orders_status_idx", "status"),              # 常用过滤字段
        Index("orders_created_at_idx", "created_at"),      # 排序字段
    )
```

> 多列查询（如 `WHERE status = 'pending' AND created_at > X`）用复合索引更高效：
> ```python
> # 等值条件列在前，范围条件列在后
> Index("orders_status_created_idx", "status", "created_at")
> ```
> 最左前缀规则：`(status, created_at)` 可用于 `WHERE status = X`，但不能单独用于 `WHERE created_at > X`。

**部分索引**（只索引有用的行，缩小 5-20x）：

```sql
-- 通过 execute_sql 创建，SQLAlchemy 不直接支持部分索引语法
CREATE INDEX users_active_email_idx ON users (email) WHERE deleted_at IS NULL;
CREATE INDEX orders_pending_idx ON orders (created_at) WHERE status = 'pending';
```

**索引类型选择**：

| 类型 | 适用场景 | 示例 |
|-----|---------|------|
| B-tree（默认） | `=`, `<`, `>`, `BETWEEN`, `IN` | `CREATE INDEX idx ON t (col)` |
| GIN | JSONB、数组、全文搜索 | `CREATE INDEX idx ON t USING gin (metadata)` |
| BRIN | 大时序表（比 B-tree 小 100x） | `CREATE INDEX idx ON t USING brin (created_at)` |

> JSONB 列被频繁查询时必须建 GIN 索引，否则全表扫描。

**查找缺失外键索引**：

```sql
SELECT conrelid::regclass AS table_name, a.attname AS fk_column
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE c.contype = 'f'
  AND NOT EXISTS (SELECT 1 FROM pg_index i WHERE i.indrelid = c.conrelid AND a.attnum = ANY(i.indkey));
```

> **UUID 主键注意**：`gen_random_uuid()` 是 UUIDv4（随机），超大表（>100 万行）导致索引碎片化。小型项目没问题。

### 向后兼容

修改已有表时：不删字段、不改类型、不把 `nullable=True` 改为 `nullable=False`。

```python
# ✅ 新字段设 nullable=True 或提供 server_default
new_field: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
new_field: Mapped[str] = mapped_column(String(100), nullable=False, server_default="default_value")

# ❌ 已有表新增非空字段无默认值 → NotNullViolation
new_field: Mapped[str] = mapped_column(String(100), nullable=False)
```

### 其他注意事项

- 追加新表时确保导入了所有使用的类型（否则 `NameError`）
- 修改 model.py 时优先参考已有代码风格
- 时间类型要使用 `Mapped[datetime]` 或 `Mapped[Optional[datetime]]`

### 禁止删除系统表

`health_check` 等系统表必须保留。

```python
class HealthCheck(Base):
    __tablename__ = "health_check"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    updated_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
```

## user_id 字段（🔴 绝大多数表不需要）

**默认不要添加。** 只有 RLS 场景 D（用户只能操作自己的数据）才需要。场景 A/B/C 均不需要。

错误添加会导致运行时错误：`auth.uid()` 在非认证上下文返回 `NULL`，`nullable=False` 约束导致 INSERT 失败。

```python
# ✅ 仅场景 D
from sqlalchemy import text
from sqlalchemy.dialects.postgresql import UUID

user_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False, server_default=text("auth.uid()"))
```
