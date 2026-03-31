# Python Knowledge SDK 使用指南

本指南介绍如何使用 Python SDK 进行知识库操作。

## Quick Start

```python
from coze_coding_dev_sdk import KnowledgeClient, Config, KnowledgeDocument, DataSourceType
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
config = Config()
client = KnowledgeClient(config=config, ctx=ctx)

# 1. 添加文档
docs = [
    KnowledgeDocument(
        source=DataSourceType.TEXT,
        raw_data="Coze Coding SDK is a powerful development toolkit.",
    )
]
client.add_documents(documents=docs, table_name="coze_doc_knowledge")

# 2. 搜索信息
response = client.search(query="What is Coze Coding SDK?")

for chunk in response.chunks:
    print(f"[Score: {chunk.score}] {chunk.content}")
```

**关于 Context (`ctx`):**
- `Context` 用于分布式系统中的请求追踪
- 生产环境建议使用以启用可观测性和调试

---

## API Reference

### Client 初始化

```python
KnowledgeClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None,
    custom_headers: Optional[Dict[str, str]] = None,
    verbose: bool = True
)
```

### DataSourceType

```python
class DataSourceType(IntEnum):
    TEXT = 0  # 纯文本
    URL = 1   # 网页 URL
    URI = 2   # 对象存储 URI
```

### add_documents()

导入文档到知识库。

```python
client.add_documents(
    documents: List[Union[KnowledgeDocument, Dict]],
    table_name: str,
    chunk_config: Optional[ChunkConfig] = None,
    extra_headers: Optional[Dict[str, str]] = None
) -> KnowledgeInsertResponse
```

**参数：**
- `documents`: KnowledgeDocument 对象列表或字典列表
- `table_name`: 目标数据集名称，建议使用 `"coze_doc_knowledge"`
- `chunk_config`: 文本分块配置（分隔符、max_tokens 等）

### ChunkConfig

```python
ChunkConfig(
    separator: str = "\n",
    max_tokens: int = 2000,
    remove_extra_spaces: bool = False,
    remove_urls_emails: bool = False
)
```

**示例：**

```python
from coze_coding_dev_sdk import ChunkConfig

chunk_config = ChunkConfig(
    separator="\n\n",
    max_tokens=1000,
    remove_extra_spaces=True
)
```

### search()

在知识库中进行语义搜索。

```python
client.search(
    query: str,
    table_names: Optional[List[str]] = None,
    top_k: int = 5,
    min_score: Optional[float] = 0.0,
    extra_headers: Optional[Dict[str, str]] = None
) -> KnowledgeSearchResponse
```

**参数：**
- `query`: 搜索文本
- `table_names`: 要搜索的数据集列表。如不提供或为空，搜索所有数据集
- `top_k`: 返回结果数量（默认 5）
- `min_score`: 最小相似度阈值（0.0-1.0）

---

## 使用示例

### 1. 导入文档（文本 & URL）

```python
from coze_coding_dev_sdk import KnowledgeClient, Config, KnowledgeDocument, DataSourceType, ChunkConfig

config = Config()
client = KnowledgeClient(config=config)

documents = [
    KnowledgeDocument(
        source=DataSourceType.TEXT,
        raw_data="The quick brown fox jumps over the lazy dog."
    ),
    KnowledgeDocument(
        source=DataSourceType.URL,
        url="https://example.com/documentation"
    )
]

chunk_config = ChunkConfig(
    separator="\n",
    max_tokens=2000,
    remove_extra_spaces=False
)

response = client.add_documents(
    documents=documents,
    table_name="coze_doc_knowledge",
    chunk_config=chunk_config
)

if response.code == 0:
    print(f"Successfully added {len(response.doc_ids)} documents. IDs: {response.doc_ids}")
else:
    print(f"Error adding documents: {response.msg}")
```

### 2. 语义搜索

```python
from coze_coding_dev_sdk import KnowledgeClient, Config

config = Config()
client = KnowledgeClient(config=config)

query = "What does the fox do?"

response = client.search(
    query=query,
    top_k=3,
    min_score=0.6
)

if response.code == 0:
    print(f"Found {len(response.chunks)} results:")
    for i, chunk in enumerate(response.chunks):
        print(f"\nResult {i+1} (Score: {chunk.score:.4f}):")
        print(f"Content: {chunk.content}")
        print(f"Source Doc ID: {chunk.doc_id}")
else:
    print(f"Search failed: {response.msg}")
```

---

## 关键要点

- **默认数据集**：搜索时如不指定数据集，会搜索所有数据集
- **提示指令**：除非用户明确要求搜索特定数据集，否则始终省略 `table_names` 参数（或传空/None）
- **数据源枚举**：使用 `DataSourceType.TEXT` (0) 表示文本，`DataSourceType.URL` (1) 表示链接
- **错误处理**：始终检查 `response.code == 0` 确保操作成功
- **Context**：生产环境建议传入 `Context` 对象用于请求追踪
