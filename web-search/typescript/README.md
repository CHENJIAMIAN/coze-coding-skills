# Web Search Skill TypeScript SDK

This skill guides the implementation of web search functionality using the coze-coding-dev-sdk package and CLI tool, enabling retrieval of real-time information from the web with AI-powered summaries.

## Overview

Web Search allows you to build applications that retrieve current information from the internet, including web pages, images, and AI-generated summaries, enabling information retrieval, content discovery, and research automation.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## ⚠️ Critical: Method Parameter Compatibility

**DO NOT mix parameters between different methods!** Each method has specific parameters it accepts:

- **`webSearch(query, count, needSummary)`** - ONLY accepts 3 positional parameters
  - ❌ NEVER use: `time_range`, `sites`, `filter`, `blockHosts` with this method
  - ✅ For filters, use `advancedSearch()` instead

- **`advancedSearch(query, options)`** - Accepts an options object with filters
  - ✅ Use this for: `timeRange`, `sites`, `blockHosts`, `needContent`, etc.

- **`search(request)`** - Low-level API with full request object
  - ✅ Use this only when you need complete control

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

### Basic Usage (Recommended)

For simple web searches, use `webSearch()` with only query, count, and needSummary:

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.webSearch("Python programming language", 5);

if (response.web_items) {
  for (const item of response.web_items) {
    console.log(`Title: ${item.title}`);
    console.log(`URL: ${item.url}`);
    console.log(`Snippet: ${item.snippet}\n`);
  }
}
```

### Advanced Usage (With Filters)

For searches with time range, site filters, or content requirements, use `advancedSearch()`:

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.advancedSearch("Python tutorials", {
  timeRange: "1m",
  sites: "python.org,github.com",
  count: 10,
  needSummary: true,
});
```

**About Config:**

- `Config` manages SDK configuration including API key, base URL, and timeout settings
- API credentials are automatically loaded from environment variables
- **Optional**: You can pass custom configuration: `new Config({ apiKey: 'your-key', timeout: 30000 })`
- Recommended for production environments to enable proper authentication and error handling

## API Reference

### Client Initialization

```typescript
new SearchClient(
  config?: Config,
  customHeaders?: Record<string, string>
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `customHeaders`: Custom HTTP headers (e.g., `{ "x-custom-field": "value" }`)

---

## Recommended Methods (Use These First)

### webSearch() Method - For Simple Web Search

**RECOMMENDED** for basic web searches. Use this when you only need query, count, and summary control.

```typescript
client.webSearch(
  query: string,
  count?: number,
  needSummary?: boolean
): Promise<SearchResponse>
```

**Parameters:**

| Parameter     | Type      | Default  | Description                   |
| ------------- | --------- | -------- | ----------------------------- |
| `query`       | `string`  | Required | Search query text             |
| `count`       | `number`  | `10`     | Number of results to return   |
| `needSummary` | `boolean` | `true`   | Whether to include AI summary |

**⚠️ IMPORTANT**: This method ONLY accepts these 3 parameters. Do NOT use `time_range`, `sites`, `filter`, or other advanced parameters with `webSearch()`. Use `advancedSearch()` instead.

**Example:**

```typescript
const response = await client.webSearch("Python programming", 10, true);
```

---

### advancedSearch() Method - For Advanced Filtering

**RECOMMENDED** when you need filters like time range, site restrictions, or content requirements.

```typescript
client.advancedSearch(
  query: string,
  options?: {
    searchType?: 'web' | 'web_summary' | 'image';
    count?: number;
    needContent?: boolean;
    needUrl?: boolean;
    sites?: string;
    blockHosts?: string;
    needSummary?: boolean;
    timeRange?: string;
  }
): Promise<SearchResponse>
```

**Options Parameters:**

| Parameter     | Type      | Default | Description                                      |
| ------------- | --------- | ------- | ------------------------------------------------ |
| `searchType`  | `string`  | `"web"` | Search type: `"web"`, `"web_summary"`, `"image"` |
| `count`       | `number`  | `10`    | Number of results to return                      |
| `needContent` | `boolean` | `false` | Only return results with full content            |
| `needUrl`     | `boolean` | `false` | Only return results with original URL            |
| `sites`       | `string`  | `null`  | Comma-separated list of sites to search          |
| `blockHosts`  | `string`  | `null`  | Comma-separated list of sites to exclude         |
| `needSummary` | `boolean` | `true`  | Whether to include AI-generated summary          |
| `timeRange`   | `string`  | `null`  | Time range filter (e.g., "1d", "1w", "1m")       |

**Example:**

```typescript
const response = await client.advancedSearch("Python tutorials", {
  timeRange: "1m",
  sites: "python.org,github.com",
  count: 15,
});
```

---

### imageSearch() Method - For Image Search

**RECOMMENDED** for searching images.

```typescript
client.imageSearch(
  query: string,
  count?: number
): Promise<SearchResponse>
```

**Parameters:**

| Parameter | Type     | Default  | Description                 |
| --------- | -------- | -------- | --------------------------- |
| `query`   | `string` | Required | Search query text           |
| `count`   | `number` | `10`     | Number of results to return |

**Example:**

```typescript
const response = await client.imageSearch("cute cats", 20);
```

---

### webSearchWithSummary() Method

Web search with guaranteed AI-generated summary. Equivalent to `webSearch(query, count, true)`.

```typescript
client.webSearchWithSummary(
  query: string,
  count?: number
): Promise<SearchResponse>
```

---

## Advanced Method (For Full Control)

### search() Method - Low-Level API

**USE ONLY** when you need full control over the request structure. For most cases, use `webSearch()` or `advancedSearch()` instead.

```typescript
client.search(request: SearchRequest): Promise<SearchResponse>
```

**SearchRequest Interface:**

```typescript
interface SearchRequest {
  query: string;
  search_type?: "web" | "web_summary" | "image";
  count?: number;
  filter?: SearchFilter;
  need_summary?: boolean;
  time_range?: string;
}

