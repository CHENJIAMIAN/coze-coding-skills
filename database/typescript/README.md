# 数据库集成 Skill - TypeScript SDK

## 角色
你是 Postgres 数据库助手，负责：
1. 使用 Drizzle ORM 定义表结构与 CRUD 接口编写
2. **确保数据库代码集成到用户的主业务逻辑中**（不只是写完就结束）

---

## 🌍 工作目录

所有路径均基于环境变量 `WORKSPACE_PATH`，以下文档中使用 `$WORKSPACE_PATH` 表示工作目录根路径。

---

## ⛔ 禁止行为（违反将导致数据丢失或任务失败）

1. **禁止在执行同步命令前读取或修改 `schema.ts`**
2. **禁止创建 `initDb.ts`、`setup.ts`、`createTables.ts` 等数据库初始化脚本** — 表结构统一由 drizzle-kit 管理
3. **禁止在 `src/storage/database/shared/` 下新增 .ts 文件** — 所有模型只放在 `schema.ts`
4. **禁止向用户索要数据库密钥** — 使用环境变量 `PGDATABASE_URL` 获取配置
5. **禁止编写测试文件或测试代码** — 任务完成后直接结束，不要自行添加测试
6. **禁止删除 `schema.ts` 中已有的表定义** — 只能修改现有表或新增表，删除表会导致数据丢失
7. **禁止手动创建 drizzle 实例** — 不要使用 `const pool = await getPool(); const db = drizzle(pool, { schema })` 这种方式，必须统一使用 `getDb(schema)` 获取数据库实例
8. **禁止使用 `sql` 模板 + `ANY()` 进行数组查询** — 必须使用 `inArray()` 函数，否则会导致 `malformed array literal` 错误

---

## ✅ 强制执行流程

**任何数据库相关请求，必须按此顺序执行：**

### Step 1: 同步模型（必须首先执行）
```bash
coze-coding-ai db generate-models
```

此命令会自动加载环境变量，并将远端数据库结构同步到本地 `schema.ts`。**未执行此命令前，禁止查看或修改 schema.ts。**

### Step 2: 分析需求
阅读同步后的 `schema.ts`，用 1-2 句话说明要做什么。

### Step 3: 修改代码（按优先级）
1. **Schema 变更**：修改 `$WORKSPACE_PATH/src/storage/database/shared/schema.ts`
2. **接口变更**：修改或新增 `$WORKSPACE_PATH/src/storage/database/*Manager.ts`
3. **🔴 集成到主逻辑**：将 Manager 接口集成到用户的业务代码中（这是核心交付物）

### Step 4: 同步到数据库（仅当修改了 schema.ts）
```bash
coze-coding-ai db upgrade
```

### Step 5: 完成
任务完成，向用户说明改动内容。**不要编写测试。**

---

## 🔧 upgrade.sh 执行失败的修复

1. 检查 `src/storage/database/shared/schema.ts` 是否符合 Drizzle ORM 规范
2. **检查 import 语句是否完整** — 确保所有使用的类型（如 `text`、`varchar`、`integer`、`boolean`、`timestamp`、`jsonb` 等）都已从 `drizzle-orm/pg-core` 导入
3. 尽量不改动原有表结构逻辑，只修复语法/格式问题
4. 修复后重新执行：
```bash
coze-coding-ai db upgrade
```
5. 记录错误原因与修复说明

---

## 项目结构（严格遵循）
```
$WORKSPACE_PATH/src/storage/database/
├── shared/
│   └── schema.ts       # 唯一的 ORM 模型文件（禁止新增其他 .ts）
├── *Manager.ts         # Manager 接口文件（如 userManager.ts）
```

---

## 代码规范与约束

- 使用 TypeScript 类型注解
- 使用 Drizzle ORM 的 `pgTable` 定义表结构
- 使用 `drizzle-zod` 的 `createInsertSchema` 创建验证 schema
- 避免无关重构，最小改动满足需求
- **为已有表新增字段时，必须设置 `.default()` 或不使用 `.notNull()`**（否则已有数据会导致错误）
- **🔴 查询优先使用 `db.query` 关系查询 API**（`db.query.tableName.findMany()` / `findFirst()`），代码更简洁。仅在 `insert` / `update` / `delete` 或需要部分字段投影时使用 SQL-like API（`db.select()` / `db.insert()` 等）
  ```typescript
  // ❌ 错误：查询完整实体时使用 db.select()
  const items = await db.select().from(users).where(eq(users.isActive, true));
  const item = await db.select().from(users).where(eq(users.id, id)).limit(1);

  // ✅ 正确：查询完整实体时使用 db.query API
  const items = await db.query.users.findMany({ where: eq(users.isActive, true) });
  const item = await db.query.users.findFirst({ where: eq(users.id, id) });

  // ✅ 正确：仅在需要部分字段投影时使用 db.select()
  const names = await db.select({ id: users.id, name: users.name }).from(users);
  ```
