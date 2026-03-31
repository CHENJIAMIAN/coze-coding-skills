# 数据库操作（TypeScript）

> Initialize `client` per Step 3 in [README.md](./README.md).

> ⚠️ Supabase SDK 不会抛异常，错误通过 `{ data, error }` 返回。**所有操作必须检查 error 并 throw，禁止 console.error 后继续。**

## 查询

```typescript
const { data, error } = await client.from('users').select('id, name').eq('status', 'active').order('created_at', { ascending: false }).limit(10)
if (error) throw new Error(`查询失败: ${error.message}`)
```

> **避免 `select('*')`**：表有大 JSONB/TEXT 字段时每行数据量膨胀。只取需要的列。

### .single() vs .maybeSingle()

```typescript
// ✅ 结果可能为空 → .maybeSingle()，返回 null 而非报错
const { data, error } = await client.from('config').select('*').eq('key', 'site_settings').maybeSingle()
if (error) throw new Error(`查询失败: ${error.message}`)

// ✅ 按主键查且 100% 确定存在 → .single()
// ❌ 结果可能为空时用 .single() → PGRST116 错误
```

> **规则**：默认用 `.maybeSingle()`，只有 100% 确定有且仅有 1 行时才用 `.single()`。

### 🔴 .eq() 不能匹配 NULL — 必须用 .is()

```typescript
// ❌ 永远匹配不到 NULL 行（SQL: col = NULL → NULL，不是 TRUE）
const { data } = await client.from('users').select('*').eq('deleted_at', null)

// ✅ 匹配 NULL
const { data } = await client.from('users').select('*').is('deleted_at', null)
// ✅ 匹配 NOT NULL
const { data } = await client.from('users').select('*').not('deleted_at', 'is', null)
```

### 🔴 .neq() 不包含 NULL 行

```typescript
// ❌ status 为 NULL 的行也被排除了（SQL 三值逻辑：NULL != 'deleted' → NULL）
const { data } = await client.from('users').select('*').neq('status', 'deleted')

// ✅ 要同时包含 NULL 行
const { data } = await client.from('users').select('*').or('status.neq.deleted,status.is.null')
```

### .or() 必须用 PostgREST 原始字符串语法

```typescript
// ✅ 逗号分隔，无空格，PostgREST 操作符
.or('role.eq.admin,role.eq.moderator')
// ✅ IN 列表
.or('id.in.(1,2,3),status.eq.active')
// ✅ AND 嵌套在 OR 内
.or('role.eq.admin,and(age.gte.18,status.eq.active)')
// ❌ 逗号后加空格可能导致解析异常
.or('role.eq.admin, role.eq.moderator')
```

### N+1 查询防范

```typescript
// ❌ 循环中逐条查询（100 个用户 = 101 次数据库往返）
for (const user of users) {
  const { data } = await client.from('orders').select('*').eq('user_id', user.id)
}

// ✅ 批量查询（1 次往返）
const userIds = users.map(u => u.id)
const { data } = await client.from('orders').select('*').in('user_id', userIds)

// ✅ 嵌套查询（需要外键，1 次往返）
const { data } = await client.from('users').select('*, orders(*)')
```

---

## 插入

```typescript
const { data, error } = await client.from('users').insert({ name: 'John', email: 'john@example.com' }).select()
if (error) throw new Error(`插入失败: ${error.message}`)
// .select() 返回插入后的完整记录（含自动生成的 id）
// 不链 .select() 则 data 为 null

// ✅ 批量插入（1 次网络往返），禁止循环单条插入
const { error } = await client.from('users').insert([{ name: 'A' }, { name: 'B' }])
if (error) throw new Error(`批量插入失败: ${error.message}`)
```

### Upsert（插入或更新）

