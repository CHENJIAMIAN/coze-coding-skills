# Edge Functions 调用（Python）

> Initialize `client` per Step 3 in [README.md](./README.md).

> ⚠️ `client.functions.invoke()` 失败时抛异常。**必须 `try/except` 捕获并 raise，禁止 `except: pass`。**

```python
# 基础调用
try:
    response = client.functions.invoke('hello-world', invoke_options={'body': {}})
except Exception as e:
    raise Exception(f"Edge Function 调用失败: {e}")

# 带参数
try:
    response = client.functions.invoke('process-data', invoke_options={
        'body': { 'user_id': 123, 'action': 'process' },
        'headers': { 'x-custom-header': 'value' }  # 可选
    })
except Exception as e:
    raise Exception(f"Edge Function 调用失败: {e}")
```

- 部署和管理请使用 CLI 命令，参考 [cli.md](../cli.md)
- 启用 JWT 验证的函数需要客户端已登录或传入有效 token