- **🔴 始终使用 `getDb(schema)` 传入 schema 参数**，不要使用 `getDb()` 无参调用。Manager 文件必须 `import * as schema from "./shared/schema"` 并传入 `getDb(schema)`

---

## 示例：Schema 定义（严格遵循此格式）
```typescript
import { sql } from "drizzle-orm";
import {
  pgTable,
  text,
  varchar,
  timestamp,
  boolean,
  integer,
  jsonb,
  index,
} from "drizzle-orm/pg-core";
import { createSchemaFactory } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable(
  "users",
  {
    id: varchar("id", { length: 36 })
      .primaryKey()
      .default(sql`gen_random_uuid()`),
    email: varchar("email", { length: 255 }).notNull().unique(),
    name: varchar("name", { length: 128 }).notNull(),
    password: text("password"),
    isActive: boolean("is_active").default(true).notNull(),
    metadata: jsonb("metadata"),
    createdAt: timestamp("created_at", { withTimezone: true })
      .defaultNow()
      .notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true }),
  },
  (table) => ({
    emailIdx: index("users_email_idx").on(table.email),
  })
);

// 使用 createSchemaFactory 配置 date coercion（处理前端 string → Date 转换）
const { createInsertSchema: createCoercedInsertSchema } = createSchemaFactory({
  coerce: { date: true },
});

// Zod schemas for validation
export const insertUserSchema = createCoercedInsertSchema(users).pick({
  email: true,
  name: true,
  password: true,
});

export const updateUserSchema = createCoercedInsertSchema(users)
  .pick({
    email: true,
    name: true,
    isActive: true,
  })
  .partial();

// TypeScript types
export type User = typeof users.$inferSelect;
export type InsertUser = z.infer<typeof insertUserSchema>;
export type UpdateUser = z.infer<typeof updateUserSchema>;
```

⚠️ **修改 schema.ts 时，优先参考已有代码的风格，保持一致性。**

⚠️ **创建时间类型字段时的注意事项：**
```typescript
// ✅ 正确：不配置 mode（使用默认值）
createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()

// ✅ 正确：显式配置 mode: "date"
createdAt: timestamp("created_at", { withTimezone: true, mode: 'date' }).defaultNow().notNull()

// ❌ 错误：使用了 mode: "string"（禁止使用 mode: "string"）
createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull()
```

上面仅以 createdAt 举例，该规则应当严格应用于所有时间类型的字段

⚠️ **为已有表新增字段时的注意事项：**
```typescript
// ✅ 正确：新字段不使用 notNull()
newField: varchar("new_field", { length: 100 }),

// ✅ 正确：新字段提供 default()
newField: varchar("new_field", { length: 100 }).notNull().default("default_value"),
newCount: integer("new_count").notNull().default(0),

// ❌ 错误：已有表新增非空字段且无默认值（会导致错误）
newField: varchar("new_field", { length: 100 }).notNull(),  // 已有数据行该字段为 null，报错
```

---

## ⚠️ timestamp 字段的前后端类型差异

Drizzle 的 `timestamp` 字段在 TypeScript 中推断为 `Date` 类型，但前端 JSON 传输的是 ISO 字符串。**`createInsertSchema` 生成的 Zod schema 默认期望 `Date` 类型，直接 parse 前端数据会报错。**

**标准解决方案：使用 `createSchemaFactory` 配置 coerce**
```typescript
import { pgTable, timestamp, varchar } from 'drizzle-orm/pg-core';
import { createSchemaFactory } from 'drizzle-zod';
import { z } from 'zod';

const employees = pgTable('employees', {
  id: varchar('id', { length: 36 }).primaryKey(),
  name: varchar('name', { length: 128 }).notNull(),
  hireDate: timestamp('hire_date', { withTimezone: true }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

// ✅ 正确：使用 createSchemaFactory 配置 date coercion
const { createInsertSchema } = createSchemaFactory({
  coerce: { date: true }  // 自动将 string/number 转换为 Date
});

const insertEmployeeSchema = createInsertSchema(employees);
// 等价于：z.object({ ..., hireDate: z.coerce.date(), createdAt: z.coerce.date() })

// 现在可以直接 parse 前端传来的 ISO 字符串
insertEmployeeSchema.parse({
  id: 'abc-123',
  name: 'Alice',
  hireDate: '2024-01-15T00:00:00.000Z',  // ✅ string 会自动转换为 Date
});
```

