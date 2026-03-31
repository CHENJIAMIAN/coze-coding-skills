# Image Generation Skill TypeScript SDK

This skill guides the implementation of image generation functionality using the coze-coding-dev-sdk package and CLI tool, enabling creation of high-quality images from text descriptions.

## Overview

Image Generation allows you to build applications that create visual content from text prompts using AI models, enabling creative workflows, design automation, and visual content production.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

```typescript
import { ImageGenerationClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new ImageGenerationClient(config);

const response = await client.generate({
  prompt: 'A futuristic city with flying vehicles at sunset',
  size: '2K'
});

const helper = client.getResponseHelper(response);

if (helper.success) {
  const imageData = await axios.get(helper.imageUrls[0], { responseType: 'arraybuffer' });
  fs.writeFileSync('output.png', imageData.data);
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
new ImageGenerationClient(
  config?: Config,
  customHeaders?: Record<string, string>
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `customHeaders`: Custom HTTP headers (e.g., `{ "x-run-mode": "test_run" }`)

### generate() Method

```typescript
client.generate(request: ImageGenerationRequest): Promise<ImageGenerationResponse>
```

**ImageGenerationRequest Interface:**

```typescript
interface ImageGenerationRequest {
  prompt: string;
  size?: string;
  watermark?: boolean;
  image?: string | string[];
  responseFormat?: 'url' | 'b64_json';
  optimizePromptMode?: string;
  sequentialImageGeneration?: 'auto' | 'disabled';
  sequentialImageGenerationMaxImages?: number;
}
```

**Input Parameters:**

| Parameter                            | Type               | Default      | Description                                                             |
| ------------------------------------ | ------------------ | ------------ | ----------------------------------------------------------------------- |
| `prompt`                             | `string`           | Required     | Text description for image generation                                   |
| `size`                               | `string`           | `"2K"`       | Image size: `"2K"`, `"4K"`, or `"WIDTHxHEIGHT"` (2560x1440 ~ 4096x4096) |
| `watermark`                          | `boolean`          | `true`       | Add watermark to generated images                                       |
| `image`                              | `string\|string[]` | `undefined`  | Reference image URL(s) for image-to-image generation                    |
| `responseFormat`                     | `string`           | `"url"`      | Response format: `"url"` or `"b64_json"`                                |
| `optimizePromptMode`                 | `string`           | `"standard"` | Prompt optimization mode                                                |
| `sequentialImageGeneration`          | `string`           | `"disabled"` | Sequential generation: `"auto"` or `"disabled"`                         |
| `sequentialImageGenerationMaxImages` | `number`           | `15`         | Max images for sequential generation (1-15)                             |

**Response Interface:**

```typescript
interface ImageGenerationResponse {
  model: string;
  created: number;
  data: ImageData[];
  usage?: UsageInfo;
  error?: {
    code?: string;
    message?: string;
  };
}

interface ImageData {
  url?: string;
  b64_json?: string;
  size?: string;
  error?: {
    code?: string;
    message?: string;
  };
}

interface UsageInfo {
  generated_images: number;
  output_tokens?: number;
  total_tokens?: number;
}
```

**Response Helper Methods:**

```typescript
const helper = client.getResponseHelper(response);

