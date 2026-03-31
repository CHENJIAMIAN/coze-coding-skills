# Embedding Skill TypeScript SDK

This skill guides the implementation of embedding functionality using the coze-coding-dev-sdk TypeScript package, enabling powerful vector representation capabilities for text, images, and videos.

## Skills Path

**Skill Location**: `{project_path}/skills/embedding`

This skill is located at the above path in your project.

**Reference Scripts**: Example test scripts are available in the `{Skill Location}/scripts/` directory for quick testing and reference. See `{Skill Location}/scripts/embedding.ts` for a working example.

## Overview

The Embedding skill allows you to convert text, images, and videos into high-dimensional vector representations that capture semantic meaning. These embeddings can be used for:

- **Semantic Search**: Find similar documents based on meaning, not just keywords
- **Similarity Comparison**: Compare the semantic similarity between texts, images, or videos
- **Clustering**: Group similar content together
- **Recommendation Systems**: Find related content based on embeddings
- **RAG Applications**: Retrieve relevant context for LLM prompts
- **Multi-Vector Output**: Generate multiple embedding vectors for complex content
- **Sparse Embeddings**: Generate sparse vectors for hybrid search

**Default Model**: `doubao-embedding-vision-251215`

**IMPORTANT**: This SDK is designed for backend/server-side use. Always ensure proper API key management and never expose credentials in client-side code.

## Prerequisites

The coze-coding-dev-sdk package should be installed. Install it using:

```bash
npm install coze-coding-dev-sdk
```

Import it as shown in the examples below.

## Extracting Forward Headers (Required)

**IMPORTANT**: Regardless of which backend framework you use (Next.js, Express, Koa, etc.), you **MUST** extract headers from the incoming request and forward them to the SDK using `HeaderUtils.extractForwardHeaders`. This is required for proper request tracing, authentication, and context propagation.

```typescript
import { HeaderUtils } from 'coze-coding-dev-sdk';

// Extract headers from your request object
const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

// Pass customHeaders to your EmbeddingClient
const client = new EmbeddingClient({
  customHeaders,
});
```

**Example with Next.js:**

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { EmbeddingClient, HeaderUtils } from 'coze-coding-dev-sdk';

export async function POST(request: NextRequest) {
  const { text } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const client = new EmbeddingClient({ customHeaders });
  const embedding = await client.embedText(text);

  return NextResponse.json({ embedding });
}
```

**Example with Express:**

```typescript
import express, { Request, Response } from 'express';
import { EmbeddingClient, HeaderUtils } from 'coze-coding-dev-sdk';

const app = express();
app.use(express.json());

app.post('/api/embedding', async (req: Request, res: Response) => {
  const { text } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(req.headers as Record<string, string>);

  const client = new EmbeddingClient({ customHeaders });
  const embedding = await client.embedText(text);

  res.json({ embedding });
});
```

## Basic Text Embedding

### Single Text Embedding

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getTextEmbedding(text: string): Promise<number[]> {
  const client = new EmbeddingClient();
  const embedding = await client.embedText(text);
  return embedding;
}

const text = 'Machine learning is transforming the world.';
const embedding = await getTextEmbedding(text);
console.log(`Embedding dimension: ${embedding.length}`);
console.log(`First 5 values: ${embedding.slice(0, 5)}`);
```

### Batch Text Embedding

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getBatchEmbeddings(texts: string[]): Promise<number[]> {
  const client = new EmbeddingClient();
  const embeddings = await client.embedTexts(texts);
  return embeddings;
}

const texts = [
  'The quick brown fox jumps over the lazy dog.',
  'Machine learning is a subset of artificial intelligence.',
  'TypeScript is a typed superset of JavaScript.'
];

const embeddings = await getBatchEmbeddings(texts);
console.log(`Batch embedding dimension: ${embeddings.length}`);
```

### Custom Dimensions

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getEmbeddingWithDimensions(
  text: string,
  dimensions: number = 512
): Promise<number[]> {
  const client = new EmbeddingClient();
  const embedding = await client.embedText(text, { dimensions });
  return embedding;
}

const embedding512 = await getEmbeddingWithDimensions('Sample text', 512);
console.log(`512-dim embedding: ${embedding512.length} dimensions`);

const embedding1024 = await getEmbeddingWithDimensions('Sample text', 1024);
console.log(`1024-dim embedding: ${embedding1024.length} dimensions`);
```