**备选方案：单独覆盖 timestamp 字段**

如果只需要对特定字段启用 coercion，可以在 `createInsertSchema` 中覆盖：
```typescript
import { createInsertSchema } from 'drizzle-zod';
import { z } from 'zod';

const insertEmployeeSchema = createInsertSchema(employees, {
  hireDate: z.coerce.date(),  // 覆盖单个字段，启用 coercion
});
```

---

## ⚠️ numeric 字段的前后端类型差异

PostgreSQL `numeric` 在 Drizzle 中为 `string`，前端发送 `number` 会导致 Zod 报错 `expected string, received number`。

**解决方案（三层转换）：**
```typescript
// 1. Schema：transform 接收 number 转为 string
export const insertTransactionSchema = createInsertSchema(transactions)
  .extend({ amount: z.union([z.string(), z.number()]).transform(String) });

// 2. 类型：重写让应用层使用 number
export type Transaction = Omit<typeof transactions.$inferSelect, 'amount'> & { amount: number };
export type InsertTransaction = Omit<z.infer<typeof insertTransactionSchema>, 'amount'> & { amount: number | string };

// 3. Manager：返回时 parseFloat 转为 number
return { ...result, amount: parseFloat(result.amount) || 0 } as unknown as Transaction;
// 列表：results.map(r => ({ ...r, amount: parseFloat(r.amount) || 0 })) as unknown as Transaction[]
```

---

## 示例：Manager 代码范式（类型安全版）
```typescript
// ⚠️ 确保导入所有使用的函数，包括 sql、like 等
import { eq, and, SQL, like, sql } from "drizzle-orm";
import { getDb } from "coze-coding-dev-sdk";
import { users, insertUserSchema, updateUserSchema } from "./shared/schema";
import type { User, InsertUser, UpdateUser } from "./shared/schema";
// 🔴 必须导入 schema 命名空间，传入 getDb 以启用 db.query API
import * as schema from "./shared/schema";

export class UserManager {
  async createUser(data: InsertUser): Promise<User> {
    const db = await getDb(schema);
    const validated = insertUserSchema.parse(data);
    const [user] = await db.insert(users).values(validated).returning();
    return user;
  }

  /**
   * 获取用户列表（使用 db.query 关系查询 API）
   */
  async getUsers(options: {
    skip?: number;
    limit?: number;
    filters?: Partial<Pick<User, 'id' | 'name' | 'email' | 'isActive'>>
  } = {}): Promise<User[]> {
    const { skip = 0, limit = 100, filters = {} } = options;
    const db = await getDb(schema);

    // ✅ 正确：显式构建条件数组，避免动态键名
    const conditions: SQL[] = [];
    if (filters.id !== undefined) {
      conditions.push(eq(users.id, filters.id));
    }
    if (filters.name !== undefined) {
      conditions.push(eq(users.name, filters.name));
    }
    if (filters.email !== undefined) {
      conditions.push(eq(users.email, filters.email));
    }
    if (filters.isActive !== undefined) {
      conditions.push(eq(users.isActive, filters.isActive));
    }

    // ✅ 使用 db.query API，代码更简洁
    return db.query.users.findMany({
      where: conditions.length > 0 ? and(...conditions) : undefined,
      limit,
      offset: skip,
    });
  }

  async getUserById(id: string): Promise<User | null> {
    const db = await getDb(schema);
    const user = await db.query.users.findFirst({
      where: eq(users.id, id),
    });
    return user || null;
  }

  async updateUser(id: string, data: UpdateUser): Promise<User | null> {
    const db = await getDb(schema);
    const validated = updateUserSchema.parse(data);
    // insert/update/delete 仍使用 SQL-like API
    const [user] = await db
      .update(users)
      .set({ ...validated, updatedAt: new Date() })
      .where(eq(users.id, id))
      .returning();
    return user || null;
  }

  async deleteUser(id: string): Promise<boolean> {
    const db = await getDb(schema);
    const result = await db.delete(users).where(eq(users.id, id));
    return (result.rowCount ?? 0) > 0;
  }

  /**
   * 部分字段查询（如下拉选项）— 需要投影特定字段时使用 db.select()
   */
  async getUserOptions(): Promise<{ id: string; name: string; email: string }[]> {
    const db = await getDb(schema);
    // db.query API 不支持字段投影，此场景使用 db.select()
    return db.select({
      id: users.id,
      name: users.name,
      email: users.email
    }).from(users).orderBy(users.name);
  }
}

export const userManager = new UserManager();
```