```typescript
// ✅ 原子操作，避免 "先查再插/更新" 的竞态条件
const { data, error } = await client
  .from('settings')
  .upsert(
    { user_id: '123', key: 'theme', value: 'dark' },
    { onConflict: 'user_id,key' }
  )
  .select()
if (error) throw new Error(`Upsert 失败: ${error.message}`)
```

> **前提**：表上必须有唯一约束。幂等添加（Postgres 没有 `ADD CONSTRAINT IF NOT EXISTS`）：
> ```sql
> DO $$ BEGIN
>   ALTER TABLE settings ADD CONSTRAINT settings_user_key_unique UNIQUE (user_id, key);
> EXCEPTION WHEN duplicate_object THEN NULL;
> END $$;
> ```

---

## 更新

```typescript
const { data, error } = await client.from('users').update({ name: 'Jane' }).eq('id', 1).select()
if (error) throw new Error(`更新失败: ${error.message}`)
// 不链 .select() 则 data 为 null
// RLS 可能导致"成功但 0 行受影响"（返回空 data），需检查
```

### 🔴 不带 filter = 更新全表

```typescript
// ❌ 更新全表所有行！！
await client.from('users').update({ status: 'inactive' })

// ✅ 必须带 filter
await client.from('users').update({ status: 'inactive' }).eq('id', 1)
```

### 🔴 .in() 传空数组 → 更新全表

```typescript
const ids: string[] = []  // 某个查询返回空结果
// ❌ .in('id', []) → filter 被静默丢弃 → 无条件 update → 改全表！
await client.from('orders').update({ status: 'cancelled' }).in('id', ids)

// ✅ 调用前必须检查数组非空
if (ids.length > 0) {
  await client.from('orders').update({ status: 'cancelled' }).in('id', ids)
}
```

### 避免死锁

多行更新时用单条 UPDATE 原子操作（通过 RPC），避免并发锁冲突：

```sql
UPDATE accounts SET balance = CASE
  WHEN id = from_id THEN balance - amount
  WHEN id = to_id THEN balance + amount
END WHERE id IN (from_id, to_id);
```

---

## 删除

```typescript
const { data, error } = await client.from('users').delete().eq('id', 1).select()
if (error) throw new Error(`删除失败: ${error.message}`)
// 不链 .select() 则 data 为 null（不知道删了什么）
```

### 🔴 不带 filter = 删全表

```typescript
// ❌ 删除整个表所有行！！
await client.from('users').delete()

// ✅ 必须带 filter
await client.from('users').delete().eq('id', 1)
```

> `.in()` 传空数组同样危险（同更新），调用前必须检查非空。

---

## 关联查询

> **🔴 嵌套查询需要数据库外键约束，否则报错 `PGRST200`。**
> schema.ts 中关联字段必须有 `.references()`，否则先添加外键并执行 `coze-coding-ai db upgrade`。详见 [drizzle-schema-guide.md](./drizzle-schema-guide.md)。

```typescript
// ✅ schema.ts 中 posts.user_id 有 .references(() => users.id)
const { data, error } = await client.from('posts').select('*, users(name, email)')
if (error) throw new Error(`关联查询失败: ${error.message}`)

// ❌ 缺少 .references() → PGRST200: Could not find a relationship
```

无法修改 schema 时，用多次查询 + `.in()` 批量查询 + Map 组装（避免 N+1）。

---

## 聚合 & RPC

```typescript
// ✅ 统计数量（不加载数据，不受 1000 行上限影响）
const { count, error } = await client.from('users').select('*', { count: 'exact', head: true })
if (error) throw new Error(`统计失败: ${error.message}`)

// ❌ 不要用 data.length 统计（受 1000 行截断影响）

// ✅ RPC 调用必须检查 error
const { data, error } = await client.rpc('calculate_total', { table: 'orders' })
if (error) throw new Error(`RPC 调用失败: ${error.message}`)
```

> 简单计数/状态更新优先用应用层 SDK。事务中不要做外部调用（支付 API 等），持锁时间长会阻塞其他查询。