## Image Embedding

### Single Image Embedding

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getImageEmbedding(imageUrl: string): Promise<number[]> {
  const client = new EmbeddingClient();
  const embedding = await client.embedImage(imageUrl);
  return embedding;
}

const imageUrl = 'https://example.com/image.jpg';
const embedding = await getImageEmbedding(imageUrl);
console.log(`Image embedding dimension: ${embedding.length}`);
```

### Batch Image Embedding

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getBatchImageEmbeddings(imageUrls: string[]): Promise<number[]> {
  const client = new EmbeddingClient();
  const embeddings = await client.embedImages(imageUrls);
  return embeddings;
}

const imageUrls = [
  'https://example.com/image1.jpg',
  'https://example.com/image2.jpg',
  'https://example.com/image3.jpg'
];

const embeddings = await getBatchImageEmbeddings(imageUrls);
console.log(`Batch image embedding dimension: ${embeddings.length}`);
```

## Video Embedding

### Single Video Embedding

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getVideoEmbedding(videoUrl: string): Promise<number[]> {
  const client = new EmbeddingClient();
  const embedding = await client.embedVideo(videoUrl);
  return embedding;
}

const videoUrl = 'https://example.com/video.mp4';
const embedding = await getVideoEmbedding(videoUrl);
console.log(`Video embedding dimension: ${embedding.length}`);
```

### Batch Video Embedding

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getBatchVideoEmbeddings(videoUrls: string[]): Promise<number[]> {
  const client = new EmbeddingClient();
  const embeddings = await client.embedVideos(videoUrls);
  return embeddings;
}

const videoUrls = [
  'https://example.com/video1.mp4',
  'https://example.com/video2.mp4'
];

const embeddings = await getBatchVideoEmbeddings(videoUrls);
console.log(`Batch video embedding dimension: ${embeddings.length}`);
```

## Multimodal Embedding

### Combined Text and Image Embedding

```typescript
import { EmbeddingClient, EmbeddingResponse } from 'coze-coding-dev-sdk';

async function getMultimodalEmbeddings(
  texts?: string[],
  imageUrls?: string[]
): Promise<{ embeddings: number[] | undefined; model: string }> {
  const client = new EmbeddingClient();
  const response = await client.embedMultimodal(texts, imageUrls);
  return {
    embeddings: response.data?.embedding,
    model: response.model
  };
}

const result = await getMultimodalEmbeddings(
  ['A beautiful sunset over the ocean'],
  ['https://example.com/sunset.jpg']
);

console.log(`Model used: ${result.model}`);
if (result.embeddings) {
  console.log(`Embedding dimension: ${result.embeddings.length}`);
}
```

### Combined Text, Image, and Video Embedding

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getFullMultimodalEmbeddings(
  texts?: string[],
  imageUrls?: string[],
  videoUrls?: string[]
) {
  const client = new EmbeddingClient();
  const response = await client.embedMultimodal(texts, imageUrls, videoUrls);
  return {
    embeddings: response.data?.embedding,
    model: response.model,
    usage: response.usage
  };
}

const result = await getFullMultimodalEmbeddings(
  ['A cat playing with a ball'],
  ['https://example.com/cat.jpg'],
  ['https://example.com/cat_video.mp4']
);

console.log(`Model used: ${result.model}`);
if (result.usage) {
  console.log(`Total tokens: ${result.usage.total_tokens}`);
}
```

## Advanced Use Cases

### Semantic Search

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

class SemanticSearch {
  private client: EmbeddingClient;
  private documents: string[] = [];
  private embeddings: number[][] = [];

  constructor() {
    this.client = new EmbeddingClient();
  }

  async addDocuments(documents: string[]) {
    this.documents.push(...documents);
    for (const doc of documents) {
      const embedding = await this.client.embedText(doc);
      this.embeddings.push(embedding);
    }
  }

  async search(query: string, topK: number = 5): Promise<Array<{ document: string; score: number }>> {
    const queryEmbedding = await this.client.embedText(query);

    const similarities = this.embeddings.map((docEmbedding, i) => ({
      document: this.documents[i],
      score: this.cosineSimilarity(queryEmbedding, docEmbedding)
    }));

    similarities.sort((a, b) => b.score - a.score);
    return similarities.slice(0, topK);
  }

  private cosineSimilarity(a: number[], b: number[]): number {
    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }
}

const searchEngine = new SemanticSearch();

const documents = [
  'Python is a high-level programming language.',
  'Machine learning models can predict outcomes.',
  'Deep learning uses neural networks.',
  'Natural language processing analyzes text.',
  'Computer vision processes images and videos.'
];

await searchEngine.addDocuments(documents);

const results = await searchEngine.search('How do computers understand text?', 3);
results.forEach(({ document, score }) => {
  console.log(`Score: ${score.toFixed(4)} - ${document}`);
});
```

