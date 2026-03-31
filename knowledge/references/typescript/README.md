# TypeScript Knowledge SDK 使用指南

本指南介绍如何使用 TypeScript SDK 进行知识库操作。

## Quick Start

```typescript
import { 
  KnowledgeClient, 
  Config, 
  KnowledgeDocument, 
  DataSourceType 
} from 'coze-coding-dev-sdk';

const config = new Config();
const client = new KnowledgeClient(config);

async function main() {
  // 1. 添加文档
  const docs: KnowledgeDocument[] = [
    {
      source: DataSourceType.TEXT,
      raw_data: "Coze Coding SDK is a powerful development toolkit.",
    }
  ];

  const addResponse = await client.addDocuments(docs, "coze_doc_knowledge");
  
  if (addResponse.code === 0) {
    console.log(`Successfully added documents. IDs: ${addResponse.doc_ids?.join(', ')}`);
  } else {
    console.error(`Error adding documents: ${addResponse.msg}`);
  }

  // 2. 搜索信息
  const searchResponse = await client.search("What is Coze Coding SDK?");

  if (searchResponse.code === 0) {
    searchResponse.chunks.forEach(chunk => {
      console.log(`[Score: ${chunk.score}] ${chunk.content}`);
    });
  } else {
    console.error(`Search failed: ${searchResponse.msg}`);
  }
}

main().catch(console.error);
```

---

## API Reference

### Client 初始化

```typescript
new KnowledgeClient(
  config?: Config,
  customHeaders?: Record<string, string>,
  verbose?: boolean
)
```

### DataSourceType

```typescript
enum DataSourceType {
  TEXT = 0,  // 纯文本
  URL = 1,   // 网页 URL
  URI = 2,   // 对象存储 URI
}
```

### KnowledgeDocument Interface

```typescript
interface KnowledgeDocument {
  source: DataSourceType;
  raw_data?: string; // TEXT 类型的内容
  url?: string;      // URL 类型的链接
  uri?: string;      // URI 类型的存储地址
}
```

### ChunkConfig Interface

```typescript
interface ChunkConfig {
  separator: string;             // 分隔符（如 "\n"）
  max_tokens: number;            // 每个分块的最大 token 数（默认 2000）
  remove_extra_spaces?: boolean; // 是否规范化空格（默认 false）
  remove_urls_emails?: boolean;  // 是否移除 URL 和邮箱（默认 false）
}
```

### addDocuments()

导入文档到知识库。

```typescript
async addDocuments(
  documents: KnowledgeDocument[],
  tableName: string,
  chunkConfig?: ChunkConfig,
  extraHeaders?: Record<string, string>
): Promise<KnowledgeInsertResponse>
```

**参数：**
- `documents`: KnowledgeDocument 对象数组
- `tableName`: 目标数据集名称，建议使用 `"coze_doc_knowledge"`
- `chunkConfig`: 文本分块配置

### ChunkConfig 使用示例

```typescript
import { ChunkConfig } from 'coze-coding-dev-sdk';

const chunkConfig: ChunkConfig = {
  separator: "\n\n",
  max_tokens: 1000,
  remove_extra_spaces: true,
  remove_urls_emails: false
};
```

### search()

在知识库中进行语义搜索。

```typescript
async search(
  query: string,
  tableNames?: string[],
  topK: number = 5,
  minScore: number = 0.0,
  extraHeaders?: Record<string, string>
): Promise<KnowledgeSearchResponse>
```

**参数：**
- `query`: 搜索文本
- `tableNames`: 要搜索的数据集数组。如不提供或为空，搜索所有数据集
- `topK`: 返回结果数量（默认 5）
- `minScore`: 最小相似度阈值（0.0-1.0）

---

## 使用示例

### 1. 导入文档（文本 & URL）

```typescript
import { 
  KnowledgeClient, 
  Config, 
  KnowledgeDocument, 
  DataSourceType, 
  ChunkConfig 
} from 'coze-coding-dev-sdk';

const config = new Config();
const client = new KnowledgeClient(config);

async function importDocs() {
  const documents: KnowledgeDocument[] = [
    {
      source: DataSourceType.TEXT,
      raw_data: "The quick brown fox jumps over the lazy dog."
    },
    {
      source: DataSourceType.URL,
      url: "https://example.com/documentation"
    }
  ];

  const chunkConfig: ChunkConfig = {
    separator: "\n",
    max_tokens: 2000,
    remove_extra_spaces: false
  };

  const response = await client.addDocuments(
    documents,
    "coze_doc_knowledge",
    chunkConfig
  );

  if (response.code === 0) {
    console.log(`Successfully added ${response.doc_ids?.length} documents.`);
    console.log(`IDs: ${response.doc_ids?.join(', ')}`);
  } else {
    console.error(`Error adding documents: ${response.msg}`);
  }
}
```

### 2. 语义搜索

```typescript
import { KnowledgeClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new KnowledgeClient(config);

async function searchDocs() {
  const query = "What does the fox do?";

  const response = await client.search(
    query,
    undefined, // tableNames: undefined 搜索所有数据集
    3,   // topK
    0.6  // minScore
  );

  if (response.code === 0) {
    console.log(`Found ${response.chunks.length} results:`);
    response.chunks.forEach((chunk, i) => {
      console.log(`\nResult ${i + 1} (Score: ${chunk.score.toFixed(4)}):`);
      console.log(`Content: ${chunk.content}`);
      console.log(`Source Doc ID: ${chunk.doc_id}`);
    });
  } else {
    console.error(`Search failed: ${response.msg}`);
  }
}
```

---

## 关键要点

- **默认数据集**：搜索时如不指定数据集，会搜索所有数据集
- **提示指令**：除非用户明确要求搜索特定数据集，否则始终省略 `tableNames` 参数
- **数据源枚举**：使用 `DataSourceType.TEXT` (0) 表示文本，`DataSourceType.URL` (1) 表示链接
- **错误处理**：始终检查 `response.code === 0` 确保操作成功
- **异步操作**：所有客户端方法都是异步的，返回 Promise