---

## 分页

### 🔴 默认 limit 1000 行

Supabase SDK 默认最多返回 1000 行，超过部分**被静默截断，不报错**。可能超过 1000 行的查询必须分页或显式 `.limit()`。

```typescript
async function fetchAll<T>(table: string, pageSize = 1000): Promise<T[]> {
  const all: T[] = []
  let page = 0
  while (true) {
    const { data, error } = await client
      .from(table).select('*')
      .order('id').range(page * pageSize, (page + 1) * pageSize - 1)
    if (error) throw new Error(`分页查询失败: ${error.message}`)
    if (!data?.length) break
    all.push(...data as T[])
    if (data.length < pageSize) break
    page++
  }
  return all
}
```

### OFFSET 分页

> ⚠️ **`.range()` 必须搭配 `.order()` — 没有 order 时并发写入会导致同一行在不同分页中重复出现。**

```typescript
const { data, error } = await client.from(table).select('*').order('id').range(page * size, (page + 1) * size - 1)
if (error) throw new Error(`分页查询失败: ${error.message}`)
```

### 游标分页（大数据量翻页）

`.range()` 底层用 OFFSET，越翻越慢（第 100 页比第 1 页慢 100 倍）。面向用户的大表分页用游标分页：

```typescript
// ✅ 恒定 O(1) 速度
const { data } = await client
  .from('posts')
  .select('id, title, created_at')
  .order('created_at', { ascending: false })
  .lt('created_at', lastSeenCreatedAt)  // 游标：上一页最后一条的值
  .limit(20)
```

> 管理后台 / 导出用 `.range()`。面向用户的无限滚动用游标分页。

---

## 全文搜索（替代 ilike）

`.ilike('col', '%keyword%')` 无法使用索引，全表扫描。用 `.textSearch()`，性能提升 100x+。

**第一步**：通过 `execute_sql` 添加 tsvector 列 + GIN 索引：

```sql
ALTER TABLE articles ADD COLUMN IF NOT EXISTS fts tsvector
  GENERATED ALWAYS AS (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))) STORED;
CREATE INDEX IF NOT EXISTS articles_fts_idx ON articles USING gin (fts);
```

**第二步**：SDK 查询：

```typescript
const { data, error } = await client
  .from('articles')
  .select('id, title, created_at')
  .textSearch('fts', 'supabase & database', { type: 'websearch' })
if (error) throw new Error(`搜索失败: ${error.message}`)

// ❌ 不要用 ilike 做搜索
```

> 默认 `english` parser 对中文支持有限，中文搜索需要 pgroonga 等扩展。

---

## 类型安全

> **🔴 禁止 `createClient<Database>` 泛型。** `database.types.ts` 在 Coze 环境中不存在。添加 `<Database>` 会导致 TS2307/TS2349 编译错误。

```typescript
// ✅ 不带泛型，用 as 断言
const client = getSupabaseClient()

interface Post { id: string; title: string; content: string; author_id: string }
const { data, error } = await client.from('posts').select('*')
if (error) throw new Error(`查询失败: ${error.message}`)
const posts = data as Post[]

// ❌ database.types.ts 不存在
import type { Database } from './database.types'
```

---

## 常见错误码

| 错误码 | 含义 | 解决方法 |
|--------|------|---------|
| `PGRST116` | `.single()` 返回 0 行或多行 | 改用 `.maybeSingle()` 并处理 null |
| `PGRST200` | 嵌套查询找不到表关系 | schema.ts 中给关联字段加 `.references()`，然后 `db upgrade` |
| `23505` | 唯一约束冲突（重复数据） | 改用 `.upsert()` 或先查询再插入 |
| `42501` | RLS 权限不足 | 检查 RLS 策略是否配置，场景是否匹配 Auth 状态 |
| `42P01` | 表不存在 | 检查表名拼写，确认已执行 `db upgrade` |
