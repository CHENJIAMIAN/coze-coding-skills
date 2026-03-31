# 登录态验证（业务接口鉴权，身份认证）

业务接口分两类：**需要登录态**和**不需要登录态**。
🔴🔴🔴 需要身份认证的接口【重要强调，必须遵循】：
- 所有需要身份认证的接口，必须在请求 Header 中携带 `x-session` 字段，值为当前登录用户的 session token。
- 对应的数据表比如开启RLS策略
- 后端接口的数据操作必须显示带上user_id的过滤条件

---

## 前端：携带 token 发请求

登录成功后，调用需要鉴权的接口时，**必须在请求 Header 中携带 token**：

> ⚠️ **key 为** **`x-session`**（不是 `Authorization`）
>
> ⚠️注意：token不要做缓存，每次请求都从 Supabase client获取当前的session 再获取token

```typescript
'use client';
import { getSupabaseBrowserClientWithRetry } from '@/lib/supabase-browser';

async function callAuthenticatedApi(path: string, options?: RequestInit) {
  const supabase = await getSupabaseBrowserClientWithRetry();
  const { data: { session } } = await supabase.auth.getSession();

  if (!session) {
    // 未登录，跳转到登录页
    window.location.href = '/login';
    return;
  }

  return fetch(path, {
    ...options,
    headers: {
      ...(options?.headers || {}),
      'x-session': session.access_token,
    },
  });
}
```

---

## 服务端（TypeScript / Next.js）：验证登录态

**不需要登录的接口**：

```typescript
// app/api/public-data/route.ts
import { NextResponse } from 'next/server';
import { getSupabaseClient } from '@/storage/database/supabase-client';

export async function GET() {
  const client = getSupabaseClient();
  const { data, error } = await client.from('public_posts').select('*');
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json(data);
}
```

**需要登录的接口**：

```typescript
// app/api/my-records/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { getSupabaseClient } from '@/storage/database/supabase-client';

export async function GET(req: NextRequest) {
  const token = req.headers.get('x-session');

  if (!token) {
    return NextResponse.json({ error: '请先登录' }, { status: 401 });
  }

  const client = getSupabaseClient(token);
  const { data: { user }, error: authError } = await client.auth.getUser();

  if (authError || !user) {
    return NextResponse.json({ error: '认证失败' }, { status: 401 });
  }

  const { data, error } = await client.from('records').select('*');
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json(data);
}
```

---

## 服务端（Python）：验证登录态

**需要登录的接口**：

```python
from storage.database.supabase_client import get_supabase_client

def get_current_user(request):
    token = request.headers.get('x-session')
    if not token:
        raise Exception('请先登录')

    client = get_supabase_client(token)
    response = client.auth.get_user()
    if not response.user:
        raise Exception('认证失败')

    return response.user
```

## 服务端（Python）：验证登录态

## 检查清单（每次生成完登录模块时，进行检查）
🔴🔴🔴 需要身份认证的接口【重要强调，必须遵循】：
- 所有需要身份认证的接口，必须在请求 Header 中携带 `x-session` 字段，值为当前登录用户的 session token。
- 对应的数据表比如开启RLS策略
- 后端接口的数据操作必须显示带上user_id的过滤条件