### Document Similarity Comparison

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function compareDocuments(doc1: string, doc2: string): Promise<number> {
  const client = new EmbeddingClient();

  const emb1 = await client.embedText(doc1);
  const emb2 = await client.embedText(doc2);

  let dotProduct = 0;
  let normA = 0;
  let normB = 0;

  for (let i = 0; i < emb1.length; i++) {
    dotProduct += emb1[i] * emb2[i];
    normA += emb1[i] * emb1[i];
    normB += emb2[i] * emb2[i];
  }

  return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
}

const doc1 = 'The cat sat on the mat.';
const doc2 = 'A feline rested on the rug.';
const doc3 = 'The stock market crashed today.';

const sim12 = await compareDocuments(doc1, doc2);
const sim13 = await compareDocuments(doc1, doc3);

console.log(`Similarity between doc1 and doc2: ${sim12.toFixed(4)}`);
console.log(`Similarity between doc1 and doc3: ${sim13.toFixed(4)}`);
```

### Text Clustering

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function clusterTexts(
  texts: string[],
  nClusters: number = 3
): Promise<Map<number, string[]>> {
  const client = new EmbeddingClient();

  const embeddings: number[][] = [];
  for (const text of texts) {
    const embedding = await client.embedText(text);
    embeddings.push(embedding);
  }

  const centroids = initializeCentroids(embeddings, nClusters);
  const labels = assignClusters(embeddings, centroids);

  const clusters = new Map<number, string[]>();
  texts.forEach((text, i) => {
    const label = labels[i];
    if (!clusters.has(label)) {
      clusters.set(label, []);
    }
    clusters.get(label)!.push(text);
  });

  return clusters;
}

function initializeCentroids(embeddings: number[][], k: number): number[][] {
  const indices = new Set<number>();
  while (indices.size < k) {
    indices.add(Math.floor(Math.random() * embeddings.length));
  }
  return Array.from(indices).map(i => [...embeddings[i]]);
}

function assignClusters(embeddings: number[][], centroids: number[][]): number[] {
  return embeddings.map(emb => {
    let minDist = Infinity;
    let label = 0;
    centroids.forEach((centroid, i) => {
      const dist = euclideanDistance(emb, centroid);
      if (dist < minDist) {
        minDist = dist;
        label = i;
      }
    });
    return label;
  });
}

function euclideanDistance(a: number[], b: number[]): number {
  let sum = 0;
  for (let i = 0; i < a.length; i++) {
    sum += (a[i] - b[i]) ** 2;
  }
  return Math.sqrt(sum);
}

const texts = [
  'Python is great for data science.',
  'JavaScript powers the web.',
  'Machine learning predicts outcomes.',
  'React is a frontend framework.',
  'Deep learning uses neural networks.',
  'Vue.js is another frontend option.'
];

const clusters = await clusterTexts(texts, 2);
clusters.forEach((clusterTexts, clusterId) => {
  console.log(`\nCluster ${clusterId}:`);
  clusterTexts.forEach(text => console.log(`  - ${text}`));
});
```

### RAG Context Retrieval

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

class RAGRetriever {
  private client: EmbeddingClient;
  private chunks: string[] = [];
  private embeddings: number[][] = [];
  private chunkSize: number;

  constructor(chunkSize: number = 500) {
    this.client = new EmbeddingClient();
    this.chunkSize = chunkSize;
  }

  async addDocument(document: string) {
    const newChunks = this.splitIntoChunks(document);
    this.chunks.push(...newChunks);

    for (const chunk of newChunks) {
      const embedding = await this.client.embedText(chunk);
      this.embeddings.push(embedding);
    }
  }

  private splitIntoChunks(text: string): string[] {
    const words = text.split(/\s+/);
    const chunks: string[] = [];
    let currentChunk: string[] = [];
    let currentLength = 0;

    for (const word of words) {
      if (currentLength + word.length > this.chunkSize && currentChunk.length > 0) {
        chunks.push(currentChunk.join(' '));
        currentChunk = [word];
        currentLength = word.length;
      } else {
        currentChunk.push(word);
        currentLength += word.length + 1;
      }
    }

    if (currentChunk.length > 0) {
      chunks.push(currentChunk.join(' '));
    }

    return chunks;
  }

