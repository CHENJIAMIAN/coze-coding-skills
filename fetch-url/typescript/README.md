# Fetch URL Skill TypeScript SDK

This skill guides the implementation of URL content fetching functionality using the coze-coding-dev-sdk package, enabling URL content extraction and parsing capabilities.

## Overview

Fetch URL capabilities allow you to build applications that can fetch and extract structured content from any URL, including text, images, and links.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

- **TypeScript SDK**: `coze-coding-dev-sdk >= 0.7.17`

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

```typescript
import { FetchClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FetchClient(config);

const response = await client.fetch('https://example.com/article');

console.log(`Title: ${response.title}`);
console.log(`URL: ${response.url}`);
for (const item of response.content) {
  if (item.type === 'text') {
    console.log(`Text: ${item.text}`);
  } else if (item.type === 'image') {
    console.log(`Image: ${item.image?.display_url}`);
  } else if (item.type === 'link') {
    console.log(`Link: ${item.url}`);
  }
}
```

**About Config:**

- `Config` manages SDK configuration including API key, base URL, and timeout settings
- API credentials are automatically loaded from environment variables
- **Optional**: You can pass custom configuration: `new Config({ apiKey: 'your-key', timeout: 30000 })`
- Recommended for production environments to enable proper authentication and error handling

## API Reference

### Client Initialization

```typescript
new FetchClient(
  config?: Config,
  customHeaders?: Record<string, string>,
  verbose?: boolean
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `customHeaders`: Custom HTTP headers (e.g., `{ "x-run-mode": "test_run" }`)
- `verbose`: Enable verbose HTTP request logging

### fetch() Method

```typescript
client.fetch(url: string): Promise<FetchResponse>
```

Fetch and extract content from a URL.

**Input Parameters:**

| Parameter | Type     | Default  | Description  |
| --------- | -------- | -------- | ------------ |
| `url`     | `string` | Required | URL to fetch |

**Returns:** `FetchResponse` with extracted content

**Response Interface:**

```typescript
interface FetchResponse {
  fetch_id?: string;
  status_code?: number;  // 0 means success, non-0 means error
  status_message?: string;
  url?: string;
  doc_id?: string;
  title?: string;
  publish_time?: string;
  filetype?: string;
  content: FetchContentItem[];
  display_info?: FetchDisplayInfo;
}

interface FetchContentItem {
  type: 'image' | 'link' | 'text';
  text?: string;
  url?: string;
  image?: FetchImage;
}

interface FetchImage {
  image_url?: string;
  display_url?: string;
  width?: number;
  height?: number;
  thumbnail_display_url?: string;
}

interface FetchDisplayInfo {
  no_display?: boolean;
  no_display_reason?: string;
}
```

**Content Item Types:**

| Type    | Description                                      |
| ------- | ------------------------------------------------ |
| `text`  | Text content, available in `text` field          |
| `image` | Image content, details in `image` object         |
| `link`  | Hyperlink, URL available in `url` field          |

**Image Object Fields:**

| Field                   | Type     | Description                        |
| ----------------------- | -------- | ---------------------------------- |
| `image_url`             | `string` | Original image URL                 |
| `display_url`           | `string` | Re-signed publicly accessible URL  |
| `width`                 | `number` | Image width                        |
| `height`                | `number` | Image height                       |
| `thumbnail_display_url` | `string` | Compressed thumbnail URL           |

## Usage Examples

### Basic URL Fetching

```typescript
import { FetchClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FetchClient(config);

const response = await client.fetch('https://example.com/article');

console.log(`Title: ${response.title}`);
console.log(`Status: ${response.status_code === 0 ? 'Success' : 'Failed'}`);
```

### Extract Text Content

```typescript
import { FetchClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FetchClient(config);

const response = await client.fetch('https://example.com/blog-post');

const textContent = response.content
  .filter(item => item.type === 'text')
  .map(item => item.text)
  .join('\n');

console.log('Article content:', textContent);
```

### Extract Images

```typescript
import { FetchClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FetchClient(config);

const response = await client.fetch('https://example.com/gallery');

const images = response.content
  .filter(item => item.type === 'image')
  .map(item => ({
    url: item.image?.display_url,
    width: item.image?.width,
    height: item.image?.height,
    thumbnail: item.image?.thumbnail_display_url
  }));

console.log(`Found ${images.length} images`);
images.forEach((img, i) => {
  console.log(`Image ${i + 1}: ${img.url} (${img.width}x${img.height})`);
});
```

### Extract Links

```typescript
import { FetchClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FetchClient(config);

const response = await client.fetch('https://example.com/resources');

const links = response.content
  .filter(item => item.type === 'link')
  .map(item => item.url);

console.log(`Found ${links.length} links:`, links);
```

### With Custom Headers

```typescript
import { FetchClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const customHeaders = {
  'x-run-mode': 'test_run',
  'x-custom-field': 'custom-value'
};

const client = new FetchClient(config, customHeaders);

const response = await client.fetch('https://example.com/article');
console.log(`Title: ${response.title}`);
```

### Extracting Forward Headers (Required)

**IMPORTANT**: Regardless of which backend framework you use (Next.js, Express, Koa, etc.), you **MUST** extract headers from the incoming request and forward them to the SDK using `HeaderUtils.extractForwardHeaders`. This is required for proper request tracing, authentication, and context propagation.

**IMPORTANT**: This feature requires `coze-coding-dev-sdk` version >=0.7.10. **MUST** check the sdk version before use it.

```typescript
import { HeaderUtils } from 'coze-coding-dev-sdk';

// Extract headers from your request object
const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

// Pass customHeaders to your SDK client
const client = new FetchClient(config, customHeaders);
```

**Example with Next.js:**

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { FetchClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

export async function POST(request: NextRequest) {
  const { url } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const config = new Config();
  const client = new FetchClient(config, customHeaders);

  const response = await client.fetch(url);

  return NextResponse.json({
    title: response.title,
    content: response.content,
    url: response.url,
  });
}
```

**Example with Express:**

```typescript
import express, { Request, Response } from 'express';
import { FetchClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

const app = express();
app.use(express.json());

app.post('/api/fetch', async (req: Request, res: Response) => {
  const { url } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(req.headers as Record<string, string>);

  const config = new Config();
  const client = new FetchClient(config, customHeaders);

  const response = await client.fetch(url);

  res.json({
    title: response.title,
    content: response.content,
    url: response.url,
  });
});
```

## Key Points

- **Backend Only**: Never expose API keys in client-side code
- **Config Management**: Use `Config` class for proper API authentication
- **Custom Headers**: Use `customHeaders` for mock mode or custom metadata
- **Content Types**: Handle different content types (text, image, link) appropriately
- **Error Handling**: Check `status_code` in response (0 means success)
- **Image URLs**: Use `display_url` for publicly accessible image URLs
- **Thumbnails**: Use `thumbnail_display_url` for optimized image loading
