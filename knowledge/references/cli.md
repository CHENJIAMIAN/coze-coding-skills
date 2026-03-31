# CLI 工具详细说明

Knowledge CLI 提供快速的知识库操作能力，适用于一次性/临时任务。

---

## 通用参数

所有命令均支持以下参数：

| 参数 | 简写 | 说明 |
|------|------|------|
| `--help` | `-h` | 显示帮助信息 |

---

## 导入文档

### 命令格式

```bash
coze-coding-ai knowledge add [options]
```

### 参数说明

| 参数 | 简写 | 说明 | 必需 |
|------|------|------|------|
| `--dataset` | `-d` | 目标数据集名称，建议使用 `coze_doc_knowledge` | ✅ |
| `--content` | `-c` | 要导入的文本内容（与 `--url` 二选一） | ❌ |
| `--url` | `-u` | 要导入的网页 URL（与 `--content` 二选一） | ❌ |

**说明：**
- `--content` 和 `--url` 必须提供其中一个
- 导入文本时使用 `--content`
- 导入网页时使用 `--url`

### 示例

**导入文本：**
```bash
coze-coding-ai knowledge add \
  --dataset "coze_doc_knowledge" \
  --content "这是要导入的文本内容"
```

**导入 URL：**
```bash
coze-coding-ai knowledge add \
  --dataset "coze_doc_knowledge" \
  --url "https://example.com/doc.html"
```

---

## 语义搜索

### 命令格式

```bash
coze-coding-ai knowledge search [options]
```

### 参数说明

| 参数 | 简写 | 说明 | 默认值 | 必需 |
|------|------|------|--------|------|
| `--query` | `-q` | 搜索查询文本 | - | ✅ |
| `--top-k` | `-k` | 返回结果数量 | 5 | ❌ |
| `--dataset` | `-d` | 指定搜索的数据集（可多次使用） | 所有数据集 | ❌ |

**说明：**
- 如不指定 `--dataset`，默认搜索所有数据集
- `--top-k` 控制返回的最相关结果数量

### 示例

**基础搜索：**
```bash
coze-coding-ai knowledge search --query "搜索关键词"
```

**指定返回数量：**
```bash
coze-coding-ai knowledge search \
  --query "搜索关键词" \
  --top-k 3
```

**搜索指定数据集：**
```bash
coze-coding-ai knowledge search \
  --query "搜索关键词" \
  --dataset "coze_doc_knowledge"
```

---

## 常用场景

### 快速导入单条文本
```bash
coze-coding-ai knowledge add -d "coze_doc_knowledge" -c "快速导入的文本"
```

### 导入网页文档
```bash
coze-coding-ai knowledge add -d "coze_doc_knowledge" -u "https://docs.example.com/guide"
```

### 快速搜索
```bash
coze-coding-ai knowledge search -q "如何使用" -k 5
```