  async retrieve(query: string, topK: number = 3): Promise<string[]> {
    const queryEmbedding = await this.client.embedText(query);

    const similarities = this.embeddings.map((chunkEmbedding, i) => ({
      index: i,
      score: this.cosineSimilarity(queryEmbedding, chunkEmbedding)
    }));

    similarities.sort((a, b) => b.score - a.score);

    return similarities.slice(0, topK).map(item => this.chunks[item.index]);
  }

  private cosineSimilarity(a: number[], b: number[]): number {
    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }
}

const retriever = new RAGRetriever(200);

const document = `
Machine learning is a subset of artificial intelligence that enables 
systems to learn and improve from experience without being explicitly 
programmed. It focuses on developing algorithms that can access data 
and use it to learn for themselves. The process begins with observations 
or data, such as examples, direct experience, or instruction, to look 
for patterns in data and make better decisions in the future.
`;

await retriever.addDocument(document);

const query = 'How do machines learn from data?';
const relevantChunks = await retriever.retrieve(query, 2);

console.log('Query:', query);
console.log('\nRelevant chunks:');
relevantChunks.forEach((chunk, i) => {
  console.log(`\n${i + 1}. ${chunk}`);
});
```

### Async Batch Processing

```typescript
import { EmbeddingClient, EmbeddingResponse } from 'coze-coding-dev-sdk';

async function processLargeDataset(
  texts: string[],
  batchSize: number = 50
): Promise<EmbeddingResponse[]> {
  const client = new EmbeddingClient();

  const batches: string[][] = [];
  for (let i = 0; i < texts.length; i += batchSize) {
    batches.push(texts.slice(i, i + batchSize));
  }

  const results = await client.batchEmbed(batches, undefined, 5);
  return results;
}

const texts = Array.from({ length: 200 }, (_, i) => `Sample text number ${i}`);

const results = await processLargeDataset(texts, 50);
console.log(`Processed ${results.length} batches`);
```

### Multi-Vector Embedding

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getMultiVectorEmbedding(texts: string[]): Promise<number[][] | undefined> {
  const client = new EmbeddingClient();
  const multiEmbeddings = await client.embedWithMultiVectors(texts);
  return multiEmbeddings;
}

const texts = ['Complex document with multiple semantic aspects'];
const multiVectors = await getMultiVectorEmbedding(texts);

if (multiVectors) {
  console.log(`Number of vectors: ${multiVectors.length}`);
  multiVectors.forEach((vec, i) => {
    console.log(`Vector ${i + 1} dimension: ${vec.length}`);
  });
}
```

### Sparse Embedding

```typescript
import { EmbeddingClient, SparseEmbeddingItem } from 'coze-coding-dev-sdk';

async function getSparseEmbedding(texts: string[]): Promise<SparseEmbeddingItem[] | undefined> {
  const client = new EmbeddingClient();
  const sparseEmbedding = await client.embedWithSparse(texts);
  return sparseEmbedding;
}

const texts = ['Machine learning is transforming industries'];
const sparse = await getSparseEmbedding(texts);

if (sparse) {
  console.log(`Sparse embedding entries: ${sparse.length}`);
  sparse.slice(0, 5).forEach(item => {
    console.log(`Index: ${item.index}, Value: ${item.value}`);
  });
}
```

## Best Practices

### 1. Batch Processing for Efficiency

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function efficientEmbedding(texts: string[], batchSize: number = 50) {
  const client = new EmbeddingClient();
  const allEmbeddings: number[][] = [];

  for (let i = 0; i < texts.length; i += batchSize) {
    const batch = texts.slice(i, i + batchSize);
    for (const text of batch) {
      const embedding = await client.embedText(text);
      allEmbeddings.push(embedding);
    }
  }

  return allEmbeddings;
}

const largeTextList = Array.from({ length: 1000 }, (_, i) => `Text ${i}`);
const embeddings = await efficientEmbedding(largeTextList, 50);
console.log(`Processed ${embeddings.length} embeddings`);
```

### 2. Error Handling

```typescript
import { EmbeddingClient, APIError, ValidationError } from 'coze-coding-dev-sdk';

