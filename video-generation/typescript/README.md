# Video Generation Skill TypeScript SDK

This skill guides the implementation of video generation functionality using the coze-coding-dev-sdk package and CLI tool, enabling creation of high-quality videos from text descriptions and images.

## Overview

Video Generation allows you to build applications that create video content from text prompts and/or images using AI models, enabling creative workflows, animation automation, and video content production.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

**Video URL Storage**: The returned video URLs are already stored in object storage with a valid expiration period. Unless absolutely necessary, you should use these URLs directly without re-uploading to your own object storage system

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Extracting Forward Headers (Required)

**IMPORTANT**: Regardless of which backend framework you use (Next.js, Express, Koa, etc.), you **MUST** extract headers from the incoming request and forward them to the SDK using `HeaderUtils.extractForwardHeaders`. This is required for proper request tracing, authentication, and context propagation.

```typescript
import { HeaderUtils } from 'coze-coding-dev-sdk';

// Extract headers from your request object
const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

// Pass customHeaders to your VideoGenerationClient
const client = new VideoGenerationClient({
  customHeaders,
});
```

**Example with Next.js:**

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { VideoGenerationClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

export async function POST(request: NextRequest) {
  const { prompt } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const config = new Config();
  const client = new VideoGenerationClient(config, { customHeaders });

  const content = [{ type: 'text' as const, text: prompt }];
  const response = await client.videoGeneration(content, {
    model: 'doubao-seedance-1-5-pro-251215',
    duration: 5,
  });

  return NextResponse.json({ videoUrl: response.videoUrl });
}
```

**Example with Express:**

```typescript
import express, { Request, Response } from 'express';
import { VideoGenerationClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

const app = express();
app.use(express.json());

app.post('/api/video', async (req: Request, res: Response) => {
  const { prompt } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(req.headers as Record<string, string>);

  const config = new Config();
  const client = new VideoGenerationClient(config, { customHeaders });

  const content = [{ type: 'text' as const, text: prompt }];
  const response = await client.videoGeneration(content, {
    model: 'doubao-seedance-1-5-pro-251215',
    duration: 5,
  });

  res.json({ videoUrl: response.videoUrl });
});
```

## Quick Start

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new VideoGenerationClient(config);

const content = [
  {
    type: 'text' as const,
    text: 'A serene mountain landscape with flowing clouds',
  },
];

const response = await client.videoGeneration(content, {
  model: 'doubao-seedance-1-5-pro-251215',
  duration: 5,
  ratio: '16:9',
  resolution: '720p',
});

if (response.videoUrl) {
  const videoData = await axios.get(response.videoUrl, { responseType: 'arraybuffer' });
  fs.writeFileSync('output.mp4', videoData.data);
  console.log('Video saved to output.mp4');
}
```

**About Config:**

- `Config` manages SDK configuration including API key, base URL, and timeout settings
- API credentials are automatically loaded from environment variables
- **Optional**: You can pass custom configuration: `new Config({ apiKey: 'your-key', timeout: 60000 })`
- Recommended for production environments to enable proper authentication and error handling

## Available Models

The SDK currently supports the following video generation model:

### doubao-seedance-1-5-pro-251215 (Default)

Latest professional model with enhanced capabilities:

- **Text-to-Video**: Generate videos from text prompts with optional audio
- **Image-to-Video (First Frame)**: Generate videos starting from a first frame image
- **Image-to-Video (First & Last Frame)**: Generate videos with controlled start and end frames
- **Audio Generation**: Automatically generate synchronized audio including voice, sound effects, and background music
- **Smart Duration**: Support 4-12 seconds duration, or let the model choose automatically (duration: -1)
- **Smart Aspect Ratio**: Intelligently select the best aspect ratio for text-to-video (ratio: 'adaptive')
- **Supported Resolutions**: 480p, 720p, 1080p

> **Note**: Reference images (`role: 'reference_image'`) are NOT supported by doubao-seedance-1-5-pro-251215. Only `first_frame` and `last_frame` roles are supported for image-to-video generation.

## API Reference

### Client Initialization

```typescript
new VideoGenerationClient(
  config?: Config,
  customHeaders?: Record<string, string>
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `customHeaders`: Custom HTTP headers (e.g., `{ "x-run-mode": "test_run" }`)

### videoGeneration() Method

```typescript
client.videoGeneration(
  contentItems: Content[],
  options?: {
    callbackUrl?: string;
    returnLastFrame?: boolean;
    model?: string;
    maxWaitTime?: number;
    resolution?: Resolution;
    ratio?: Ratio;
    duration?: number;
    watermark?: boolean;
    seed?: number;
    camerafixed?: boolean;
    generateAudio?: boolean;
  }
): Promise<VideoGenerationResponse>
```

**Content Interface:**

```typescript
type Content = TextContent | ImageURLContent;

interface TextContent {
  type: 'text';
  text: string;
}

interface ImageURLContent {
  type: 'image_url';
  image_url: {
    url: string;
  };
  role?: 'first_frame' | 'last_frame' | 'reference_image';
}
```

**Input Parameters:**

| Parameter               | Type                                                                  | Default                            | Description                                                               |
| ----------------------- | --------------------------------------------------------------------- | ---------------------------------- | ------------------------------------------------------------------------- |
| `contentItems`          | `Content[]`                                                           | Required                           | Array of text and/or image content items                                  |
| `options.model`         | `string`                                                              | `'doubao-seedance-1-5-pro-251215'` | Model name (see Available Models section)                                 |
| `options.maxWaitTime`   | `number`                                                              | `900`                              | Maximum wait time in seconds                                              |
| `options.resolution`    | `'480p' \| '720p' \| '1080p'`                                         | `'720p'`                           | Video resolution                  |
| `options.ratio`         | `'16:9' \| '9:16' \| '1:1' \| '4:3' \| '3:4' \| '21:9' \| 'adaptive'` | `'16:9'`                           | Aspect ratio ('adaptive' for smart selection in text-to-video)            |
| `options.duration`      | `number`                                                              | `5`                                | Video duration in seconds (4-12s for 1.5 pro, or -1 for smart selection)  |
| `options.watermark`     | `boolean`                                                             | `true`                             | Add watermark to generated video                                          |
| `options.seed`          | `number`                                                              | `undefined`                        | Random seed for reproducible results                                      |
| `options.camerafixed`   | `boolean`                                                             | `false`                            | Fix camera position                                                       |
| `options.generateAudio` | `boolean`                                                             | `true`                             | Generate synchronized audio (1.5 pro only). Set to false for silent video |
| `options.callbackUrl`   | `string`                                                              | `undefined`                        | Callback URL for async notification                                       |
| `options.returnLastFrame` | `boolean`                                                           | `false`                            | Return the last frame of the video                                        |

**Response Interface:**

```typescript
interface VideoGenerationResponse {
  videoUrl: string | null;
  response: VideoGenerationTask;
  lastFrameUrl: string;
}

interface VideoGenerationTask {
  id: string;
  model?: string;
  status: 'queued' | 'running' | 'succeeded' | 'failed' | 'cancelled';
  content?: {
    video_url?: string;
    last_frame_url?: string;
  };
  seed?: number;
  resolution?: '480p' | '720p' | '1080p';
  ratio?: '16:9' | '9:16' | '1:1';
  duration?: number;
  framespersecond?: number;
  usage?: {
    completion_tokens?: number;
    total_tokens?: number;
  };
  created_at?: number;
  updated_at?: number;
  error_message?: string;
}
```

**Response Properties:**

```typescript
response.videoUrl; // The generated video URL (null if failed)
response.lastFrameUrl; // The last frame image URL (if requested)
response.response; // Full task response with metadata
response.response.status; // Task status: 'succeeded', 'failed', etc.
response.response.id; // Task ID for tracking
```

## Usage Examples

### Text-to-Video Generation

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

const content = [
  {
    type: 'text' as const,
    text: 'A futuristic city with flying vehicles at sunset, cinematic camera movement',
  },
];

const response = await client.videoGeneration(content, {
  model: 'doubao-seedance-1-5-pro-251215',
  duration: 5,
  ratio: '16:9',
  resolution: '720p',
});

const videoUrl = response.videoUrl;
```

### Image-to-Video (First Frame)

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

const content = [
  {
    type: 'image_url' as const,
    image_url: {
      url: 'https://example.com/first-frame.jpg',
    },
    role: 'first_frame' as const,
  },
  {
    type: 'text' as const,
    text: 'Camera slowly zooms in, gentle wind blowing',
  },
];

const response = await client.videoGeneration(content, {
  model: 'doubao-seedance-1-5-pro-251215',
  duration: 5,
  ratio: '16:9',
});

const videoUrl = response.videoUrl;
```

### Image-to-Video (First & Last Frame)

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

const content = [
  {
    type: 'image_url' as const,
    image_url: {
      url: 'https://example.com/start.jpg',
    },
    role: 'first_frame' as const,
  },
  {
    type: 'image_url' as const,
    image_url: {
      url: 'https://example.com/end.jpg',
    },
    role: 'last_frame' as const,
  },
  {
    type: 'text' as const,
    text: 'Smooth transition between scenes',
  },
];

const response = await client.videoGeneration(content, {
  model: 'doubao-seedance-1-5-pro-251215',
  duration: 5,
  ratio: '16:9',
});

const videoUrl = response.videoUrl;
```

### Image-to-Video (Reference Images)

> **Warning**: Reference images (`role: 'reference_image'`) are NOT supported by doubao-seedance-1-5-pro-251215. The following example is for reference only and will not work with the current model. Use `first_frame` and `last_frame` roles instead.

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

const content = [
  {
    type: 'image_url' as const,
    image_url: {
      url: 'https://example.com/ref1.jpg',
    },
    role: 'reference_image' as const,
  },
  {
    type: 'image_url' as const,
    image_url: {
      url: 'https://example.com/ref2.jpg',
    },
    role: 'reference_image' as const,
  },
  {
    type: 'image_url' as const,
    image_url: {
      url: 'https://example.com/ref3.jpg',
    },
    role: 'reference_image' as const,
  },
  {
    type: 'text' as const,
    text: 'Create a dynamic video based on these reference images',
  },
];

const response = await client.videoGeneration(content, {
  model: 'doubao-seedance-1-0-lite-i2v-250428',
  duration: 5,
  ratio: '16:9',
});

const videoUrl = response.videoUrl;
```

### Video with Audio (Seedance 1.5 Pro)

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

const content = [
  {
    type: 'text' as const,
    text: 'A man calls out to a woman and says: "Remember, you must never point at the moon with your finger."',
  },
];

const response = await client.videoGeneration(content, {
  model: 'doubao-seedance-1-5-pro-251215',
  duration: 8,
  ratio: '16:9',
  resolution: '720p',
  generateAudio: true,
});

const videoUrl = response.videoUrl;
```

### Custom Headers for Testing

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();

const customHeaders = {
  'x-custom-field': 'custom-value',
};

const client = new VideoGenerationClient(config, customHeaders);

const content = [
  {
    type: 'text' as const,
    text: 'A serene beach scene with gentle waves',
  },
];

const response = await client.videoGeneration(content, {
  model: 'doubao-seedance-1-5-pro-251215',
  duration: 5,
  ratio: '16:9',
});

const videoUrl = response.videoUrl;
```

### Error Handling

```typescript
import { VideoGenerationClient, Config, APIError } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

try {
  const content = [
    {
      type: 'text' as const,
      text: 'A beautiful landscape video',
    },
  ];

  const response = await client.videoGeneration(content, {
    model: 'doubao-seedance-1-5-pro-251215',
    duration: 5,
    ratio: '16:9',
  });

  const videoUrl = response.videoUrl;
} catch (error) {
  if (error instanceof APIError) {
    throw error;
  } else {
    throw error;
  }
}
```

### Batch Generation (Sequential)

For generating multiple videos, you can call `videoGeneration()` sequentially or use `Promise.all()` for parallel execution:

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

const prompts = ['A sunset over mountains', 'A futuristic cityscape', 'A serene beach scene'];

const videoUrls: string[] = [];
for (const promptText of prompts) {
  const content = [{ type: 'text' as const, text: promptText }];

  const response = await client.videoGeneration(content, {
    model: 'doubao-seedance-1-5-pro-251215',
    duration: 5,
    ratio: '16:9',
  });

  if (response.videoUrl) {
    videoUrls.push(response.videoUrl);
  }
}
```

**Parallel Generation with Concurrency Control:**

```typescript
import { VideoGenerationClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

async function generateWithConcurrencyLimit(prompts: string[], maxConcurrent: number = 2) {
  const results = [];

  for (let i = 0; i < prompts.length; i += maxConcurrent) {
    const batch = prompts.slice(i, i + maxConcurrent);

    const batchPromises = batch.map(promptText => {
      const content = [{ type: 'text' as const, text: promptText }];
      return client.videoGeneration(content, {
        model: 'doubao-seedance-1-5-pro-251215',
        duration: 5,
        ratio: '16:9',
      });
    });

    const batchResults = await Promise.all(batchPromises);
    results.push(...batchResults);
  }

  return results;
}

const prompts = [
  'A sunset over mountains',
  'A futuristic cityscape',
  'A serene beach scene',
  'A tropical rainforest',
  'A snowy mountain peak',
];

const responses = await generateWithConcurrencyLimit(prompts, 2);

const videoUrls = responses.filter(r => r.videoUrl).map(r => r.videoUrl);
```

### Sequential Video Generation (Video Consistency)

Use the last frame of the previous video as the first frame of the next video to maintain visual consistency across multiple video segments:

```typescript
import { VideoGenerationClient, Config, Content } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoGenerationClient(config);

const scenePrompts = [
  'A girl walking through a forest path, morning light filtering through trees',
  'The girl discovers a hidden waterfall, camera slowly approaching',
  'The girl sits by the waterfall, peaceful atmosphere, birds flying',
];

const videoUrls: string[] = [];
let lastFrameUrl: string | null = null;

for (const prompt of scenePrompts) {
  const contentItems: Content[] = [{ type: 'text', text: prompt }];

  if (lastFrameUrl) {
    contentItems.unshift({ type: 'image_url', image_url: { url: lastFrameUrl } });
  }

  const response = await client.videoGeneration(contentItems, {
    model: 'doubao-seedance-1-5-pro-251215',
    resolution: '720p',
    ratio: '16:9',
    duration: 5,
    returnLastFrame: true,
  });

  if (response.videoUrl) {
    videoUrls.push(response.videoUrl);
    lastFrameUrl = response.lastFrameUrl || null;
  }
}

const finalVideos = videoUrls;
```

**Key Points:**
- Set `returnLastFrame: true` to get the last frame URL of each generated video
- Use `image_url` content type to pass the last frame as the first frame of the next video
- This ensures smooth visual transitions between consecutive video segments
- Ideal for creating story-driven or continuous scene videos

## CLI Usage

The SDK includes a command-line tool `coze-coding-ai` for quick video generation without writing code.

### Basic CLI Usage

```bash
coze-coding-ai video --model doubao-seedance-1-5-pro-251215 --prompt "A futuristic city at sunset" --output result.json
```

### CLI Options

```bash
coze-coding-ai video [OPTIONS]

Options:
  -m, --model <model>           Model name (default: doubao-seedance-1-5-pro-251215)
  -p, --prompt <text>           Text description of the video
  -i, --image-url <url>         Image URL (single or comma-separated for first/last frame)
  -s, --size <size>             Video resolution (e.g., 1280x720)
  -d, --duration <seconds>      Video duration in seconds (default: 5, or -1 for smart selection)
  -o, --output <path>           Output file path (JSON format)
  --callback-url <url>          Callback URL for async notification
  --return-last-frame           Return last frame image
  --watermark                   Add watermark to video
  --seed <number>               Random seed for reproducible results
  --camerafixed                 Fix camera position
  --generate-audio              Generate synchronized audio (default: true)
  --no-audio                    Generate silent video
  -H, --header <header>         Custom HTTP header (format: "Key: Value" or "Key=Value")
  --mock                        Use mock mode (test run)
  --verbose                     Enable verbose logging
  --help                        Show this message and exit
```

### CLI Examples

**Text-to-Video:**

```bash
coze-coding-ai video \
  --model doubao-seedance-1-5-pro-251215 \
  --prompt "A serene mountain landscape with flowing clouds" \
  --output mountain.json \
  --duration 5 \
  --size 1280x720
```

**Image-to-Video (First Frame):**

```bash
coze-coding-ai video \
  --model doubao-seedance-1-5-pro-251215 \
  --image-url "https://example.com/first.jpg" \
  --prompt "Camera slowly zooms in" \
  --output animation.json \
  --duration 5
```

**Image-to-Video (First & Last Frame):**

```bash
coze-coding-ai video \
  --model doubao-seedance-1-5-pro-251215 \
  --image-url "https://example.com/start.jpg,https://example.com/end.jpg" \
  --prompt "Smooth transition" \
  --output transition.json
```

**With Audio Generation:**

```bash
coze-coding-ai video \
  --model doubao-seedance-1-5-pro-251215 \
  --prompt "A man says: 'Hello, welcome to the future!'" \
  --output audio_video.json \
  --generate-audio
```
**Mock mode (testing):**

```bash
coze-coding-ai video \
  --model doubao-seedance-1-5-pro-251215 \
  --prompt "Test video generation" \
  --output test.json \
  --mock
```
**With reproducible seed:**

```bash
coze-coding-ai video \
  --model doubao-seedance-1-5-pro-251215 \
  --prompt "A magical forest" \
  --output forest.json \
  --seed 42
```

**With verbose logging:**

```bash
coze-coding-ai video \
  --model doubao-seedance-1-5-pro-251215 \
  --prompt "A beautiful landscape" \
  --output landscape.json \
  --verbose
```

## Model Selection Guide

The SDK currently only supports **doubao-seedance-1-5-pro-251215** model:

### doubao-seedance-1-5-pro-251215 (Default)

- **Latest model with enhanced capabilities**
- Audio-synchronized video generation
- First & last frame control for image-to-video
- Complex scene transitions with audio
- Professional video production with voice, sound effects, and background music
- Smart duration selection (4-12 seconds or auto with duration: -1)
- Smart aspect ratio selection for text-to-video (ratio: 'adaptive')
- **Note**: Supports 480p, 720p, and 1080p resolutions
- **Note**: Reference images are NOT supported

## Key Points

- **Backend Only**: Never expose API keys in client-side code
- **Model Selection**: Only `doubao-seedance-1-5-pro-251215` is supported (default model with audio support)
- **Content Array**: Use `Content[]` array to pass text prompts and image URLs with specific roles
- **Image Roles**: Specify image roles as `first_frame` or `last_frame` (reference_image is NOT supported)
- **Duration Options**:
  - Supports 4-12 seconds, or -1 for smart selection
  - Smart selection lets the model choose the optimal duration
- **Aspect Ratios**: Support for 16:9, 9:16, 1:1, 4:3, 3:4, 21:9, and 'adaptive' (smart selection for text-to-video)
- **Resolution Options**: 480p, 720p, and 1080p
- **Audio Generation**:
  - Enabled by default (`generate_audio: true`)
  - Generates synchronized voice, sound effects, and background music
  - Set `generate_audio: false` for silent videos
  - Place dialogue in quotes for better audio generation (e.g., 'He says: "Hello"')
- **Error Handling**: Always use try-catch blocks and check `response.videoUrl` for success
- **Config Management**: Use `Config` class for proper API authentication
- **Custom Headers**: Use `customHeaders` for mock mode or custom metadata
- **Async Processing**: The `videoGeneration()` method waits for completion (polling-based)
- **Task Tracking**: Access task details via `response.response.id` and `response.response.status`
- **Concurrency Control**: Implement manual batching with `Promise.all()` to limit concurrent requests (video generation is resource-intensive)
- **CLI Tool**: Use `coze-coding-ai video` command for quick generation without writing code
- **Response Structure**: Response contains `videoUrl`, `lastFrameUrl`, and full `response` object with task metadata
- **Reproducibility**: Use the `seed` parameter in config for reproducible results
- **Camera Control**: Use `camerafixed` option to fix camera position during generation
- **Watermark**: Watermark is enabled by default, set `watermark: false` to disable
- **Verbose Logging**: Enable `verbose` mode in constructor for detailed HTTP request logging