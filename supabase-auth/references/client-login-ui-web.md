# WEB端前端生成登录模块UI规范

根据 Supabase Auth 配置生成或修改WEB端用户登录模块。集成登录能力后，必须执行相关检查清单！！！

***

## 强制工作流程

1. 执行 `npx coze-coding-ai supabase auth get-config-v2 -H "x-tt-env: ppe_auth_supabase_0324" -H "x-use-ppe: 1"`获取当前配置
2. 根据配置决定开启的登录方式：
   - `email_config.external_email_enabled = true` → 包含邮箱密码登录
   - `phone_config.external_phone_enabled = true` → 包含手机号验证码登录
   - `icon_url`→ 应用图标
   - `name` → 应用名称
3. 检查项目是否已有登录页面，**有则做增量修改，无则新建，做增量修改时按照原来的UI风格**
   1. 若登录页没有显示应用图标，则在最上方水平居中显示icon\_url的图标(必须用得到的icon\_url这个值作为静态资源显示在登录页)。重要！！检查应用图标的ui组件，会不会报这个错误。需要解决！**hostname "coze-coding-project.tos.coze.site" is not configured under images in your `next.config.js`。**`next.config.ts` 修改后需要重启开发服务器才能生效，需要你重启下开发！
   2. 若登录页没有显示应用名称，则在icon\_url下水平居中显示应用名称
4. 优先展示手机号登录方式选择tab（如果都有的话），手机号、邮箱
5. 选了手机号登录，就没有单独的注册入口
6. 选了邮箱登录，必须独立的注册入口

***

## 登录页面生成规范

### 整体布局规范

- 居中显示，从上到下依次是应用图标，应用名称，实际登录方式选择页

* 展示应用图标（`config.icon_url`）和应用名称（`config.name`），应用图标展示在整体UI的上面水平居中，应用名称在图标下面水平居中。应用图标千万注意Next.js 的 Image 组件需要配置允许的外部图片域名，否则会报错！！！
* 图标和应用名称：若已有登录页但缺少此信息，补充上去，始终与 Auth 配置保持一致
* 在实际登录方式选择页中，如果有多种登录方式，手机号登录方式的tab需要在邮箱登录方式tab之前，优先显示手机号登录方式tab

### 手机号验证码登录规范

> ⚠️ **区号限制**：只能使用 `+86`（火山短信服务仅支持中国大陆）

- **必须显示区号** **`+86`**，区号不可修改（写死 `+86`）
- 发送验证码时手机号拼接区号：`+86${phone}`
- 倒计时：发送验证码后显示 60 秒倒计时，倒计时中禁止重复发送
- **登录注册不区分**（同一个界面，验证码正确即登录或自动注册）
- 前端调用：
  ```typescript
  // 发送验证码（手机号必须带区号）
  await supabase.auth.signInWithOtp({ phone: '+86' + phoneNumber })

  // 验证验证码
  await supabase.auth.verifyOtp({
    phone: '+86' + phoneNumber,
    token: otpCode,
    type: 'sms'
  })
  ```
- ui参考示例（手机号和邮箱登录方式同时展示的情况）：
  - 登录/注册：/references/typescript/phone-login.png

### 邮箱密码登录规范

- **注册和登录必须分开**（两个独立页面或 Tab）
- 注册页：邮件 + 密码 + 确认密码
  - 注册入口在邮箱的登录页面的登录按钮下方再加一个字符串（如"还没有账号？去注册"）形式的跳转，注册页面中在注册按钮下方再加一个字符串（如"已有账号？去登录"）形式的跳转
  - 如果Auth配置 mailer_auto_confirm: true，邮箱注册是自动确认的，不需要验证邮件。注册成功后应该直接登录跳转到首页。
- 登录页：邮件 + 密码
- 前端调用：
  - 注册：`supabase.auth.signUp({ email, password })`
  - 登录：`supabase.auth.signInWithPassword({ email, password })`
- ui参考示例（手机号和邮箱登录方式同时展示的情况）：
  - 登录：/references/typescript/email-login.png
  - 注册：/references/typescript/email-signup.png

### 对已有登录页的增量修改规范

- **邮箱、手机号登录方式只检查开关**：`external_email_enabled` / `external_phone_enabled`，不改变已有 UI 风格
- **图标和应用名称**：若已有登录页缺少，补充上去；若已有但不同，更新为 Auth 配置中的最新值
- **尽量保持已有 UI 的视觉风格**，做最小化改动

***

## 登录后能力

### 用户信息页

用户登录后，应提供用户信息的查看与编辑功能：

- **展示信息**：用户名（`user_metadata.full_name`）、Email（`user.email`）、手机号（`user.phone`）
- **修改 Email**：需要 SMTP 已配置，改邮箱会发送确认邮件（这个功能先不主动对用户透出）
  ```typescript
  await supabase.auth.updateUser({ email: 'new@example.com' })
  ```
- **修改密码**：（这个功能先不主动对用户透出）
  ```typescript
  await supabase.auth.updateUser({ password: 'new_password' })
  ```
- **修改用户名等元数据**：（这个功能先不主动对用户透出）
  ```typescript
  await supabase.auth.updateUser({ data: { full_name: 'New Name' } })
  ```

### 登出能力

- 登录后的应用页面**必须提供登出入口**（如右上角头像菜单、设置页等）
- 登出时需要弹窗二次确认才能执行登出操作，登出后，应用必须跳转到登录页，清除所有登录状态（如本地存储的 token、用户信息等）
- 前端调用：
  ```typescript
  await supabase.auth.signOut()
  // 登出后跳转到登录页
  router.push('/login')
  ```

## 检查清单（每次生成完登录模块时，进行检查）

- 根据以上代码示例生成的代码，必须进行自检确保代码能正常运行！！
- 尤其注意检查：检查应用图标的ui组件，会不会报这个错误。需要解决！**hostname "coze-coding-project.tos.coze.site" is not configured under images in your `next.config.js`，**`next.config.ts` 修改后需要重启开发服务器才能生效，需要你重启下开发
- 检查登出后是否成功清除所有登录状态并且跳转到登录页
- 再次检查应用图标是否正确显示了
- 集成了登录模块能力后，检查一下现有的接口是否需要身份认证，如果需要的话根据verify-session.md接入身份认证能力！！！
- 确认登录成功后会切换到首页，而不是登录页！！
- 确认退出登录后会跳转到登录页！！
- 登出成功和登出成功不需要toast提示
- 集成了登录模块能力后，必须检查一下现有的接口是否需要身份认证，如果需要的话根据verify-session.md接入身份认证能力！！！
- 检查倒计时功能是否会影响手机号输入框和验证码输入框，不要每次倒计时都会触发 render() 重新渲染整个页面，导致输入框被清空