async function safeEmbed(texts: string[], retries: number = 3): Promise<number[][]> {
  const client = new EmbeddingClient();

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const embeddings: number[][] = [];
      for (const text of texts) {
        const embedding = await client.embedText(text);
        embeddings.push(embedding);
      }
      return embeddings;
    } catch (error: unknown) {
      if (error instanceof ValidationError) {
        console.error(`Validation error: ${error.message}`);
        throw error;
      }

      if (error instanceof APIError) {
        console.error(`API error (attempt ${attempt}/${retries}): ${error.message}`);
        if (attempt < retries) {
          await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 1000));
        } else {
          throw error;
        }
      }

      console.error(`Unexpected error (attempt ${attempt}/${retries}): ${error}`);
      if (attempt < retries) {
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 1000));
      } else {
        throw error;
      }
    }
  }

  throw new Error('Failed after all retries');
}

try {
  const embeddings = await safeEmbed(['Hello world', 'Test text']);
  console.log(`Successfully embedded ${embeddings.length} texts`);
} catch (error) {
  console.error('Failed to embed:', error);
}
```

### 3. Caching Embeddings

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';

class EmbeddingCache {
  private cacheDir: string;
  private client: EmbeddingClient;

  constructor(cacheDir: string = './embedding_cache') {
    this.cacheDir = cacheDir;
    this.client = new EmbeddingClient();
    if (!fs.existsSync(cacheDir)) {
      fs.mkdirSync(cacheDir, { recursive: true });
    }
  }

  private getCacheKey(text: string): string {
    return crypto.createHash('md5').update(text).digest('hex');
  }

  private getCachePath(cacheKey: string): string {
    return path.join(this.cacheDir, `${cacheKey}.json`);
  }

  async getEmbedding(text: string, useCache: boolean = true): Promise<number[]> {
    const cacheKey = this.getCacheKey(text);
    const cachePath = this.getCachePath(cacheKey);

    if (useCache && fs.existsSync(cachePath)) {
      const cached = fs.readFileSync(cachePath, 'utf-8');
      return JSON.parse(cached);
    }

    const embedding = await this.client.embedText(text);

    fs.writeFileSync(cachePath, JSON.stringify(embedding));

    return embedding;
  }
}

const cache = new EmbeddingCache();
const embedding1 = await cache.getEmbedding('Hello world');
const embedding2 = await cache.getEmbedding('Hello world');
console.log('Second call uses cache');
```

### 4. Dimension Selection

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function getOptimalEmbedding(text: string, useCase: string = 'search') {
  const client = new EmbeddingClient();

  const dimensionMap: Record<string, number> = {
    search: 1024,
    clustering: 512,
    classification: 768,
    similarity: 1024,
    storage_efficient: 256
  };

  const dimensions = dimensionMap[useCase] || 1024;

  const embedding = await client.embedText(text, { dimensions });
  return embedding;
}

const searchEmbedding = await getOptimalEmbedding('Sample text', 'search');
console.log(`Search embedding: ${searchEmbedding.length} dimensions`);

const efficientEmbedding = await getOptimalEmbedding('Sample text', 'storage_efficient');
console.log(`Storage-efficient embedding: ${efficientEmbedding.length} dimensions`);
```

## Integration Examples

### Express.js API Endpoint

```typescript
import express, { Request, Response } from 'express';
import { EmbeddingClient, APIError } from 'coze-coding-dev-sdk';

const app = express();
app.use(express.json());

const client = new EmbeddingClient();

app.post('/api/embed', async (req: Request, res: Response) => {
  try {
    const { texts, dimensions } = req.body;

    if (!texts || !Array.isArray(texts) || texts.length === 0) {
      return res.status(400).json({ error: 'texts array is required' });
    }

    const embeddings: number[][] = [];
    for (const text of texts) {
      const embedding = await client.embedText(text, { dimensions });
      embeddings.push(embedding);
    }

    res.json({
      success: true,
      embeddings,
      count: embeddings.length,
      dimensions: embeddings[0]?.length || 0
    });
  } catch (error: unknown) {
    if (error instanceof APIError) {
      return res.status(500).json({ error: error.message });
    }
    return res.status(500).json({ error: String(error) });
  }
});

