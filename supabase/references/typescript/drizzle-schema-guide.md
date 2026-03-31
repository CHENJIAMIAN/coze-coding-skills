# TypeScript Drizzle Schema 定义规范

## 示例

```typescript
import { sql } from "drizzle-orm";
import { pgTable, text, varchar, timestamp, boolean, integer, jsonb, index } from "drizzle-orm/pg-core";
import { createSchemaFactory } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable(
  "users",
  {
    id: varchar("id", { length: 36 }).primaryKey().default(sql`gen_random_uuid()`),
    email: varchar("email", { length: 255 }).notNull().unique(),
    name: varchar("name", { length: 128 }).notNull(),
    is_active: boolean("is_active").default(true).notNull(),
    metadata: jsonb("metadata"),
    created_at: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
    updated_at: timestamp("updated_at", { withTimezone: true }),
  },
  (table) => [index("users_email_idx").on(table.email)]
);

const { createInsertSchema: createCoercedInsertSchema } = createSchemaFactory({ coerce: { date: true } });
export const insertUserSchema = createCoercedInsertSchema(users).pick({ email: true, name: true });
export type User = typeof users.$inferSelect;
export type InsertUser = z.infer<typeof insertUserSchema>;
```

## 🔴 关键规则

### 主键和外键

`id` 必须用 `.primaryKey()`，关联字段必须用 `.references()`。缺一不可，否则嵌套查询报错 `PGRST200`。

```typescript
// ✅ 主键和外键类型必须匹配
// serial 主键 + integer 外键
id: serial().primaryKey(),
category_id: integer("category_id").notNull().references(() => categories.id),

// varchar 主键 + varchar 外键
id: varchar("id", { length: 36 }).primaryKey().default(sql`gen_random_uuid()`),
category_id: varchar("category_id", { length: 36 }).notNull().references(() => categories.id),

// 级联删除
category_id: integer("category_id").notNull().references(() => categories.id, { onDelete: "cascade" }),

// ❌ 错误
id: serial().notNull(),                          // 不是主键
category_id: integer("category_id").notNull(),   // 缺少 .references()
category_id: serial("category_id").references(() => categories.id),  // serial 会自增，关联静默失效
```

> **检查规则**：每个 `_id` 字段（除主键 `id`），如果存储另一个表的主键值，必须加 `.references()`。

> **已有表补救**：Schema 补加主键后 `db upgrade` 不一定生效，需在 SQL Editor 手动 `ALTER TABLE xxx ADD PRIMARY KEY (id);`。

### 数据类型选择

- **时间必须用 `withTimezone: true`**：`timestamp("col", { withTimezone: true })` — 不带时区在跨时区场景出错（存入的时间被当作 UTC 还是本地时间不确定）
- **金额用 `numeric`，不用 `real` / `doublePrecision`**：浮点有精度问题（`0.1 + 0.2 !== 0.3`），金融计算用 `numeric("price", { precision: 10, scale: 2 })`
- **大表主键考虑 `bigserial`**：`serial` 在 21 亿行后溢出。小型项目 `serial` 或 `varchar` UUID 即可

### 字段命名必须 snake_case

TypeScript 字段名必须和数据库列名一致，统一 snake_case。

```typescript
// ✅ 正确
category_id: varchar("category_id", { length: 36 }),

// ❌ 错误：Supabase Client insert 时必须写 category_id，不是 categoryId
categoryId: varchar("category_id", { length: 36 }),
```

### 🔴 创建表时必须设计索引

**Postgres 不会自动为外键创建索引。** 每次创建新表，必须为以下字段建索引：

1. **外键字段** — 缺失索引导致嵌套查询和 CASCADE 全表扫描
2. **常用 WHERE 过滤字段** — `.eq()`, `.gt()`, `.in()` 等过滤条件的列
3. **ORDER BY 字段** — 排序字段无索引需全表扫描后排序
4. **RLS 策略中的 user_id** — 每行检查都要查这个字段

```typescript
export const orders = pgTable(
  "orders",
  {
    id: varchar("id", { length: 36 }).primaryKey().default(sql`gen_random_uuid()`),
    customer_id: varchar("customer_id", { length: 36 }).notNull().references(() => customers.id),
    status: varchar("status", { length: 20 }).notNull().default("pending"),
    created_at: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  },
  (table) => [
    index("orders_customer_id_idx").on(table.customer_id),  // 外键必须有索引
    index("orders_status_idx").on(table.status),             // 常用过滤字段
    index("orders_created_at_idx").on(table.created_at),     // 排序字段
  ]
);
```

> 多列查询（如 `WHERE status = 'pending' AND created_at > X`）用复合索引更高效：
> ```typescript
> // 等值条件列在前，范围条件列在后
> index("orders_status_created_idx").on(table.status, table.created_at)
> ```
> 最左前缀规则：`(status, created_at)` 可用于 `WHERE status = X`，但不能单独用于 `WHERE created_at > X`。

**部分索引**（只索引有用的行，缩小 5-20x）：

```sql
-- 通过 execute_sql 创建，Drizzle 不直接支持部分索引
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

### 索引必须使用数组语法（v0.30+）

```typescript
// ✅ 返回数组
(table) => [index("users_email_idx").on(table.email)]

// ❌ 返回对象（旧语法，TypeScript 类型检查失败）
(table) => ({ emailIdx: index("users_email_idx").on(table.email) })
```

### 禁止使用 `exports` 作为表变量名

`exports` 是 CJS 保留名，`drizzle-kit push` 会覆盖 `module.exports`，导致表不被创建且不报错。

```typescript
// ❌ export const exports = pgTable("exports", { ... });
// ✅ export const exportRecords = pgTable("exports", { ... });
```

### 向后兼容

修改已有表时：不删字段、不改类型、不把可选改为 `.notNull()`。

```typescript
// ✅ 新字段不用 notNull() 或提供 default()
new_field: varchar("new_field", { length: 100 }),
new_field: varchar("new_field", { length: 100 }).notNull().default("default_value"),

// ❌ 已有表新增非空字段无默认值 → 已有数据报错
new_field: varchar("new_field", { length: 100 }).notNull(),
```

### 禁止删除系统表

`health_check` 等系统表必须保留。删除会导致 `must be owner of table health_check` 错误。

```typescript
export const healthCheck = pgTable("health_check", {
  id: serial().notNull(),
  updated_at: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow(),
});
```

> 不要从 `health_check` 学习写法——`serial().notNull()` 仅用于防删表，不是业务表规范。

## user_id 字段（🔴 绝大多数表不需要）

**默认不要添加。** 只有 RLS 场景 D（用户只能操作自己的数据）才需要。场景 A/B/C 均不需要。

错误添加会导致运行时错误：`auth.uid()` 在非认证上下文返回 `NULL`，`notNull()` 约束导致 INSERT 失败。

```typescript
// ✅ 仅场景 D
import { sql } from "drizzle-orm";
import { uuid } from "drizzle-orm/pg-core";
user_id: uuid("user_id").notNull().default(sql`auth.uid()`),
```
