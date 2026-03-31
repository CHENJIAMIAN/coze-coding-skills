# Auth 配置管理

注意：🔴🔴🔴 【重要】在用auth配置生成登录相关功能之前，必须先确认当前是否已经有了登录模块，以及登录模块是否使用的supabase的auth模块还是用户定制化实现的登录模块，如果是用户定制化实现的（判断条件是：是否使用了supabase的auth下的users表，通常使用supabase的前端sdk进行登录、注册、退登等操作），需要要让用户确认是否切换到supabase的auth模块实现，如果做了切换那原有的用户信息都会丢失，这个必须让用户确认

沙箱中通过 CLI 命令查询和更新 Supabase Auth 认证配置。

***

## 1. Cli查询当前 Auth 配置
注意：如果没有找到get-config-v2，则需要更新coze-coding-dev-sdk到最新版本

```bash
npx coze-coding-ai supabase auth get-config-v2 -H "x-tt-env: ppe_auth_supabase_0324" -H "x-use-ppe: 1"
```

**返回结构**：

```json
{
  "status": 3,
  "config": {
    "project_id": 12345,
    "icon_url": "https://example.com/icon.png",
    "name": "My App",
    "email_config": {
      "external_email_enabled": true,
      "disable_signup": false,
      "mailer_autoconfirm": false,
      "double_confirm_changes": true,
      "mailer_secure_email_change_enabled": true,
      "mailer_otp_exp": 3600,
      "password_min_length": 8,
      "password_required_characters": "",
      "site_url": "https://myapp.com",
      "smtp_host": "smtp.sendgrid.net",
      "smtp_port": 587,
      "smtp_user": "apikey",
      "smtp_pass": "SG.xxx",
      "smtp_admin_email": "noreply@myapp.com",
      "smtp_sender_name": "My App",
      "smtp_max_frequency": 60
    },
    "phone_config": {
      "external_phone_enabled": true
    }
  }
}
```

**关键字段说明**：

| 字段路径                                         | 含义               |
| -------------------------------------------- | ---------------- |
| `config.name`                                | 应用名称，用于登录页展示     |
| `config.icon_url`                            | 应用图标 URL，用于登录页展示 |
| `config.email_config.external_email_enabled` | 是否启用邮箱密码登录       |
| `config.phone_config.external_phone_enabled` | 是否启用手机号验证码登录     |

> ⚠️ **透出规则**：除了 `external_email_enabled`、`external_phone_enabled`、`name`、`icon_url` 这几个关键开关/展示字段外，SMTP相关配置不要透出给用户，其余配置项（如 SMTP、密码策略、OTP 过期时间等）**不需要主动透出给用户**。邮箱登录和手机号登录本质上都是开关配置，只需关注是否启用即可，当然如果用户非要进行配置email的其余配置信息也可以支持。

***

## 2. 更新 Auth 配置

```bash
npx coze-coding-ai supabase auth update-config-v2  -H "x-tt-env: ppe_auth_supabase_0324" -H "x-use-ppe: 1" [options]
```

**所有可用参数**：

| 参数                                                                               | 说明              | 示例                                     |
| -------------------------------------------------------------------------------- | --------------- | -------------------------------------- |
| `--name`                                                                         | 应用名称            | `"My App"`                             |
| `--site-url`                                                                     | 站点 URL，邮件中的跳转地址 | `https://myapp.com`                    |
| `--enable-signup` / `--disable-signup`                                           | 启用/禁用注册         | `--enable-signup`                      |
| `--external-email-enabled` / `--external-email-disabled`                         | 启用/禁用邮箱登录       | `--external-email-enabled`             |
| `--external-phone-enabled` / `--external-phone-disabled`                         | 启用/禁用手机号登录      | `--external-phone-enabled`             |
| `--mailer-autoconfirm` / `--no-mailer-autoconfirm`                               | 启用/禁用邮箱自动确认     | `--no-mailer-autoconfirm`              |
| `--double-confirm-changes` / `--no-double-confirm-changes`                       | 启用/禁用敏感操作双重确认   | `--double-confirm-changes`             |
| `--mailer-secure-email-change-enabled` / `--mailer-secure-email-change-disabled` | 启用/禁用安全邮箱更改     | `--mailer-secure-email-change-enabled` |
| `--mailer-otp-exp`                                                               | OTP 过期时间（秒）     | `3600`                                 |
| `--password-min-length`                                                          | 密码最小长度          | `8`                                    |
| `--password-required-characters`                                                 | 密码必需字符          | `aA1@`                                 |
| `--smtp-host`                                                                    | SMTP 服务器地址      | `smtp.sendgrid.net`                    |
| `--smtp-port`                                                                    | SMTP 端口         | `587`                                  |
| `--smtp-user`                                                                    | SMTP 用户名        | `apikey`                               |
| `--smtp-pass`                                                                    | SMTP 密码/Key     | `SG.xxx`                               |
| `--smtp-admin-email`                                                             | 发件人邮箱           | `noreply@myapp.com`                    |
| `--smtp-sender-name`                                                             | 发件人名称           | `My App`                               |
| `--smtp-max-frequency`                                                           | 最小发送间隔（秒）       | `60`                                   |

**返回**：

```json
{
  "success": true,
  "should_update_ui": false
}
```

**常用示例**：

```bash
# 启用手机号登录
npx coze-coding-ai supabase auth update-config-v2 --external-phone-enabled

# 启用邮箱登录并配置 SMTP
npx coze-coding-ai supabase auth update-config-v2 \
  --external-email-enabled \
  --smtp-host "smtp.sendgrid.net" \
  --smtp-port 587 \
  --smtp-user "apikey" \
  --smtp-pass "SG.xxx" \
  --smtp-admin-email "noreply@myapp.com" \
  --smtp-sender-name "My App"

# 更新应用名称
npx coze-coding-ai supabase auth update-config-v2 --name "My App"

# 设置密码策略
npx coze-coding-ai supabase auth update-config-v2 \
  --password-min-length 8 \
  --password-required-characters "aA1@"
```

🔴🔴🔴 **【重要】沙箱中通过 CLI 命令更新 Supabase Auth 认证配置后，需要查看**should\_update\_ui的值，如果为true代表需要根据配置重新生成登录页，需要继续进行根据auth_config生成登录页面！
