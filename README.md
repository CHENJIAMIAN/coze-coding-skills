# 扣子编程 Skills

扣子编程（Coze Coding）Skills 集合 - 一组可复用的开发技能模块，用于快速构建各类应用功能。

## 概述

本项目包含多个独立的 Skill 模块，每个模块提供特定领域的能力，支持 Python 和 TypeScript 双语言 SDK。这些 Skills 基于 `coze-coding-dev-sdk` 构建，可用于扣子平台的应用开发。

## Skills 列表

### 核心能力

| Skill | 描述 |
|-------|------|
| [llm](llm/) | 大语言模型集成，支持文本生成、对话交互、意图识别、多模态理解（图片/视频），支持豆包、DeepSeek、Kimi 等模型 |
| [database](database/) | PostgreSQL 数据库集成，支持结构化数据存储、CRUD 操作、Drizzle ORM |
| [supabase](supabase/) | Supabase 开发指南，包含数据库、认证、存储、Edge Functions、RLS 策略 |
| [supabase-auth](supabase-auth/) | Supabase 认证模块，支持邮箱登录、手机登录、会话管理 |
| [storage](storage/) | 对象存储能力，用于文件上传、下载、管理 |
| [web-search](web-search/) | 网络搜索能力，用于获取实时信息 |

### 媒体处理

| Skill | 描述 |
|-------|------|
| [audio](audio/) | 音频处理能力，包括 TTS（文本转语音）和 ASR（语音识别） |
| [image-generation](image-generation/) | 图像生成能力 |
| [video-generation](video-generation/) | 视频生成能力 |
| [video-edit](video-edit/) | 视频编辑能力 |
| [embedding](embedding/) | 向量嵌入能力，用于语义搜索和相似度计算 |

### 前端与设计

| Skill | 描述 |
|-------|------|
| [frontend-design](frontend-design/) | 前端界面设计，生成高质量、独特风格的 UI |
| [shadcn-web-base-theme](shadcn-web-base-theme/) | shadcn/ui 基础主题配置 |
| [ui-design-ref](ui-design-ref/) | UI 设计参考 |
| [ui-ux-pro-max](ui-ux-pro-max/) | 专业 UI/UX 设计 |
| [design-style-thinking](design-style-thinking/) | 设计风格思维指南 |
| [vercel-react-best-practices](vercel-react-best-practices/) | Vercel React 最佳实践 |
| [vercel-composition-patterns](vercel-composition-patterns/) | Vercel 组合模式 |
| [web-design-guidelines](web-design-guidelines/) | Web 设计指南 |

### 集成与通信

| Skill | 描述 |
|-------|------|
| [feishu-base](feishu-base/) | 飞书基础集成 |
| [feishu-message](feishu-message/) | 飞书消息推送 |
| [email](email/) | 邮件发送能力 |
| [wechat-bot](wechat-bot/) | 微信机器人 |
| [wechat-official-account](wechat-official-account/) | 微信公众号 |
| [websocket-guide](websocket-guide/) | WebSocket 通信 |
| [webrtc-best-practice](webrtc-best-practice/) | WebRTC 最佳实践 |

### 工具与实用程序

| Skill | 描述 |
|-------|------|
| [fetch-url](fetch-url/) | URL 抓取与内容提取 |
| [document-generation](document-generation/) | 文档生成能力 |
| [pptx-generation](pptx-generation/) | PPTX 演示文稿生成 |
| [knowledge](knowledge/) | 知识库管理 |
| [expo-advanced](expo-advanced/) | Expo 高级功能（音频、文件上传、瀑布流等） |
| [miniapp-upload-asr](miniapp-upload-asr/) | 小程序上传与语音识别 |
| [volcano-ark](volcano-ark/) | 火山方舟集成 |

## 快速开始

### 前置要求

- Node.js >= 18
- Python >= 3.9（如使用 Python SDK）
- pnpm 包管理器

### 安装

```bash
pnpm install
```

### 使用

每个 Skill 模块都包含 `SKILL.md` 文件，描述了该技能的用途和使用方法。详细的使用指南请参考各 Skill 目录下的 `python/README.md` 或 `typescript/README.md`。

```bash
# 查看某个 Skill 的详细说明
cat llm/SKILL.md

# 查看 TypeScript SDK 使用指南
cat llm/typescript/README.md

# 查看 Python SDK 使用指南
cat llm/python/README.md
```

## 项目结构

```
.
├── llm/                    # 大语言模型
├── database/               # 数据库
├── supabase/               # Supabase
├── supabase-auth/          # Supabase 认证
├── audio/                  # 音频处理
├── image-generation/       # 图像生成
├── video-generation/       # 视频生成
├── storage/                # 对象存储
├── web-search/             # 网络搜索
├── frontend-design/        # 前端设计
├── feishu-base/            # 飞书集成
├── email/                  # 邮件
├── ...                     # 其他 Skills
```

## 许可证

本项目采用 MIT 许可证（部分 Skill 可能有独立的许可证，详见各目录）。

## 贡献

欢迎提交 Issue 和 Pull Request！