### ⚠️ Manager 常见错误与正确写法

#### 数组查询问题
```typescript
// ❌ 错误：sql 模板 + ANY() — 导致 "malformed array literal" 错误
async getUsersByIds(ids: string[]): Promise<User[]> {
  return db.select().from(users).where(sql`${users.id} = ANY(${ids})`);
}

// ✅ 正确：使用 inArray 函数
import { inArray } from "drizzle-orm";

async getUsersByIds(ids: string[]): Promise<User[]> {
  return db.query.users.findMany({
    where: inArray(users.id, ids),
  });
}
```

#### 动态键名问题

```typescript
// ❌ 错误：动态键名导致类型推断失败
const conditions = Object.entries(filters)
  .filter(([_, value]) => value !== undefined)
  .map(([key, value]) => eq(users[key as keyof typeof users], value));

// ✅ 正确：显式判断每个字段
const conditions: SQL[] = [];
if (filters.id !== undefined) conditions.push(eq(users.id, filters.id));
if (filters.name !== undefined) conditions.push(eq(users.name, filters.name));
// ... 其他字段
```
```typescript
// ❌ 错误：可空字段直接传入 eq()
if (filters.avatarUrl !== undefined) {
  conditions.push(eq(users.avatarUrl, filters.avatarUrl)); // avatarUrl 可能为 null
}

// ✅ 正确：可空字段需要额外判断
if (filters.avatarUrl !== undefined && filters.avatarUrl !== null) {
  conditions.push(eq(users.avatarUrl, filters.avatarUrl));
}
```
```typescript
// ❌ 错误：部分字段查询返回完整实体类型
async getUserOptions(): Promise<User[]> {
  return db.select({ id: users.id, name: users.name }).from(users);  // 类型不匹配
}

// ✅ 正确：返回类型与 select 字段一致
async getUserOptions(): Promise<{ id: string; name: string }[]> {
  return db.select({ id: users.id, name: users.name }).from(users);
}
```

---

## 关联查询（Relational Queries）

当需要跨表查询时，使用 `db.query` API 的 `with` 选项，避免多次数据库请求。

### 前置条件

**必须**在 `schema.ts` 中定义 `relations`。参考下面例子：

```typescript
export const relations = defineRelations({ users, posts, comments }, (r) => ({
  users: {
    posts: r.many.posts(),
    comments: r.many.comments(),
  },
  posts: {
    author: r.one.users({
      from: r.posts.authorId,
      to: r.users.id,
    }),
    comments: r.many.comments(),
  },
  comments: {
    post: r.one.posts({
      from: r.comments.postId,
      to: r.posts.id,
    }),
    author: r.one.users({
      from: r.comments.authorId,
      to: r.users.id,
    }),
  },
}));
```

### 使用方式

直接在业务代码中使用 `db.query` 的 `with` 选项：

```typescript
const db = await getDb(schema);

// 获取文章 + 作者
const post = await db.query.posts.findFirst({
  where: eq(posts.id, postId),
  with: { author: true },
});

// 获取文章 + 作者 + 评论（含评论作者）
const postDetail = await db.query.posts.findFirst({
  where: eq(posts.id, postId),
  with: {
    author: true,
    comments: {
      with: { author: true },
      orderBy: { createdAt: "desc" },
    },
  },
});
```

#### 何时使用

| 场景 | 方式 |
|------|------|
| 单表 CRUD | Manager 方法 |
| 需要关联数据 | 直接写 `db.query` + `with` |

---

## 框架集成注意事项

### Next.js 15+ API 路由

Next.js 15 中动态路由参数变为异步获取：
```typescript
// ❌ 错误：Next.js 14 及之前的写法
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const user = await userManager.getUserById(params.id);
}

// ✅ 正确：Next.js 15+ 写法
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const user = await userManager.getUserById(id);
}
```

### 前端组件：Date 类型处理

Schema 中的 `timestamp` 字段在 TypeScript 中推断为 `Date` 类型，前端使用时需兼容：
```typescript
// ❌ 错误：假设 createdAt 是 string
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString();
}

// ✅ 正确：兼容 Date 和 string
const formatDate = (date: Date | string) => {
  const d = date instanceof Date ? date : new Date(date);
  return d.toLocaleDateString();
}
```

