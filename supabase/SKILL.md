---
name: supabase
description: 当用户需要使用 Supabase 或 Database 能力时加载，用于持久化数据存储和数据访问控制。适用于构建用户管理系统、存储应用数据、实现数据驱动功能、记录追踪/历史、管理实体关系，或任何需要结构化数据持久化与 CRUD 操作、数据安全策略、Edge Functions 的场景。
---

# Supabase 开发指南

> 🔴🔴🔴 **【最重要】开始前必读**：在编写任何代码之前，**必须先用 Read 工具读取对应语言的 README.md 文件**。不读取直接编码将导致错误！
>
> - TypeScript 项目：**立即读取** [references/typescript/README.md](references/typescript/README.md)
> - Python 项目：**立即读取** [references/python/README.md](references/python/README.md)

本技能提供 Supabase 数据库开发支持。支持结构化数据的存储、检索和管理，提供了一套统一的工作流，用于定义 Schema、管理迁移以及实现类型安全的 CRUD 操作。

## 触发场景

当用户请求涉及以下内容时，使用此 Skill：

- 构建用户管理系统、存储应用数据
- 实现数据驱动功能、记录追踪/历史
- 管理实体关系、结构化数据持久化
- 表结构操作（新建表、变更字段、查看结构）
- 数据 CRUD（查询、插入、更新、删除）
- 数据访问控制、行级安全策略（RLS）
- Edge Functions（部署、管理、调用服务端函数）

## 参考文档导航

| 需求                          | 文档                                                                 |
| :-------------------------- | :----------------------------------------------------------------- |
| TypeScript 项目开发             | [references/typescript/README.md](references/typescript/README.md) |
| Python 项目开发                 | [references/python/README.md](references/python/README.md)         |
| RLS 策略配置与场景选择               | [references/rls.md](references/rls.md)                             |
| Edge Functions 管理（部署、删除、查看） | [references/cli.md](references/cli.md)                             |