helper.success: boolean           // Check if generation succeeded
helper.imageUrls: string[]        // Get all image URLs
helper.imageB64List: string[]     // Get all base64 encoded images
helper.errorMessages: string[]    // Get all error messages
```

## Usage Examples

### Basic Generation with Custom Headers

```typescript
import { ImageGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();

const customHeaders = {
  'x-custom-field': 'custom-value',
};

const client = new ImageGenerationClient(config, customHeaders);

const response = await client.generate({
  prompt: 'A serene mountain landscape',
  size: '4K'
});

const helper = client.getResponseHelper(response);
console.log('Image URLs:', helper.imageUrls);
```

### Extracting Forward Headers (Required)

**IMPORTANT**: Regardless of which backend framework you use (Next.js, Express, Koa, etc.), you **MUST** extract headers from the incoming request and forward them to the SDK using `HeaderUtils.extractForwardHeaders`. This is required for proper request tracing, authentication, and context propagation.

```typescript
import { HeaderUtils } from 'coze-coding-dev-sdk';

// Extract headers from your request object
const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

// Pass customHeaders to your SDK client
const client = new ImageGenerationClient(config, customHeaders);
```

**Example with Next.js:**

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { ImageGenerationClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

export async function POST(request: NextRequest) {
  const { prompt, size } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const config = new Config();
  const client = new ImageGenerationClient(config, customHeaders);

  const response = await client.generate({
    prompt,
    size: size || '2K',
  });

  const helper = client.getResponseHelper(response);

  if (helper.success) {
    return NextResponse.json({ imageUrls: helper.imageUrls });
  } else {
    return NextResponse.json({ errors: helper.errorMessages }, { status: 500 });
  }
}
```

**Example with Express:**

```typescript
import express, { Request, Response } from 'express';
import { ImageGenerationClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

const app = express();
app.use(express.json());

app.post('/api/image/generate', async (req: Request, res: Response) => {
  const { prompt, size } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(req.headers as Record<string, string>);

  const config = new Config();
  const client = new ImageGenerationClient(config, customHeaders);

  const response = await client.generate({
    prompt,
    size: size || '2K',
  });

  const helper = client.getResponseHelper(response);

  if (helper.success) {
    res.json({ imageUrls: helper.imageUrls });
  } else {
    res.status(500).json({ errors: helper.errorMessages });
  }
});
```

### Image-to-Image Generation

```typescript
import { ImageGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new ImageGenerationClient(config);

const response = await client.generate({
  prompt: 'Transform into anime style',
  image: 'https://example.com/input.jpg',
  size: '2K'
});

const helper = client.getResponseHelper(response);
if (helper.success) {
  console.log('Generated image:', helper.imageUrls[0]);
}
```

### Sequential Image Generation

```typescript
import { ImageGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new ImageGenerationClient(config);

const response = await client.generate({
  prompt: "A story of a cat's adventure",
  sequentialImageGeneration: 'auto',
  sequentialImageGenerationMaxImages: 5,
  size: '2K'
});

const helper = client.getResponseHelper(response);
console.log(`Generated ${helper.imageUrls.length} images`);
```

### Base64 Response Format

```typescript
import { ImageGenerationClient, Config } from 'coze-coding-dev-sdk';
import fs from 'fs';

const config = new Config();
const client = new ImageGenerationClient(config);

const response = await client.generate({
  prompt: 'A modern office workspace',
  responseFormat: 'b64_json',
  size: '2K'
});

const helper = client.getResponseHelper(response);

helper.imageB64List.forEach((b64Data, i) => {
  const buffer = Buffer.from(b64Data, 'base64');
  fs.writeFileSync(`image_${i}.png`, buffer);
});
```

### Error Handling

```typescript
import { ImageGenerationClient, Config, APIError } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new ImageGenerationClient(config);

try {
  const response = await client.generate({
    prompt: 'A beautiful landscape',
    size: '2K'
  });

  const helper = client.getResponseHelper(response);
  
  if (helper.success) {
    console.log('Success! Image URLs:', helper.imageUrls);
  } else {
    console.error('Generation failed:', helper.errorMessages);
  }
} catch (error) {
  if (error instanceof APIError) {
    console.error('API Error:', error.message);
    console.error('Status Code:', error.statusCode);
  } else {
    console.error('Unexpected error:', error);
  }
}
```

### Batch Generation (Parallel)

For generating images from multiple prompts, use `batchGenerate()` for parallel execution:

```typescript
import { ImageGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new ImageGenerationClient(config);

const requests = [
  { prompt: 'A sunset over mountains', size: '2K' },
  { prompt: 'A futuristic cityscape', size: '2K' },
  { prompt: 'A serene beach scene', size: '2K' }
];

const responses = await client.batchGenerate(requests);

responses.forEach((response, i) => {
  const helper = client.getResponseHelper(response);
  if (helper.success) {
    console.log(`Image ${i + 1}:`, helper.imageUrls[0]);
  } else {
    console.error(`Image ${i + 1} failed:`, helper.errorMessages);
  }
});
```

**Manual Concurrency Control:**

```typescript
import { ImageGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new ImageGenerationClient(config);

async function generateWithConcurrencyLimit(
  prompts: string[],
  maxConcurrent: number = 3
) {
  const results = [];
  
  for (let i = 0; i < prompts.length; i += maxConcurrent) {
    const batch = prompts.slice(i, i + maxConcurrent);
    const batchRequests = batch.map(prompt => ({ prompt, size: '2K' }));
    const batchResults = await client.batchGenerate(batchRequests);
    results.push(...batchResults);
  }
  
  return results;
}

const prompts = [
  'A sunset over mountains',
  'A futuristic cityscape',
  'A serene beach scene',
  'A tropical rainforest',
  'A snowy mountain peak'
];

const responses = await generateWithConcurrencyLimit(prompts, 3);

responses.forEach((response, i) => {
  const helper = client.getResponseHelper(response);
  if (helper.success) {
    console.log(`Image ${i + 1}:`, helper.imageUrls[0]);
  }
});
```

## CLI Usage

The SDK includes a command-line tool `coze-coding-ai` for quick image generation without writing code.

### Basic CLI Usage

```bash
coze-coding-ai image --prompt "A futuristic city at sunset" --output output.png
```

### CLI Options

```bash
coze-coding-ai image [OPTIONS]

Options:
  -p, --prompt <text>     Text description of the image [required]
  -o, --output <path>     Output file path
  --size <size>           Image size: 2K, 4K, or WIDTHxHEIGHT (default: 2K)
  -H, --header <header>   Custom HTTP header (format: "Key: Value" or "Key=Value")
  --mock                  Use mock mode (test run without actual generation)
  --help                  Show this message and exit
```

### CLI Examples

**Basic generation:**

```bash
coze-coding-ai image \
  --prompt "A serene mountain landscape with a lake" \
  --output mountain.png \
  --size 4K
```

**Custom size:**

```bash
coze-coding-ai image \
  --prompt "Professional product photography" \
  --output product.png \
  --size 3840x2160
```

**With custom headers:**

```bash
coze-coding-ai image \
  --prompt "A beautiful sunset" \
  --output sunset.png \
  --header "x-custom-field: custom-value" \
  --header "x-request-id: 12345"
```

**Mock mode (testing):**

```bash
coze-coding-ai image \
  --prompt "Test image generation" \
  --output test.png \
  --mock
```

**Get image URL without downloading:**

```bash
coze-coding-ai image \
  --prompt "A futuristic city"
```

## Key Points

- **Size Range**: Custom sizes must be `WIDTHxHEIGHT` within [2560x1440, 4096x4096]
- **Backend Only**: Never expose API keys in client-side code
- **Error Handling**: Always use try-catch blocks and check `helper.success` before accessing results
- **Config Management**: Use `Config` class for proper API authentication
- **Custom Headers**: Use `customHeaders` for mock mode or custom metadata
- **Batch Processing**: Use `batchGenerate()` for parallel execution of multiple prompts
- **Concurrency Control**: Implement manual batching to limit concurrent requests and avoid rate limiting
- **CLI Tool**: Use `coze-coding-ai image` command for quick generation without writing code
- **Response Helper**: Use `getResponseHelper()` for convenient access to results and error handling