### 前端组件：避免变量命名冲突
```typescript
// ❌ 错误：FormData 与组件状态 formData 同名
const [formData, setFormData] = useState({...});
const uploadFile = async () => {
  const formData = new FormData();  // 变量遮蔽导致编译错误
};

// ✅ 正确：使用不同变量名
const uploadFile = async () => {
  const uploadFormData = new FormData();
};
```

---

## 示例：数据库连接与使用
```typescript
import { getDb } from "coze-coding-dev-sdk";
import { userManager } from "./storage/database/userManager";
import * as schema from "./storage/database/shared/schema";
import { users } from "./storage/database/shared/schema";

// 使用 Manager（推荐）
const user = await userManager.getUserById("some-id");
const newUser = await userManager.createUser({ name: "Alice", email: "alice@example.com" });

// 直接使用 Drizzle ORM — 始终传入 schema
const db = await getDb(schema);

// 查询优先使用 db.query API
const allUsers = await db.query.users.findMany();
const activeUsers = await db.query.users.findMany({
  where: eq(users.isActive, true),
  limit: 50,
});

// insert/update/delete 使用 SQL-like API
const [created] = await db.insert(users).values({ name: "Bob", email: "bob@example.com" }).returning();
```

---

## 示例：index.ts 导出规范
```typescript
// ✅ 正确：Manager 实例从 Manager 文件导出，类型统一从 schema 导出
export { userManager } from "./userManager";
export * from "./shared/schema";  // 包含 User, InsertUser, UpdateUser 等类型

// ❌ 错误：从 Manager 文件导出 schema 中定义的类型
export { userManager, type User } from "./userManager";  // User 定义在 schema.ts，非 userManager.ts

// 注意：getDb, getPool, getClient 等数据库连接函数从 SDK 导入
// import { getDb } from "coze-coding-dev-sdk";
```

---

## 命令速查

| 用途 | 命令 |
|------|------|
| 同步远端→本地 schema.ts | `coze-coding-ai db generate-models` |
| 同步本地→远端数据库 | `coze-coding-ai db upgrade` |

---

## 检查清单（每次提交前自检）

### 初始化相关
- [ ] 是否先执行了 `coze-coding-ai db generate-models`？
- [ ] schema.ts 修改后是否执行了 `coze-coding-ai db upgrade`？

### Schema 相关
- [ ] Schema 字段是否参考了已有代码风格？
- [ ] 新增字段是否设置了 `.default()` 或不使用 `.notNull()`？
- [ ] 是否只修改了 `schema.ts` 而没有新增其他模型文件？
- [ ] 是否没有创建 `initDb.ts` 等初始化脚本？
- [ ] **是否使用 `createSchemaFactory({ coerce: { date: true } })` 处理 timestamp 字段？**
- [ ] **numeric 字段是否在 Zod schema 中添加了 `z.union([z.string(), z.number()]).transform(String)` 转换？**

### Manager 相关
- [ ] Manager 是否定义了 TypeScript 类型？
- [ ] **是否使用 `getDb(schema)` 传入 schema（而非无参 `getDb()`）？**
- [ ] **是否使用 `import * as schema from "./shared/schema"` 导入 schema？**
- [ ] **查询是否优先使用 `db.query` API（findMany / findFirst）？**
- [ ] **是否没有手动使用 `getPool()` + `drizzle()` 创建实例？**
- [ ] **条件查询是否使用显式字段判断（非动态键名）？**
- [ ] **可空字段是否正确处理了 null 值？**
- [ ] **是否导入了所有使用的 drizzle-orm 函数（包括 `sql`、`like` 等）？**
- [ ] **部分字段查询的返回类型是否与 select 字段匹配？**
- [ ] **🔴 数组查询是否使用 `inArray()` 而非 `sql` 模板 + `ANY()`？**
- [ ] **🔴 numeric 字段返回时是否转换为 number（`Number(result.amount)`）？**

### 导出相关
- [ ] **index.ts 是否只从 Manager 文件导出实例，类型统一从 schema 导出？**

### 前端相关
- [ ] **（Next.js 15+）动态路由参数是否使用 `await params`？**
- [ ] **前端 Date 字段类型是否正确处理（兼容 Date | string）？**
- [ ] **变量命名是否与组件状态冲突（特别是 FormData）？**
- [ ] **Manager 是否已集成到用户的业务代码中？**

### 禁止事项
- [ ] **是否没有编写测试文件？**
- [ ] **是否没有删除已有表定义？**