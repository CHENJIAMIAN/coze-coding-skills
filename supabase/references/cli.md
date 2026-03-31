# CLI 工具详细说明

---

## 通用参数（所有命令可用）

| 参数 | 简写 | 说明 |
|------|------|------|
| `--header` | `-H` | 自定义 HTTP 请求头（格式：`'Key: Value'` 或 `'Key=Value'`，可多次使用） |
| `--verbose` | `-v` | 显示详细的 HTTP 请求和响应日志 |

---

## Edge Functions 管理

### 1. 列出所有函数

**命令**：
```bash
coze-coding-ai supabase func list [options]
```

**参数**：无（仅通用参数）

**返回**：
```json
[
  {
    "id": "string",
    "slug": "string",
    "name": "string",
    "status": "string",
    "version": 1,
    "verify_jwt": true,
    "entrypoint_path": "string",
    "created_at": "string",
    "updated_at": "string"
  }
]
```

**函数状态说明**：
- `active`: 活跃状态，函数正常运行
- `inactive`: 非活跃状态，函数已停用
- `deploying`: 部署中
- `failed`: 部署失败

**示例**：
```bash
# 列出所有函数
coze-coding-ai supabase func list

# 显示详细日志
coze-coding-ai supabase func list -v
```

---

### 2. 获取函数详情

**命令**：
```bash
coze-coding-ai supabase func get <SLUG> [options]
```

**参数**：
| 参数 | 说明 |
|------|------|
| `SLUG` | 函数标识符，即函数的唯一名称（可通过 `func list` 查看） |

**返回**：
```json
{
  "function": {
    "id": "string",
    "slug": "string",
    "name": "string",
    "status": "string",
    "version": 1
  },
  "files": [
    {
      "name": "string",
      "content": "string"
    }
  ]
}
```

**示例**：
```bash
# 获取函数详情
coze-coding-ai supabase func get hello-world
```

---

### 3. 部署函数

**命令**：
```bash
coze-coding-ai supabase func deploy <SLUG> [options]
```

**参数**：
| 参数 | 简写 | 说明 | 必需 |
|------|------|------|------|
| `SLUG` | - | 函数标识符，只能包含小写字母、数字和连字符 | ✅ |
| `--code` | `-c` | 函数代码字符串（单文件），与 `--file` 二选一 | ❌ |
| `--file` | `-f` | 文件名和内容对（多文件），格式：`--file <文件名> <内容>`，可多次使用 | ❌ |
| `--name` | `-n` | 函数显示名称，用于在控制台中展示 | ❌ |
| `--entrypoint` | `-e` | 入口文件名称（多文件部署时必需） | ❌ |
| `--verify-jwt` / `--no-verify-jwt` | - | 启用/禁用 JWT 验证 | ❌ |

**说明**：
- 单文件部署：使用 `--code` 参数
- 多文件部署：使用 `--file` 参数，配合 `--entrypoint` 指定入口文件
- `--verify-jwt`：启用后，调用函数需要携带有效的 JWT token
- 如果函数已存在则更新，不存在则创建新函数

**返回**：
```json
{
  "success": true,
  "slug": "hello-world",
  "version": 2
}
```

**示例**：

**单文件部署**：
```bash
coze-coding-ai supabase func deploy hello-world \
  --code 'Deno.serve(() => new Response("Hello World"))' \
  --name "Hello World" \
  --verify-jwt
```

**多文件部署**：
```bash
coze-coding-ai supabase func deploy my-api \
  --file index.ts 'import { handler } from "./handler.ts"; Deno.serve(handler)' \
  --file handler.ts 'export const handler = () => new Response("API Response")' \
  --entrypoint index.ts \
  --no-verify-jwt
```

---

### 4. 删除函数

**命令**：
```bash
coze-coding-ai supabase func delete <SLUG> [options]
```

**参数**：
| 参数 | 说明 |
|------|------|
| `SLUG` | 函数标识符（可通过 `func list` 查看） |

**返回**：
```json
{
  "success": true
}
```

**⚠️ 警告**：此操作不可逆，删除后函数将无法恢复。

**示例**：
```bash
# 删除函数
coze-coding-ai supabase func delete hello-world
```

---

## 最佳实践

### Edge Functions

1. **合理设置 JWT 验证**：公开的 API 可以禁用 JWT 验证，敏感操作必须启用
2. **多文件部署结构**：复杂项目建议使用多文件结构，便于维护
3. **函数命名规范**：使用 kebab-case（如 `user-profile-api`）

---

## 注意事项

1. **删除操作**：删除函数是不可逆的，请谨慎操作
2. **函数命名**：slug 只能包含小写字母、数字和连字符
3. **错误处理**：CLI 命令会返回错误信息，遇到错误请根据提示检查参数
