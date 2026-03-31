# 用户认证（Auth）

> 💡 **重要提示**：Supabase Auth 使用内置的 `auth.users` 表管理用户，**无需额外新建用户表**。

> Initialize `client` per Step 3 in [SKILL.md](../../SKILL.md).

---

## 用户注册

### 邮箱密码注册
```python
client = get_supabase_client()

response = client.auth.sign_up({
    'email': 'user@example.com',
    'password': 'secure_password',
    'options': {
        'data': {
            'full_name': 'John Doe'
        }
    }
})

user = response.user
session = response.session
```

---

## 用户登录

### 邮箱密码登录
```python
client = get_supabase_client()

response = client.auth.sign_in_with_password({
    'email': 'user@example.com',
    'password': 'secure_password'
})

access_token = response.session.access_token
user = response.user
```

---

## 用户登出

```python
client = get_supabase_client(token)
response = client.auth.sign_out()
```

---

## 获取当前用户

```python
client = get_supabase_client(token)
response = client.auth.get_user()
user = response.user
print(user.email)
```

---

## 更新用户信息

### 更新邮箱
```python
client = get_supabase_client(token)
response = client.auth.update_user({
    'email': 'newemail@example.com'
})
```

### 更新密码
```python
client = get_supabase_client(token)
response = client.auth.update_user({
    'password': 'new_secure_password'
})
```

### 更新元数据
```python
client = get_supabase_client(token)
response = client.auth.update_user({
    'data': {
        'full_name': 'John Doe',
        'avatar_url': 'https://example.com/avatar.jpg'
    }
})
```

---

## 密码重置

### 发送重置邮件
```python
client = get_supabase_client()
response = client.auth.reset_password_for_email(
    'user@example.com',
    options={
        'redirect_to': 'https://myapp.com/reset-password'
    }
)
```