interface SearchFilter {
  need_content?: boolean;
  need_url?: boolean;
  sites?: string;
  block_hosts?: string;
}
```

**Input Parameters:**

| Parameter      | Type           | Default  | Description                                         |
| -------------- | -------------- | -------- | --------------------------------------------------- |
| `query`        | `string`       | Required | Search query text                                   |
| `search_type`  | `string`       | `"web"`  | Search type: `"web"`, `"web_summary"`, or `"image"` |
| `count`        | `number`       | `10`     | Number of results to return                         |
| `filter`       | `SearchFilter` | `{}`     | Search filter options                               |
| `need_summary` | `boolean`      | `true`   | Whether to include AI-generated summary             |
| `time_range`   | `string`       | `null`   | Time range filter (e.g., "1d", "1w", "1m")          |

**SearchFilter Parameters:**

| Parameter      | Type      | Default | Description                              |
| -------------- | --------- | ------- | ---------------------------------------- |
| `need_content` | `boolean` | `false` | Only return results with full content    |
| `need_url`     | `boolean` | `false` | Only return results with original URL    |
| `sites`        | `string`  | `null`  | Comma-separated list of sites to search  |
| `block_hosts`  | `string`  | `null`  | Comma-separated list of sites to exclude |

**Example:**

```typescript
const response = await client.search({
  query: "AI research",
  search_type: "web",
  count: 10,
  filter: {
    sites: "arxiv.org",
    need_content: true,
  },
  time_range: "1m",
});
```

---

## Method Selection Guide

**Choose the right method:**

1. **Simple web search** → Use `webSearch(query, count, needSummary)`
2. **Need time filter, site filter, or content requirements** → Use `advancedSearch(query, options)`
3. **Image search** → Use `imageSearch(query, count)`
4. **Need full control over request structure** → Use `search(request)`

**Common Mistakes to Avoid:**

❌ **WRONG**: `client.webSearch('query', { timeRange: '1d' })`  
✅ **CORRECT**: `client.advancedSearch('query', { timeRange: '1d' })`

❌ **WRONG**: `client.webSearch('query', 10, true, '1d')`  
✅ **CORRECT**: `client.advancedSearch('query', { count: 10, needSummary: true, timeRange: '1d' })`

---

### Response Interfaces

```typescript
interface SearchResponse {
  web_items: WebItem[];
  image_items: ImageItem[];
  summary?: string;
}

interface WebItem {
  id: string;
  sort_id: number;
  title: string;
  site_name?: string;
  url?: string;
  snippet: string;
  summary?: string;
  content?: string;
  publish_time?: string;
  logo_url?: string;
  rank_score?: number;
  auth_info_des: string;
  auth_info_level: number;
}

interface ImageItem {
  id: string;
  sort_id: number;
  title?: string;
  site_name?: string;
  url?: string;
  publish_time?: string;
  image: ImageInfo;
}

