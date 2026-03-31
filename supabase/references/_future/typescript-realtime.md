# 实时订阅（Realtime）

> Initialize `client` per Step 3 in [SKILL.md](../../SKILL.md).

## 监听表变化

### 监听 INSERT 事件
```typescript
const subscription = client
  .channel('users-changes')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'users'
    },
    (payload) => {
      console.log('New user:', payload.new)
    }
  )
  .subscribe()

// 取消订阅
subscription.unsubscribe()
```

---

## 监听所有事件

```typescript
const subscription = client
  .channel('table-changes')
  .on(
    'postgres_changes',
    {
      event: '*',  // INSERT, UPDATE, DELETE
      schema: 'public',
      table: 'users'
    },
    (payload) => {
      if (payload.eventType === 'INSERT') {
        console.log('New:', payload.new)
      } else if (payload.eventType === 'UPDATE') {
        console.log('Updated:', payload.old, '->', payload.new)
      } else if (payload.eventType === 'DELETE') {
        console.log('Deleted:', payload.old)
      }
    }
  )
  .subscribe()
```

---

## 监听特定行

```typescript
const subscription = client
  .channel('user-updates')
  .on(
    'postgres_changes',
    {
      event: 'UPDATE',
      schema: 'public',
      table: 'users',
      filter: 'id=eq.1'
    },
    (payload) => {
      console.log('User updated:', payload.new)
    }
  )
  .subscribe()
```

---

## 取消订阅

```typescript
subscription.unsubscribe()
```
