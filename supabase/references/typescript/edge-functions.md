# Edge Functions 调用（TypeScript）

> Initialize `client` per Step 3 in [README.md](./README.md).

> ⚠️ `client.functions.invoke()` 返回 `{ data, error }`。**必须检查 error 并 throw，函数不存在时不会抛异常，只返回 error。**

```typescript
// 基础调用
const { data, error } = await client.functions.invoke('hello-world')
if (error) throw new Error(`Edge Function 调用失败: ${error.message}`)

// 带参数
const { data, error } = await client.functions.invoke('process-data', {
  body: { user_id: 123, action: 'process' },
  headers: { 'x-custom-header': 'value' }  // 可选
})
if (error) throw new Error(`Edge Function 调用失败: ${error.message}`)
```

- 部署和管理请使用 CLI 命令，参考 [cli.md](../cli.md)
- 启用 JWT 验证的函数需要客户端已登录或传入有效 token
