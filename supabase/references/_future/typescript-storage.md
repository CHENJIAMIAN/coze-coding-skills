# 文件存储（Storage）

> Initialize `client` per Step 3 in [SKILL.md](../../SKILL.md).

## 上传文件

### 上传单个文件
```typescript
const { data, error } = await client
  .storage
  .from('avatars')
  .upload('user1.png', fileData, {
    contentType: 'image/png',
    upsert: false
  })
```

### 上传并设置元数据
```typescript
const { data, error } = await client
  .storage
  .from('documents')
  .upload('report.pdf', fileData, {
    contentType: 'application/pdf',
    cacheControl: '3600',
    upsert: true
  })
```

---

## 下载文件

### 下载到内存
```typescript
const { data, error } = await client
  .storage
  .from('avatars')
  .download('user1.png')

if (data) {
  // data 是 ArrayBuffer
}
```

---

## 获取文件 URL

### 获取公开 URL
```typescript
const { data: { publicUrl } } = client
  .storage
  .from('avatars')
  .getPublicUrl('user1.png')

console.log('Public URL:', publicUrl)
```

### 获取签名 URL（临时访问）
```typescript
const { data: { signedUrl } } = await client
  .storage
  .from('private-files')
  .createSignedUrl('secret.pdf', 3600) // 1 小时过期

console.log('Signed URL:', signedUrl)
```

---

## 删除文件

### 删除单个文件
```typescript
const { data, error } = await client
  .storage
  .from('avatars')
  .remove(['user1.png'])
```

### 批量删除
```typescript
const { data, error } = await client
  .storage
  .from('avatars')
  .remove([
    'user1.png',
    'user2.png',
    'user3.png'
  ])
```

---

## 列出文件

### 列出所有文件
```typescript
const { data, error } = await client
  .storage
  .from('avatars')
  .list('', {
    limit: 100,
    offset: 0
  })

if (data) {
  data.forEach(file => {
    console.log(file.name)
  })
}
```

### 带前缀过滤
```typescript
const { data, error } = await client
  .storage
  .from('avatars')
  .list('user-', { limit: 50 })
```
