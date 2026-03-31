---
name: knowledge
description: 当用户需要使用知识库能力时加载，包括文档导入（文本、URL、对象存储 URI）、向量化存储、语义搜索
---

# Knowledge Base 开发指南

本技能提供知识库开发支持，包括 CLI 快速操作和 SDK 代码集成。

## 触发场景

当用户请求涉及以下内容时，使用此 Skill：

- 文档导入（文本、URL、对象存储 URI）
- 语义搜索（向量检索）
- 知识库配置（分块策略、相似度阈值）

## 意图识别与决策流程

**Step 1: 判断操作类型**
- 用户说："导入这个文档"、"搜索关于 xxx 的内容" → **CLI 操作**
- 用户说："写一个脚本自动导入"、"把搜索功能集成到 API" → **代码开发**

**Step 2: 选择参考文档**

| 需求 | 参考文档 |
|------|----------|
| CLI 快速操作 | [references/cli.md](references/cli.md) |
| Python SDK 开发 | [references/python/README.md](references/python/README.md) |
| TypeScript SDK 开发 | [references/typescript/README.md](references/typescript/README.md) |

## CLI 命令速查

| 操作类型 | 命令 |
|----------|------|
| 导入文本 | `coze-coding-ai knowledge add --dataset <name> --content <text>` |
| 导入 URL | `coze-coding-ai knowledge add --dataset <name> --url <url>` |
| 语义搜索 | `coze-coding-ai knowledge search --query <text> --top-k <n>` |

详细参数说明请参考 [CLI 工具详细说明](references/cli.md)

## 关键要点

- **默认数据集**：搜索时如不指定数据集，会搜索所有数据集
- **提示指令**：除非用户明确要求搜索特定数据集，否则始终省略 `table_names` 参数
