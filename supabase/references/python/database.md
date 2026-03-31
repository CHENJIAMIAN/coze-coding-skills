# 数据库操作（Python）

> Initialize `client` per Step 3 in [README.md](./README.md).

> ⚠️ Supabase Python SDK 的 `.execute()` 在 HTTP 错误时抛出 `APIError`。**所有操作必须 `try/except APIError` 并 raise，禁止 `except: pass`。**

```python
from postgrest.exceptions import APIError
```

## 查询

```python
try:
    response = client.table('users').select('id, name').eq('status', 'active').order('created_at', desc=True).limit(10).execute()
except APIError as e:
    raise Exception(f"查询失败: {e.message}")
```

> **避免 `select('*')`**：表有大 JSON/TEXT 字段时每行数据量膨胀。只取需要的列。

### .single() vs .maybe_single()

```python
# ✅ 结果可能为空 → .maybe_single()，无匹配行时返回 None
try:
    response = client.table('config').select('*').eq('key', 'site_settings').maybe_single().execute()
    # 注意：无匹配行时 response 直接是 None（不是 response.data 为 None）
    if response is None:
        pass  # 处理空值
    else:
        print(response.data)
except APIError as e:
    raise Exception(f"查询失败: {e.message}")

# ✅ 按主键查且 100% 确定存在 → .single()
# ❌ 结果可能为空时用 .single() → APIError (PGRST116)
```

> **规则**：默认用 `.maybe_single()`，只有 100% 确定有且仅有 1 行时才用 `.single()`。

### 🔴 .eq() 不能匹配 NULL — 必须用 .is_()

```python
# ❌ 永远匹配不到 NULL 行（SQL: col = NULL → NULL，不是 TRUE）
response = client.table('users').select('*').eq('deleted_at', 'null').execute()

# ✅ 匹配 NULL
response = client.table('users').select('*').is_('deleted_at', 'null').execute()
# ✅ 匹配 NOT NULL
response = client.table('users').select('*').not_.is_('deleted_at', 'null').execute()
```

### 🔴 .neq() 不包含 NULL 行

```python
# ❌ status 为 NULL 的行也被排除了
response = client.table('users').select('*').neq('status', 'deleted').execute()

# ✅ 要同时包含 NULL 行
response = client.table('users').select('*').or_('status.neq.deleted,status.is.null').execute()
```

### .or_() 必须用 PostgREST 原始字符串语法

```python
# ✅ 逗号分隔，无空格，PostgREST 操作符
.or_('role.eq.admin,role.eq.moderator')
# ✅ IN 列表
.or_('id.in.(1,2,3),status.eq.active')
# ❌ 逗号后加空格可能导致解析异常
.or_('role.eq.admin, role.eq.moderator')
```

### N+1 查询防范

```python
# ❌ 循环中逐条查询（100 个用户 = 101 次数据库往返）
for user in users:
    client.table('orders').select('*').eq('user_id', user['id']).execute()

# ✅ 批量查询（1 次往返）
user_ids = [u['id'] for u in users]
response = client.table('orders').select('*').in_('user_id', user_ids).execute()

# ✅ 嵌套查询（需要外键，1 次往返）
response = client.table('users').select('*, orders(*)').execute()
```

---

## 插入

```python
try:
    response = client.table('users').insert({'name': 'John', 'email': 'john@example.com'}).execute()
    print(response.data)  # 含自动生成的 id
except APIError as e:
    raise Exception(f"插入失败: {e.message}")

# ✅ 批量插入（1 次网络往返），禁止循环单条插入
```

### Upsert（插入或更新）

```python
# ✅ 原子操作，避免 "先查再插/更新" 的竞态条件
try:
    response = client.table('settings').upsert(
        {'user_id': '123', 'key': 'theme', 'value': 'dark'},
        on_conflict='user_id,key'
    ).execute()
except APIError as e:
    raise Exception(f"Upsert 失败: {e.message}")
```

> **前提**：表上必须有唯一约束。幂等添加：
> ```sql
> DO $$ BEGIN
>   ALTER TABLE settings ADD CONSTRAINT settings_user_key_unique UNIQUE (user_id, key);
> EXCEPTION WHEN duplicate_object THEN NULL;
> END $$;
> ```

---

## 更新

```python
try:
    response = client.table('users').update({'name': 'Jane'}).eq('id', 1).execute()
    # RLS 可能导致"成功但 0 行受影响"（返回空 data），需检查 len(response.data) > 0
except APIError as e:
    raise Exception(f"更新失败: {e.message}")
```

### 🔴 不带 filter = 更新全表

```python
# ❌ 更新全表所有行！！
client.table('users').update({'status': 'inactive'}).execute()

# ✅ 必须带 filter
client.table('users').update({'status': 'inactive'}).eq('id', 1).execute()
```

### 🔴 .in_() 传空列表 → 更新全表

```python
ids = []  # 某个查询返回空结果
# ❌ .in_('id', []) → filter 被静默丢弃 → 无条件 update → 改全表！
client.table('orders').update({'status': 'cancelled'}).in_('id', ids).execute()

# ✅ 调用前必须检查列表非空
if ids:
    client.table('orders').update({'status': 'cancelled'}).in_('id', ids).execute()
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

```python
try:
    response = client.table('users').delete().eq('id', 1).execute()
except APIError as e:
    raise Exception(f"删除失败: {e.message}")
```

### 🔴 不带 filter = 删全表

```python
# ❌ 删除整个表所有行！！
client.table('users').delete().execute()