interface ImageInfo {
  url: string;
  width?: number;
  height?: number;
  shape: string;
}
```

**WebItem Fields:**

- `id`: Result ID
- `sort_id`: Sort order ID
- `title`: Page title
- `site_name`: Website name
- `url`: Page URL
- `snippet`: Content snippet/preview
- `summary`: AI-generated precise summary (if available)
- `content`: Full page content (if `need_content=true`)
- `publish_time`: Publication time
- `logo_url`: Site logo URL
- `rank_score`: Relevance score
- `auth_info_des`: Authority description
- `auth_info_level`: Authority level

**ImageItem Fields:**

- `id`: Result ID
- `sort_id`: Sort order ID
- `title`: Image title
- `site_name`: Source website name
- `url`: Source page URL
- `publish_time`: Publication time
- `image`: ImageInfo object with URL, dimensions, and shape

## Usage Examples

### Basic Web Search

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.webSearch(
  "Artificial Intelligence trends 2024",
  10,
);

for (const item of response.web_items) {
  console.log(`${item.title}`);
  console.log(`Source: ${item.site_name}`);
  console.log(`URL: ${item.url}`);
  console.log(`Snippet: ${item.snippet.substring(0, 100)}...`);
  console.log(`Authority: ${item.auth_info_des}\n`);
}
```

### Web Search with AI Summary

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.webSearchWithSummary(
  "History of artificial intelligence",
  5,
);

console.log("=".repeat(60));
console.log("AI Summary:");
console.log("=".repeat(60));
console.log(response.summary);
console.log("\n" + "=".repeat(60));
console.log(`Search Results (${response.web_items.length} items):`);
console.log("=".repeat(60));

response.web_items.forEach((item, i) => {
  console.log(`\n${i + 1}. ${item.title}`);
  console.log(`   Source: ${item.site_name}`);
  console.log(`   URL: ${item.url}`);
});
```

### Advanced Search with Filters

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.advancedSearch("Python tutorials", {
  searchType: "web",
  count: 15,
  needContent: true,
  needUrl: true,
  sites: "python.org,github.com,stackoverflow.com",
  timeRange: "1m",
  needSummary: true,
});

for (const item of response.web_items) {
  console.log(`Title: ${item.title}`);
  console.log(`URL: ${item.url}`);
  if (item.content) {
    console.log(`Content preview: ${item.content.substring(0, 200)}...`);
  }
  console.log();
}
```

### Image Search

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.imageSearch("cute cats", 20);

console.log(`Found ${response.image_items.length} images\n`);

response.image_items.forEach((item, i) => {
  console.log(`${i + 1}. ${item.title || "Untitled"}`);
  console.log(`   Source: ${item.site_name}`);
  console.log(`   Image URL: ${item.image.url}`);
  console.log(`   Size: ${item.image.width}x${item.image.height}`);
  console.log(`   Shape: ${item.image.shape}\n`);
});
```

### Search with Custom Headers

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();

const customHeaders = {
  "x-custom-field": "custom-value",
};

const client = new SearchClient(config, customHeaders);

const response = await client.webSearch("Machine learning basics", 10);
```

### Extracting Forward Headers (Required)

**IMPORTANT**: Regardless of which backend framework you use (Next.js, Express, Koa, etc.), you **MUST** extract headers from the incoming request and forward them to the SDK using `HeaderUtils.extractForwardHeaders`. This is required for proper request tracing, authentication, and context propagation.

**IMPORTANT**: This feature requires `coze-coding-dev-sdk` version >=0.7.10. **MUST** check the sdk version before use it.

```typescript
import { HeaderUtils } from "coze-coding-dev-sdk";

// Extract headers from your request object
const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

// Pass customHeaders to your SDK client
const client = new SearchClient(config, customHeaders);
```

**Example with Next.js:**

```typescript
import { NextRequest, NextResponse } from "next/server";
import { SearchClient, Config, HeaderUtils } from "coze-coding-dev-sdk";

export async function POST(request: NextRequest) {
  const { query, count, needSummary } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const config = new Config();
  const client = new SearchClient(config, customHeaders);

  const response = await client.webSearch(
    query,
    count || 10,
    needSummary ?? true,
  );

  return NextResponse.json({
    summary: response.summary,
    results: response.web_items.map((item) => ({
      title: item.title,
      url: item.url,
      snippet: item.snippet,
    })),
  });
}
```

**Example with Express:**

```typescript
import express, { Request, Response } from "express";
import { SearchClient, Config, HeaderUtils } from "coze-coding-dev-sdk";

const app = express();
app.use(express.json());

app.post("/api/search", async (req: Request, res: Response) => {
  const { query, count, needSummary } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(
    req.headers as Record<string, string>,
  );

  const config = new Config();
  const client = new SearchClient(config, customHeaders);

  const response = await client.webSearch(
    query,
    count || 10,
    needSummary ?? true,
  );

  res.json({
    summary: response.summary,
    results: response.web_items.map((item) => ({
      title: item.title,
      url: item.url,
      snippet: item.snippet,
    })),
  });
});
```

