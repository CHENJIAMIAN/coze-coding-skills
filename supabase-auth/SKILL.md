---
name: supabase-auth
description: 当用户需要集成用户登录能力，例如：处理登录/注册/登出、Auth 配置管理、登录页面生成、登录态验证等用户身份认证相关需求时加载。适用于：配置邮箱或手机号登录方式、生成或修改登录页面 UI、获取 Supabase URL/AnonKey、实现需要登录态的业务接口鉴权。
dependencies:
- supabase
---

# Supabase Auth 登录能力指南

> 🔴🔴🔴 **【最重要】开始前必读**：在生成或修改任何登录相关代码之前，**必须先执行** **`npx coze-coding-ai supabase auth get-config-v2 -H "x-tt-env: ppe_auth_supabase_0324" -H "x-use-ppe: 1"`获取当前 Auth 配置**，根据配置决定开启哪些登录方式，然后根据当前项目类型（WEB端或移动端APP）拉取对应的登录模块 UI 规范文档实现UI。生成登录登录后，必须执行相关检查清单！！！

> 📌 **依赖说明**：本 Skill 依赖 **supabase** Skill，加载本 Skill 时必须同时加载 supabase Skill。基础的 Supabase 接口调用（如客户端初始化、数据库 CRUD 等）可参考 supabase Skill 中的文档。**但如果两者存在冲突（如 Auth 相关的接口调用方式、Header 约定等），以本 supabase-auth Skill 为准。**

本技能提供完整的用户登录体系支持，涵盖以下四个模块，**请在开发前先用 Read 工具读取对应的参考文档**：

| 模块         | 参考文档                                                           | 说明                                               |
| ---------- | -------------------------------------------------------------- | ------------------------------------------------ |
| Auth 配置管理  | [references/auth-config.md](references/auth-config.md)         | 通过 CLI 查询/更新 Auth 配置（邮箱、手机号开关等）                  |
| 前端登录能力实现   | [references/client-login.md](references/client-login.md)       | 客户端配置、Supabase Auth SDK 调用（注册、登录、登出等）            |
| 登录模块 UI 规范（Web） | [references/client-login-ui-web.md](references/client-login-ui-web.md) | Web端登录页面 UI规范（邮箱密码 + 手机号验证码 + 增量修改）请按照这个规范修改UI |
| 登录模块 UI 规范（App） | [references/client-login-ui-app.md](references/client-login-ui-app.md) | 移动端APP登录页面 UI规范（邮箱密码 + 手机号验证码 + 移动端适配）请按照这个规范修改UI |
| 登录态验证      | [references/verify-session.md](references/verify-session.md)   | 业务接口鉴权，前端携带 x-session，服务端校验 token                |

## 触发场景

当用户请求涉及以下内容时，使用此 Skill：

- 配置或修改登录模块功能，包括邮箱登录、手机号登录开关等
- 根据登录配置生成登录/注册页面、修改已有登录页面、生成登录功能代码（获取 Supabase 连接凭证URL/AnonKey）
- 前后端分离，实现需要校验登录态的业务接口，指导如何进行身份认证

## 注意事项

1. 🔴🔴🔴 【重要】在用auth配置生成登录相关功能之前，必须先确认当前是否已经有了登录模块，以及登录模块是否使用的supabase的auth模块还是用户定制化实现的登录模块，如果是用户定制化实现的，需要要让用户确认是否切换到supabase的auth模块实现，如果做了切换那原有的用户信息都会丢失，这个必须让用户确认
2. 🔴🔴🔴 【重要】如果使用coze-coding-ai supabase auth update-config-v2命令更新auth配置，必须重新用get-config-v2命令查询当前auth配置，再根据查询结果和登录模块 UI 规范重新更新登录模块UI！！
3. **邮箱修改**：修改邮箱依赖 SMTP 配置（这个SMTP配置目前不要透出给用户）
4. **登录态 Header**：key 固定为 `x-session`，前后端必须保持一致，也就是前端在发起后端接口请求时，如果接口是需要身份认证的，需要将supabase登录信息session中的token放到这个`x-session`header的key中，后端需要从这个key中获取token，调用supabase的接口认证用户信息，获取到有效user\_id的等信息
5. **已有登录页**：优先做增量修改，应用icon和应用名称使用auth配置查询的结果，具体参考[references/client-login-ui.md](references/client-login-ui.md)
6. **应用图标**千万注意Next.js 的 Image 组件需要配置允许的外部图片域名，否则会报错！！！
7. **配置优先**：登录方式完全由 Auth 配置决定，未开启的方式不要生成对应代码