app.post('/api/similarity', async (req: Request, res: Response) => {
  try {
    const { text1, text2 } = req.body;

    if (!text1 || !text2) {
      return res.status(400).json({ error: 'text1 and text2 are required' });
    }

    const emb1 = await client.embedText(text1);
    const emb2 = await client.embedText(text2);

    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < emb1.length; i++) {
      dotProduct += emb1[i] * emb2[i];
      normA += emb1[i] * emb1[i];
      normB += emb2[i] * emb2[i];
    }

    const similarity = dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));

    res.json({
      success: true,
      similarity
    });
  } catch (error: unknown) {
    return res.status(500).json({ error: String(error) });
  }
});

app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'healthy' });
});

app.listen(5000, () => {
  console.log('Embedding API running on port 5000');
});
```

### Fastify Implementation

```typescript
import Fastify, { FastifyRequest, FastifyReply } from 'fastify';
import { EmbeddingClient, APIError } from 'coze-coding-dev-sdk';

const fastify = Fastify({ logger: true });
const client = new EmbeddingClient();

interface EmbedBody {
  texts: string[];
  dimensions?: number;
}

interface SimilarityBody {
  text1: string;
  text2: string;
}

interface SearchBody {
  query: string;
  documents: string[];
  top_k?: number;
}

fastify.post<{ Body: EmbedBody }>('/api/embed', async (request, reply) => {
  try {
    const { texts, dimensions } = request.body;

    if (!texts || texts.length === 0) {
      return reply.status(400).send({ error: 'texts is required' });
    }

    const embeddings: number[][] = [];
    for (const text of texts) {
      const embedding = await client.embedText(text, { dimensions });
      embeddings.push(embedding);
    }

    return {
      success: true,
      embeddings,
      count: embeddings.length,
      dimensions: embeddings[0]?.length || 0
    };
  } catch (error: unknown) {
    if (error instanceof APIError) {
      return reply.status(500).send({ error: error.message });
    }
    return reply.status(500).send({ error: String(error) });
  }
});

fastify.post<{ Body: SimilarityBody }>('/api/similarity', async (request, reply) => {
  try {
    const { text1, text2 } = request.body;

    if (!text1 || !text2) {
      return reply.status(400).send({ error: 'text1 and text2 are required' });
    }

    const emb1 = await client.embedText(text1);
    const emb2 = await client.embedText(text2);

    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < emb1.length; i++) {
      dotProduct += emb1[i] * emb2[i];
      normA += emb1[i] * emb1[i];
      normB += emb2[i] * emb2[i];
    }

    const similarity = dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));

    return {
      success: true,
      similarity
    };
  } catch (error: unknown) {
    return reply.status(500).send({ error: String(error) });
  }
});

fastify.post<{ Body: SearchBody }>('/api/search', async (request, reply) => {
  try {
    const { query, documents, top_k = 5 } = request.body;

    const queryEmbedding = await client.embedText(query);
    const docEmbeddings: number[][] = [];

    for (const doc of documents) {
      const embedding = await client.embedText(doc);
      docEmbeddings.push(embedding);
    }

    const similarities = docEmbeddings.map((docEmb, i) => {
      let dotProduct = 0;
      let normA = 0;
      let normB = 0;

      for (let j = 0; j < queryEmbedding.length; j++) {
        dotProduct += queryEmbedding[j] * docEmb[j];
        normA += queryEmbedding[j] * queryEmbedding[j];
        normB += docEmb[j] * docEmb[j];
      }

      return {
        document: documents[i],
        score: dotProduct / (Math.sqrt(normA) * Math.sqrt(normB))
      };
    });

    similarities.sort((a, b) => b.score - a.score);

    return {
      success: true,
      results: similarities.slice(0, top_k)
    };
  } catch (error: unknown) {
    return reply.status(500).send({ error: String(error) });
  }
});

fastify.get('/health', async () => {
  return { status: 'healthy' };
});

fastify.listen({ port: 8000, host: '0.0.0.0' }, (err) => {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
});
```

## Troubleshooting

### Issue: Empty or invalid input

**Error Message**: `At least one of texts, imageUrls, or videoUrls must be provided`

**Solution**: Ensure you provide at least one non-empty text, image URL, or video URL.

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

const client = new EmbeddingClient();

const texts = ['Valid text'];
const embedding = await client.embedText(texts[0]);
```

### Issue: Batch size exceeded

**Error Message**: `Total inputs exceed maximum batch size of 100`

**Solution**: Split your inputs into smaller batches.

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

const client = new EmbeddingClient();

