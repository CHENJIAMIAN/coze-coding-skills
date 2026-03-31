# 用户认证（Auth）

> 💡 **重要提示**：Supabase Auth 使用内置的 `auth.users` 表管理用户，**无需额外新建用户表**。

---

## 客户端配置

使用 Auth 功能需要配置浏览器端客户端，复制以下 4 个文件到用户项目：

```bash
cp /skills/public/prod/supabase/references/typescript/supabase-client.ts $([ -d "$WORKSPACE_PATH/server" ] && echo "$WORKSPACE_PATH/server" || echo "$WORKSPACE_PATH")/src/storage/database/supabase-client.ts
[ -d "$WORKSPACE_PATH/src/lib" ] && cp /skills/public/prod/supabase/references/typescript/supabase-browser.ts $WORKSPACE_PATH/src/lib/supabase-browser.ts
[ -d "$WORKSPACE_PATH/src/lib" ] && cp /skills/public/prod/supabase/references/typescript/supabase-config-inject.tsx $WORKSPACE_PATH/src/lib/supabase-config-inject.tsx
[ -d "$WORKSPACE_PATH/src/app/api" ] && mkdir -p $WORKSPACE_PATH/src/app/api/supabase-config && cp /skills/public/prod/supabase/references/typescript/supabase-config-route.ts $WORKSPACE_PATH/src/app/api/supabase-config/route.ts
```

然后在 `layout.tsx` 中注入配置（**不要遗漏这一步！**）：

```tsx
import { SupabaseConfigProvider } from '@/lib/supabase-config-inject';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <SupabaseConfigProvider>
          {children}
        </SupabaseConfigProvider>
      </body>
    </html>
  );
}
```

> 💡 **架构说明**：配置通过 API 路由动态获取，前后端代码分离。
> - `SupabaseConfigProvider` 是客户端组件，通过 fetch 从 API 获取配置
> - `api/supabase-config/route.ts` 是服务端 API，安全地读取环境变量
> - 使用 `useSupabaseConfig()` Hook 获取配置状态

**浏览器端 vs 服务端对比：**

| 特性 | 浏览器端 | 服务端 |
|------|----------|--------|
| 实例模式 | 单例 | 每请求新建 |
| Token 管理 | 自动（localStorage） | 手动传入 |
| Token 刷新 | 自动 | 不需要 |
| 适用场景 | 前端页面登录/注册 | API 路由 |

---

## 浏览器端

> ⚠️ **配置加载是异步的**：配置通过 API 动态获取，在组件首次渲染时可能还未就绪。
>
> ```typescript
> // ❌ 错误：直接调用（配置可能还没加载完）
> export default function LoginPage() {
>   const supabase = getSupabaseBrowserClient(); // 可能报错！
> }
>
> // ✅ 方法 1：使用 useSupabaseConfig Hook（推荐）
> import { useSupabaseConfig } from '@/lib/supabase-config-inject';
> import { getSupabaseBrowserClient } from '@/lib/supabase-browser';
>
> export default function LoginPage() {
>   const { isLoading, error } = useSupabaseConfig();
>
>   if (isLoading) return <div>加载中...</div>;
>   if (error) return <div>配置加载失败</div>;
>
>   const handleLogin = async () => {
>     const supabase = getSupabaseBrowserClient(); // 配置已就绪，安全调用
>     const { data, error } = await supabase.auth.signInWithPassword({...});
>   };
>
>   return <button onClick={handleLogin}>登录</button>;
> }
>
> // ✅ 方法 2：使用异步版本
> import { getSupabaseBrowserClientAsync } from '@/lib/supabase-browser';
>
> export default function LoginPage() {
>   const handleLogin = async () => {
>     const supabase = await getSupabaseBrowserClientAsync(); // 自动等待配置就绪
>     const { data, error } = await supabase.auth.signInWithPassword({...});
>   };
> }
> ```

### 用户注册

```typescript
'use client';
import { getSupabaseBrowserClient } from '@/lib/supabase-browser';

const supabase = getSupabaseBrowserClient();

const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure_password',
  options: {
    data: {
      full_name: 'John Doe',
    }
  }
})
```

### 用户登录

```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secure_password'
})

if (data.session) {
  console.log('登录成功，token:', data.session.access_token)
}
```

### 用户登出

```typescript
const { error } = await supabase.auth.signOut()
```

### 获取当前用户

```typescript
const { data: { user } } = await supabase.auth.getUser()
```

### 更新用户信息

```typescript
const { data, error } = await supabase.auth.updateUser({
  data: {
    full_name: 'New Name',
  }
})
```

### 密码重置

```typescript
const { error } = await supabase.auth.resetPasswordForEmail(
  'user@example.com',
  { redirectTo: 'https://myapp.com/reset-password' }
)
```

---

## 前端调用需要登录的 API

登录后，调用需要认证的服务端接口时，需要在请求头中携带 token：

```typescript
'use client';
import { getSupabaseBrowserClient } from '@/lib/supabase-browser';

const supabase = getSupabaseBrowserClient();

async function fetchMyRecords() {
  const { data: { session } } = await supabase.auth.getSession();
  
  if (!session) {
    console.log('用户未登录');
    return;
  }

  const response = await fetch('/api/my-records', {
    headers: {
      'Authorization': `Bearer ${session.access_token}`,
    },
  });

  return response.json();
}
```

---

## 服务端 API 路由

### 不需要登录的接口

公开接口，任何人都可以访问：

```typescript
// app/api/public-data/route.ts
import { NextResponse } from 'next/server';
import { getSupabaseClient } from '@/storage/database/supabase-client';

export async function GET() {
  const client = getSupabaseClient();

  const { data, error } = await client.from('public_posts').select('*');

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json(data);
}
```

### 需要登录的接口

需要验证用户身份的接口：

```typescript
// app/api/my-records/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { getSupabaseClient } from '@/storage/database/supabase-client';

export async function GET(req: NextRequest) {
  const token = req.headers.get('authorization')?.split(' ')[1];

  if (!token) {
    return NextResponse.json({ error: '请先登录' }, { status: 401 });
  }

  const client = getSupabaseClient(token);

  const { data: { user }, error: authError } = await client.auth.getUser();
  if (authError || !user) {
    return NextResponse.json({ error: '认证失败' }, { status: 401 });
  }

  // RLS 策略会自动过滤，只返回当前用户的数据（配置方法见 rls.md）
  const { data, error } = await client.from('records').select('*');

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json(data);
}
```
