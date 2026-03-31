# 文件存储（Storage）

> Initialize `client` per Step 3 in [SKILL.md](../../SKILL.md).

## 上传文件

### 上传单个文件
```python
from pathlib import Path

file_path = Path('avatar.png')
file_data = file_path.read_bytes()

response = client.storage.from_('avatars').upload('user1.png', file_data)
```

### 上传并设置元数据
```python
file_options = {
    'content-type': 'image/png',
    'cache-control': '3600'
}
response = client.storage.from_('avatars').upload('user1.png', file_data, file_options)
```

---

## 下载文件

### 下载到内存
```python
response = client.storage.from_('avatars').download('user1.png')
file_data = response
```

### 下载到本地文件
```python
response = client.storage.from_('avatars').download('user1.png')
Path('downloaded-avatar.png').write_bytes(response)
```

---

## 获取文件 URL

### 获取公开 URL
```python
url = client.storage.from_('avatars').get_public_url('user1.png')
print(url)
```

### 获取签名 URL（临时访问）
```python
url = client.storage.from_('private-files').create_signed_url(
    'secret.pdf',
    expires_in=3600  # 1 小时
)
```

---

## 删除文件

### 删除单个文件
```python
response = client.storage.from_('avatars').remove(['user1.png'])
```

### 批量删除
```python
response = client.storage.from_('avatars').remove([
    'user1.png',
    'user2.png',
    'user3.png'
])
```

---

## 列出文件

### 列出所有文件
```python
response = client.storage.from_('avatars').list()
for file in response:
    print(file['name'])
```

### 列出指定路径下的文件
```python
response = client.storage.from_('avatars').list(path='user-photos')
```

### 带分页参数
```python
response = client.storage.from_('avatars').list(
    path='',
    options={'limit': 10, 'offset': 0}
)
```
