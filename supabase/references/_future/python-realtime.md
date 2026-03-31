# 实时订阅（Realtime）

> ⚠️ **注意**: Python SDK 的 Realtime 功能需要使用**异步客户端**，与普通客户端不同。

## 订阅数据变更

```python
import asyncio
from supabase import acreate_client
from supabase_client import get_supabase_credentials

async def main():
    url, anon_key = get_supabase_credentials()
    client = await acreate_client(url, anon_key)
    
    def handle_change(payload):
        print(f"收到变更: {payload}")
    
    channel = client.channel('db-changes')
    channel.on_postgres_changes(
        event='*',
        schema='public',
        table='users',
        callback=handle_change
    ).subscribe()
    
    await asyncio.sleep(60)
    
    await client.remove_channel(channel)

asyncio.run(main())
```

---

## 监听特定事件

```python
channel.on_postgres_changes(
    event='INSERT',
    schema='public',
    table='users',
    callback=lambda payload: print('新记录:', payload)
).subscribe()
```

---

## 过滤特定行

```python
channel.on_postgres_changes(
    event='UPDATE',
    schema='public',
    table='users',
    filter='id=eq.1',
    callback=lambda payload: print('用户1更新:', payload)
).subscribe()
```

---

## 取消订阅

```python
await client.remove_channel(channel)
```