# ✅ 必须带 filter
client.table('users').delete().eq('id', 1).execute()
```

> `.in_()` 传空列表同样危险（同更新），调用前必须检查非空。

---

## 关联查询

> **🔴 嵌套查询需要数据库外键约束，否则报错 `PGRST200`。**
> model.py 中关联字段必须有 `ForeignKey()`，否则先添加外键并执行 `coze-coding-ai db upgrade`。详见 [orm-model-guide.md](./orm-model-guide.md)。

```python
# ✅ model.py 中 Post.user_id 有 ForeignKey("users.id")
try:
    response = client.table('posts').select('*, users(name, email)').execute()
except APIError as e:
    raise Exception(f"关联查询失败: {e.message}")

# ❌ 缺少 ForeignKey() → APIError (PGRST200)
```

无法修改 model 时，用多次查询 + `.in_()` 批量查询 + dict 组装（避免 N+1）。

---

## 聚合 & RPC

```python
# ✅ 统计数量（不加载数据，不受 1000 行上限影响）
try:
    response = client.table('users').select('*', count='exact').execute()
    print(response.count)
except APIError as e:
    raise Exception(f"统计失败: {e.message}")

# ❌ 不要用 len(response.data) 统计（受 1000 行截断影响）

# ✅ RPC 调用必须捕获异常
try:
    response = client.rpc('calculate_total', {'table': 'orders'}).execute()
except APIError as e:
    raise Exception(f"RPC 调用失败: {e.message}")
```

> 简单计数/状态更新优先用应用层 SDK。事务中不要做外部调用（支付 API 等），持锁时间长会阻塞其他查询。

---

## 分页

### 🔴 默认 limit 1000 行

Supabase SDK 默认最多返回 1000 行，超过部分**被静默截断，不报错**。可能超过 1000 行的查询必须分页或显式 `.limit()`。

```python
def fetch_all(table_name: str, page_size: int = 1000):
    all_data, offset = [], 0
    while True:
        try:
            response = client.table(table_name).select('*').order('id').range(offset, offset + page_size - 1).execute()
        except APIError as e:
            raise Exception(f"分页查询失败: {e.message}")
        if not response.data:
            break
        all_data.extend(response.data)
        if len(response.data) < page_size:
            break
        offset += page_size
    return all_data
```

### OFFSET 分页

> ⚠️ **`.range()` 必须搭配 `.order()` — 没有 order 时并发写入会导致同一行在不同分页中重复出现。**

```python
response = client.table(table_name).select('*').order('id').range(offset, offset + page_size - 1).execute()
```

### 游标分页（大数据量翻页）

`.range()` 底层用 OFFSET，越翻越慢。面向用户的大表分页用游标分页：

```python
# ✅ 恒定 O(1) 速度
response = client.table('posts').select('id, title, created_at') \
    .order('created_at', desc=True) \
    .lt('created_at', last_seen_created_at) \
    .limit(20).execute()
```

> 管理后台 / 导出用 `.range()`。面向用户的无限滚动用游标分页。

---

## 全文搜索（替代 ilike）

`.ilike('col', '%keyword%')` 无法使用索引，全表扫描。用 `.text_search()`，性能提升 100x+。

**第一步**：通过 `execute_sql` 添加 tsvector 列 + GIN 索引：

```sql
ALTER TABLE articles ADD COLUMN IF NOT EXISTS fts tsvector
  GENERATED ALWAYS AS (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))) STORED;
CREATE INDEX IF NOT EXISTS articles_fts_idx ON articles USING gin (fts);
```

**第二步**：SDK 查询：

```python
try:
    response = client.table('articles').select('id, title, created_at') \
        .text_search('fts', 'supabase & database', options={"type": "websearch"}).execute()
except APIError as e:
    raise Exception(f"搜索失败: {e.message}")

# ❌ 不要用 ilike 做搜索
```

> 默认 `english` parser 对中文支持有限，中文搜索需要 pgroonga 等扩展。

---

## 事务处理

```python
try:
    response = client.rpc('transfer_funds', {
        'from_account': 1, 'to_account': 2, 'amount': 100
    }).execute()
except APIError as e:
    raise Exception(f"事务执行失败: {e.message}")
```

---

## 结果获取

`response.data` 的静态类型是 `Any`。实际运行时：多行查询返回 `list[dict]`，单行查询返回 `dict`。直接用即可，不需要额外类型转换。

```python
# 多行查询 → response.data 是 list[dict[str, Any]]
try:
    response = client.table('users').select('id, name').eq('status', 'active').execute()
except APIError as e:
    raise Exception(f"查询失败: {e.message}")

for record in response.data:
    print(record['name'])      # 直接用 key 访问
    print(record.get('email')) # 或 .get() 安全访问

# 单行查询 → response 可能是 None，response.data 是 dict[str, Any]
try:
    response = client.table('users').select('*').eq('id', user_id).maybe_single().execute()
except APIError as e:
    raise Exception(f"查询失败: {e.message}")

if response is None:
    return None
print(response.data['name'])

# 插入/更新后获取返回数据
try:
    response = client.table('users').insert({'name': 'John'}).execute()
except APIError as e:
    raise Exception(f"插入失败: {e.message}")

new_id = response.data[0]['id']  # 插入返回的是 list[dict]
```

---

## 常见错误码

| 错误码 | 含义 | 解决方法 |
|--------|------|---------|
| `PGRST116` | `.single()` 返回 0 行或多行 | 改用 `.maybe_single()` 并处理 None |
| `PGRST200` | 嵌套查询找不到表关系 | model.py 中给关联字段加 `ForeignKey()`，然后 `db upgrade` |
| `23505` | 唯一约束冲突（重复数据） | 改用 `.upsert()` 或先查询再插入 |
| `42501` | RLS 权限不足 | 检查 RLS 策略是否配置，场景是否匹配 Auth 状态 |
| `42P01` | 表不存在 | 检查表名拼写，确认已执行 `db upgrade` |