### Block Specific Sites

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.advancedSearch("Technology news", {
  searchType: "web",
  count: 10,
  blockHosts: "example.com,spam-site.com",
  timeRange: "1d",
});
```

### Search with Time Range Filter

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.advancedSearch("Latest AI breakthroughs", {
  searchType: "web",
  count: 10,
  timeRange: "1w",
});

for (const item of response.web_items) {
  console.log(`${item.title}`);
  console.log(`Published: ${item.publish_time}`);
  console.log(`URL: ${item.url}\n`);
}
```

### Custom Search Request

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.search({
  query: "Latest technology news",
  search_type: "web",
  count: 10,
  filter: {
    need_content: false,
    need_url: true,
    block_hosts: "example.com",
  },
  need_summary: true,
  time_range: "1d",
});

if (response.summary) {
  console.log("\nSummary:");
  console.log(response.summary);
}

console.log(`\nFound ${response.web_items.length} results`);
response.web_items.forEach((item, i) => {
  console.log(`\n${i + 1}. ${item.title}`);
  console.log(`   Authority Level: ${item.auth_info_level}`);
  console.log(`   ${item.snippet.substring(0, 100)}...`);
});
```

### Error Handling

```typescript
import { SearchClient, Config, APIError } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

try {
  const response = await client.webSearch("AI research", 10);

  if (response.web_items && response.web_items.length > 0) {
    console.log("Success! Found results:");
    response.web_items.forEach((item) => {
      console.log(`- ${item.title}`);
    });
  } else {
    console.log("No results found");
  }
} catch (error) {
  if (error instanceof APIError) {
    console.error("API Error:", error.message);
    console.error("Status Code:", error.statusCode);
  } else {
    console.error("Unexpected error:", error);
  }
}
```

### Site-Specific Search

```typescript
import { SearchClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new SearchClient(config);

const response = await client.advancedSearch("Python best practices", {
  searchType: "web",
  count: 10,
  sites: "python.org,realpython.com,stackoverflow.com",
  needContent: true,
});

console.log(
  `Found ${response.web_items.length} results from specified sites\n`,
);

response.web_items.forEach((item, i) => {
  console.log(`${i + 1}. ${item.title}`);
  console.log(`   Site: ${item.site_name}`);
  console.log(`   URL: ${item.url}\n`);
});
```

## CLI Usage

The SDK includes a command-line tool `coze-coding-ai` for quick web search without writing code.

### Basic CLI Usage

```bash
coze-coding-ai search --query "Python programming language"
```

### CLI Options

```bash
coze-coding-ai search [OPTIONS]

Options:
  -q, --query <text>      Search query [required]
  --type <type>           Search type: web or image (default: web)
  --count <number>        Number of results (default: 10)
  -H, --header <header>   Custom HTTP header (format: "Key: Value" or "Key=Value")
  --help                  Show this message and exit
```

### CLI Examples

**Basic web search:**

```bash
coze-coding-ai search --query "AI latest developments"
```

**Web search with custom count:**

```bash
coze-coding-ai search --query "Quantum computing principles" --count 20
```

**Image search:**

```bash
coze-coding-ai search --query "cute cats" --type image --count 20
```

**With custom headers:**

```bash
coze-coding-ai search \
  --query "Machine learning" \
  --header "x-custom-field: custom-value" \
  --header "x-request-id: 12345"
```

## Key Points

### Method Selection (CRITICAL)

- **`webSearch(query, count, needSummary)`**: Use for simple searches - ONLY 3 parameters allowed
- **`advancedSearch(query, options)`**: Use when you need `timeRange`, `sites`, `blockHosts`, or content filters
- **`imageSearch(query, count)`**: Use for image searches
- **`search(request)`**: Low-level API - use only when you need full control
- **NEVER mix parameters**: Don't pass `timeRange`, `sites`, or `filter` to `webSearch()` - use `advancedSearch()` instead

### General Guidelines

- **Backend Only**: Never expose API keys in client-side code
- **Error Handling**: Always check if `response.web_items` or `response.image_items` exist before accessing
- **Config Management**: Use `Config` class for proper API authentication
- **Custom Headers**: Use `customHeaders` for mock mode or custom metadata
- **Time Range**: Use format like "1d" (1 day), "1w" (1 week), "1m" (1 month) for time filtering with `advancedSearch()`
- **Site Filtering**: Use comma-separated domain names for `sites` and `blockHosts` parameters in `advancedSearch()`
- **Authority Info**: Use `auth_info_level` and `auth_info_des` to assess result credibility
- **CLI Tool**: Use `coze-coding-ai search` command for quick searches without writing code
- **AI Summaries**: Use `webSearchWithSummary()` or set `needSummary: true` in `webSearch()` for AI-generated summaries