const largeList = Array.from({ length: 200 }, () => 'text');
const batchSize = 50;

const allEmbeddings: number[][] = [];
for (let i = 0; i < largeList.length; i += batchSize) {
  const batch = largeList.slice(i, i + batchSize);
  for (const text of batch) {
    const embedding = await client.embedText(text);
    allEmbeddings.push(embedding);
  }
}
```

### Issue: API authentication failed

**Error Message**: Authentication error

**Solution**: Ensure `COZE_WORKLOAD_IDENTITY_API_KEY` environment variable is set correctly.

```typescript
const apiKey = process.env.COZE_WORKLOAD_IDENTITY_API_KEY;
if (!apiKey) {
  throw new Error('COZE_WORKLOAD_IDENTITY_API_KEY not set');
}
```

### Issue: Network timeout

**Error Message**: Connection timeout or network error

**Solution**: Implement retry logic with exponential backoff.

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

async function embedWithRetry(texts: string[], maxRetries: number = 3) {
  const client = new EmbeddingClient();

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const embeddings: number[][] = [];
      for (const text of texts) {
        const embedding = await client.embedText(text);
        embeddings.push(embedding);
      }
      return embeddings;
    } catch (error) {
      if (attempt < maxRetries - 1) {
        const waitTime = Math.pow(2, attempt) * 1000;
        console.log(`Retry ${attempt + 1}/${maxRetries} after ${waitTime}ms`);
        await new Promise(resolve => setTimeout(resolve, waitTime));
      } else {
        throw error;
      }
    }
  }
}

const embeddings = await embedWithRetry(['Hello world']);
```

## Supported Models

- `doubao-embedding-vision-251215` (Default) - High-quality multimodal embeddings
- Additional multimodal embedding models for text + image + video

## API Reference Summary

### EmbeddingClient

```typescript
import { EmbeddingClient } from 'coze-coding-dev-sdk';

const client = new EmbeddingClient();

const embedding = await client.embedText(text: string, options?: EmbedOptions);

const embeddings = await client.embedTexts(texts: string[], options?: EmbedOptions);

const embedding = await client.embedImage(imageUrl: string, options?: EmbedOptions);

const embeddings = await client.embedImages(imageUrls: string[], options?: EmbedOptions);

const embedding = await client.embedVideo(videoUrl: string, options?: EmbedOptions);

const embeddings = await client.embedVideos(videoUrls: string[], options?: EmbedOptions);

const response = await client.embedMultimodal(
  texts?: string[],
  imageUrls?: string[],
  videoUrls?: string[],
  options?: EmbedOptions
);

const multiVectors = await client.embedWithMultiVectors(
  texts?: string[],
  imageUrls?: string[],
  videoUrls?: string[],
  options?: EmbedOptions
);

const sparseEmbedding = await client.embedWithSparse(
  texts?: string[],
  imageUrls?: string[],
  videoUrls?: string[],
  options?: EmbedOptions
);

const responses = await client.batchEmbed(
  textBatches: string[][],
  options?: EmbedOptions,
  maxConcurrent?: number
);
```

### EmbedOptions

```typescript
interface EmbedOptions {
  model?: string;
  dimensions?: number;
  encodingFormat?: 'float' | 'base64';
  instructions?: string;
  multiEmbedding?: boolean;
  sparseEmbedding?: boolean;
}
```

### EmbeddingResponse

```typescript
interface EmbeddingResponse {
  object: string;
  data?: {
    object: string;
    embedding?: number[];
    multi_embedding?: number[][];
    sparse_embedding?: SparseEmbeddingItem[];
    index: number;
  };
  model: string;
  usage?: {
    prompt_tokens: number;
    total_tokens: number;
  };
  error?: {
    code?: string;
    message?: string;
  };
}
```

## Remember

- **Backend Only**: Never call these APIs from the frontend
- **Batch Processing**: Use batch methods for multiple texts to improve efficiency
- **Max Batch Size**: Maximum 100 inputs per request
- **Caching**: Consider caching embeddings for repeated texts to save costs
- **Dimensions**: Use smaller dimensions for storage efficiency, larger for accuracy
- **Error Handling**: Always implement proper error handling and retry logic
- **Environment Variables**: Set `COZE_WORKLOAD_IDENTITY_API_KEY` before using the SDK
- **Similarity Calculation**: Use cosine similarity for comparing embeddings
- **Normalization**: Embeddings are typically normalized, but verify for your use case