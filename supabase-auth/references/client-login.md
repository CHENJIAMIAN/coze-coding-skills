# 前端登录能力实现

> 💡 **重要提示**：Supabase Auth 使用内置的 `auth.users` 表管理用户，**无需额外新建用户表**
>
>    登录相关操作，直接使用supabase的sdk即可，业务接口如果需要进行登录态的身份认证，则需要在header的x-session这个key中传supabase登录后的access\_token信息。
>
> 💡 **重要提示**：supabase-auth实现代码前必须确保supabase这个skill中的规范！！
> 
>    **重要提示**：集成登录能力后，必须执行相关检查清单！！！

***

## 前置检查，必须先执行（禁止跳过！！）
1、 在读以下代码前，先确保加载了supabase的skill，并且加载了其相关代码编写规范
2、 先根据supabase的skill，生成对应的客户端代码，包括supabase-client.ts文件等
3、 然后确保@supabase/supabase-js的安装，如果没有安装，需要重新安装并重启服务！！！

## 客户端配置（根据以下的内容进行代码编写）

使用 Auth 功能可以参考以下的代码（如果找不到，就尝试在/skills/public/prod/supabase-auth/这个路径找！）：

/references/typescript/supabase-browser.ts（必须实现Retry的逻辑！！）

/references/typescript/supabase-config-inject.tsx

/references/typescript/supabase-config-route.ts（【重要提示】：前端必须用这种方式调用后端接口获取supabase url和anonKey！！）

在 `layout.tsx` 中注入配置（**不要遗漏这一步！**）：

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
>
> - `SupabaseConfigProvider` 是客户端组件，通过 fetch 从 API 获取配置
> - `api/supabase-config/route.ts` 是服务端 API，安全地读取环境变量
> - 使用 `useSupabaseConfig()` Hook 获取配置状态

**浏览器端 vs 服务端对比：**

| 特性       | 浏览器端             | 服务端    |
| :------- | :--------------- | :----- |
| 实例模式     | 单例               | 每请求新建  |
| Token 管理 | 自动（localStorage） | 手动传入   |
| Token 刷新 | 自动               | 不需要    |
| 适用场景     | 前端页面登录/注册        | API 路由 |

***

## 浏览器端或移动端前端

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
import { getSupabaseBrowserClientWithRetry } from '@/lib/supabase-browser';

const supabase = await getSupabaseBrowserClientWithRetry();
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

<br />

## 检查清单（每次生成完登录模块时，进行检查，以下都是很重要的检查！！！）

- 根据以上代码示例生成的代码，必须进行自检确保代码能正常运行！！！
- 再次检查，前端获取url和anonKey是通过后端接口获取的！！！
- 集成了登录模块能力后，必须检查一下现有的接口是否需要身份认证，如果需要的话根据verify-session.md接入身份认证能力！！！
- 在生成移动端app应用时，经常出现问题，登录成功后仍然在登录页，这个问题需要再次进行检查！！！
  - 问题原因是：登录成功后，虽然 Supabase 会通过 onAuthStateChange 更新 session，但这个更新是异步的。当 router.replace('/') 执行时，isAuthenticated 还没更新为 true，导致路由守卫检测到 "未登录" 又把用户重定向回登录页。
    修复方案：在 verifyOtp、signInWithEmail、signUpWithEmail 成功后，立即手动更新 session 和 user 状态，确保 isAuthenticated 同步变为 true
- 在生成移动端app应用时，经常出现问题，退出登录后未到登录页，这个问题需要再次进行检查，并且同时检查是否清除客户端的身份信息！！！
