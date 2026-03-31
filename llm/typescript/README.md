# LLM (Large Language Model) Skill TypeScript SDK

This skill guides the implementation of large language model functionality using the coze-coding-dev-sdk package and CLI tool, enabling creation of conversational AI applications with advanced features like streaming, thinking mode, and caching.

## Overview

LLM allows you to build applications that leverage powerful language models for text generation, conversational AI, content creation, code generation, and complex reasoning tasks. The SDK provides both streaming and non-streaming interfaces with support for multi-turn conversations.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start


```typescript
import { NextRequest, NextResponse } from "next/server";
import { LLMClient, Config, HeaderUtils } from "coze-coding-dev-sdk";

export async function POST(request: NextRequest) {
  const { prompt } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const config = new Config();
  const client = new LLMClient(config, customHeaders);

  const messages = [{ role: "user", content: prompt }];
  for await (const chunk of stream) {
    if (chunk.content) {
      process.stdout.write(chunk.content.toString());
    }
  }
}
```
**Important**: Always use `stream()` for real-time streaming output by default. Only use `invoke()` for non-streaming responses when explicitly required by the user.

**About Config:**

- `Config` manages SDK configuration including API key, base URL, and timeout settings
- API credentials are automatically loaded from environment variables
- **Optional**: You can pass custom configuration: `new Config({ apiKey: 'your-key', timeout: 30000 })`
- Recommended for production environments to enable proper authentication and error handling

## API Reference

### Client Initialization

```typescript
new LLMClient(config?: Config, customHeaders?: Record<string, string>)
```

**Parameters:**

- `config` (optional): SDK configuration (API key, base URL, timeout). If not provided, default configuration will be used.
- `customHeaders` (optional): Custom HTTP headers to be included in all requests made by this client instance. Commonly used for forwarding request context headers using `HeaderUtils.extractForwardHeaders()`

### Message Format

The SDK supports flexible message formats for conversations:

```typescript
interface Message {
  role: "system" | "user" | "assistant";
  content: string | ContentPart[];
}

interface ContentPart {
  type: "text" | "image_url" | "video_url";
  text?: string;
  image_url?: {
    url: string;
    detail?: "high" | "low";
  };
  video_url?: {
    url: string;
    fps?: number | null;
  };
}
```

**Message Roles:**

- `system`: System prompt that defines AI behavior and role
- `user`: User messages/questions
- `assistant`: AI responses (used in multi-turn conversations)

**Content Formats:**

1. **Text-only (string)**: Simple text messages
2. **Multimodal (array)**: Combine text, images, and videos for vision models

**Text Message Example:**

```typescript
const messages = [
  { role: "system", content: "You are a helpful assistant" },
  { role: "user", content: "Hello!" },
  { role: "assistant", content: "Hi! How can I help you?" },
];
```

**Multimodal Message Example (Vision Models):**

```typescript
const messages = [
  {
    role: "user",
    content: [
      { type: "text", text: "What is in this image?" },
      {
        type: "image_url",
        image_url: {
          url: "https://example.com/image.jpg",
        },
      },
    ],
  },
];
```

**Image Detail Levels:**

- `high`: More detailed analysis, higher cost, slower processing
- `low`: Faster processing, lower cost, less detail
- Default: If not specified, the model will use its default behavior

**Video FPS (Frames Per Second):**

- **Type**: `number | null`
- **Default**: `1`
- **Range**: `[0.2, 5]`
- **Description**: Frame extraction frequency for video understanding
  - Higher values: More sensitive to video changes, higher token cost, slower
  - Lower values: Less sensitive to changes, lower token cost, faster
- **Usage**: Controls how many frames per second are analyzed from the video

**Supported Media Formats:**

**Images:**

- **URL**: HTTP/HTTPS image URLs
- **Base64**: Data URI format (`data:image/jpeg;base64,...`)
- **Formats**: JPEG, PNG, GIF, WebP

**Videos:**

- **URL**: HTTP/HTTPS video URLs
- **Base64**: Data URI format (`data:video/mp4;base64,...`)
- **Formats**: MP4, WebM, AVI, MOV

### invoke() Method

Non-streaming method that returns complete response.

```typescript
client.invoke(
  messages: Message[],
  llmConfig?: LLMConfig,
  previousResponseId?: string
): Promise<LLMResponse>
```

**LLMConfig Interface:**

```typescript
interface LLMConfig {
  model?: string;
  thinking?: "enabled" | "disabled";
  caching?: "enabled" | "disabled";
  temperature?: number;
  streaming?: boolean;
}
```

**Input Parameters:**

| Parameter            | Type        | Default     | Description                      |
| -------------------- | ----------- | ----------- | -------------------------------- |
| `messages`           | `Message[]` | Required    | List of conversation messages    |
| `llmConfig`          | `LLMConfig` | `{}`        | LLM configuration options        |
| `previousResponseId` | `string`    | `undefined` | Previous response ID for caching |

**LLMConfig Parameters:**

| Parameter     | Type      | Default                    | Description                                |
| ------------- | --------- | -------------------------- | ------------------------------------------ |
| `model`       | `string`  | `"doubao-seed-1-8-251228"` | Model ID to use                            |
| `thinking`    | `string`  | `"disabled"`               | Thinking mode: `"enabled"` or `"disabled"` |
| `caching`     | `string`  | `"disabled"`               | Caching mode: `"enabled"` or `"disabled"`  |
| `temperature` | `number`  | `1.0`                      | Output randomness (0-2)                    |
| `streaming`   | `boolean` | `true`                     | Enable streaming (internal use)            |

**LLMResponse Interface:**

```typescript
interface LLMResponse {
  content: string;
}
```

### stream() Method

Streaming method that yields response chunks in real-time.

```typescript
client.stream(
  messages: Message[],
  llmConfig?: LLMConfig,
  previousResponseId?: string
): AsyncGenerator<AIMessageChunk>
```

**Parameters:** Same as `invoke()` method.

**Returns:** AsyncGenerator of message chunks with `content` property.

### Available Models

| Model ID                          | Description                                | Best For                                            |
| --------------------------------- | ------------------------------------------ | --------------------------------------------------- |
| `doubao-seed-2-0-pro-260215`      | Flagship model for complex reasoning       | Multi-step planning, multimodal, long context       |
| `doubao-seed-2-0-lite-260215`     | Balanced performance and cost              | Content creation, data analysis, enterprise tasks   |
| `doubao-seed-2-0-mini-260215`     | Fast response, cost-effective              | Low latency, high concurrency, lightweight tasks    |
| `doubao-seed-1-8-251228`          | Multimodal Agent optimized model (default) | Agent scenarios, multimodal understanding, tool use |
| `doubao-seed-1-6-251015`          | Balanced performance                       | General conversations                               |
| `doubao-seed-1-6-vision-250815`   | Vision model                               | Image/video understanding                           |
| `doubao-seed-1-6-lite-251015`     | Lightweight model                          | Simple tasks, cost-effective                        |
| `deepseek-v3-2-251201`            | DeepSeek V3.2 model                        | Advanced reasoning                                  |
| `glm-4-7-251222`                  | GLM-4-7 model                              | General purpose                                     |
| `deepseek-r1-250528`              | DeepSeek R1 model                          | Research and analysis                               |
| `kimi-k2-5-260127`                | Kimi's most intelligent model              | Agent, code, vision, multimodal tasks               |

### Kimi K2.5 Model Restrictions

For `kimi-k2-5-260127` model, please use default parameter values. The following restrictions apply:

- **max_tokens**: Default is 32k (32768)
- **temperature**: Fixed at `1.0` (thinking mode) or `0.6` (non-thinking mode). Other values will cause errors.
- **top_p**: Fixed at `0.95`. Other values will cause errors.
- **n**: Fixed at `1`. Other values will cause errors.
- **presence_penalty**: Fixed at `0.0`. Other values will cause errors.
- **frequency_penalty**: Fixed at `0.0`. Other values will cause errors.

### Parameter Guidelines

**Temperature (0-2):**

- `0.0-0.3`: Deterministic output (code generation, data analysis)
- `0.7-0.9`: Balanced creativity (general conversation)
- `1.0-2.0`: High creativity (creative writing, brainstorming)

**Thinking Mode:**

- `"enabled"`: Deep reasoning for complex tasks (math, logic, analysis)
- `"disabled"`: Fast response for simple queries

**Caching Mode:**

- `"enabled"`: Cache context for faster follow-up responses
- `"disabled"`: No caching (default)

## Usage Examples

### Basic Chat (Non-Streaming)

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  { role: "user", content: "Explain quantum computing in simple terms" },
];

const response = await client.invoke(messages, { temperature: 0.7 });

console.log(response.content);
```

### Streaming Chat

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [{ role: "user", content: "Tell me a story about AI" }];

const stream = client.stream(messages, { temperature: 0.9 });

for await (const chunk of stream) {
  if (chunk.content) {
    process.stdout.write(chunk.content.toString());
  }
}
```

### Multi-Turn Conversation

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  { role: "system", content: "You are a Python programming expert." },
  { role: "user", content: "What is a decorator?" },
];

const response1 = await client.invoke(messages);
console.log(`AI: ${response1.content}\n`);

messages.push({ role: "assistant", content: response1.content });
messages.push({ role: "user", content: "Can you show me an example?" });

const response2 = await client.invoke(messages);
console.log(`AI: ${response2.content}`);
```

### Chat with System Prompt

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  {
    role: "system",
    content: "You are a professional translator. Translate to French.",
  },
  { role: "user", content: "Hello, how are you?" },
];

const response = await client.invoke(messages, { temperature: 0.3 });
console.log(response.content);
```

### Thinking Mode (Deep Reasoning)

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  { role: "system", content: "You are a math problem solver." },
  {
    role: "user",
    content:
        "If a pond's lily pads double every day and cover the pond in 48 days, how many days to cover half? Explain your reasoning.",
  },
];

const stream = client.stream(messages, {
  model: "doubao-seed-1-8-251228",
  thinking: "enabled",
  temperature: 0.7,
});

for await (const chunk of stream) {
  if (chunk.content) {
    process.stdout.write(chunk.content.toString());
  }
}
```

### Caching for Multi-Turn Conversations

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const systemPrompt = `You are a Python expert. Help users understand Python concepts.
Your answers should be:
1. Clear and concise
2. Include code examples
3. Explain key concepts
4. Provide best practices`;

const messages = [
  { role: "system", content: systemPrompt },
  { role: "user", content: "What is a Python decorator?" },
];

let responseId: string | undefined;
let firstResponse = "";

const stream1 = client.stream(messages, {
  caching: "enabled",
  temperature: 0.7,
});

for await (const chunk of stream1) {
  if (chunk.content) {
    const text = chunk.content.toString();
    process.stdout.write(text);
    firstResponse += text;
  }
}

console.log("\n");

messages.push({ role: "assistant", content: firstResponse });
messages.push({ role: "user", content: "Show me a practical example." });

const stream2 = client.stream(
  messages,
  {
    caching: "enabled",
    temperature: 0.7,
  },
  responseId,
);

for await (const chunk of stream2) {
  if (chunk.content) {
    process.stdout.write(chunk.content.toString());
  }
}
```

### Adjusting Temperature for Different Tasks

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

console.log("Code Generation (temperature=0.2):");
const response1 = await client.invoke(
  [{ role: "user", content: "Write a Python function to sort a list" }],
  { temperature: 0.2 },
);
console.log(response1.content);

console.log("\n" + "=".repeat(60) + "\n");

console.log("Creative Writing (temperature=1.5):");
const response2 = await client.invoke(
  [{ role: "user", content: "Write a creative poem about AI" }],
  { temperature: 1.5 },
);
console.log(response2.content);
```

### Using Different Models

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  { role: "user", content: "Explain the concept of neural networks" },
];

console.log("Using lightweight model:");
const response1 = await client.invoke(messages, {
  model: "doubao-seed-1-6-lite-251015",
  temperature: 0.7,
});
console.log(response1.content);

console.log("\n" + "=".repeat(60) + "\n");

console.log("Using multimodal model:");
const response2 = await client.invoke(messages, {
  model: "doubao-seed-1-8-251228",
  thinking: "enabled",
  temperature: 0.7,
});
console.log(response2.content);
```

### Vision Model - Image Understanding

Use vision models to analyze images with text and image inputs.

**Analyze Image from URL:**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  {
    role: "user",
    content: [
      { type: "text", text: "Describe what you see in this image in detail." },
      {
        type: "image_url",
        image_url: {
          url: "https://example.com/photo.jpg",
          detail: "high",
        },
      },
    ],
  },
];

const response = await client.invoke(messages, {
  model: "doubao-seed-1-6-vision-250815",
  temperature: 0.7,
});

console.log(response.content);
```

**Analyze Local Image (Base64):**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";
import fs from "fs";

const config = new Config();
const client = new LLMClient(config);

const imageBuffer = fs.readFileSync("./image.jpg");
const base64Image = imageBuffer.toString("base64");
const dataUri = `data:image/jpeg;base64,${base64Image}`;

const messages = [
  {
    role: "user",
    content: [
      { type: "text", text: "What objects can you identify in this image?" },
      {
        type: "image_url",
        image_url: {
          url: dataUri,
          detail: "high",
        },
      },
    ],
  },
];

const response = await client.invoke(messages, {
  model: "doubao-seed-1-6-vision-250815",
  temperature: 0.7,
});

console.log(response.content);
```

**Multiple Images Analysis:**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  {
    role: "user",
    content: [
      {
        type: "text",
        text: "Compare these two images and describe the differences.",
      },
      {
        type: "image_url",
        image_url: {
          url: "https://example.com/image1.jpg",
          detail: "high",
        },
      },
      {
        type: "image_url",
        image_url: {
          url: "https://example.com/image2.jpg",
          detail: "high",
        },
      },
    ],
  },
];

const response = await client.invoke(messages, {
  model: "doubao-seed-1-6-vision-250815",
  temperature: 0.7,
});

console.log(response.content);
```

**Vision with Streaming:**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  {
    role: "user",
    content: [
      {
        type: "text",
        text: "Analyze this image and provide a detailed description.",
      },
      {
        type: "image_url",
        image_url: {
          url: "https://example.com/photo.jpg",
        },
      },
    ],
  },
];

const stream = client.stream(messages, {
  model: "doubao-seed-1-6-vision-250815",
  temperature: 0.7,
});

for await (const chunk of stream) {
  if (chunk.content) {
    process.stdout.write(chunk.content.toString());
  }
}
```

**Image Detail Level Comparison:**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const imageUrl = "https://example.com/complex-diagram.jpg";

console.log("Low detail (faster, cheaper):");
const response1 = await client.invoke(
  [
    {
      role: "user",
      content: [
        { type: "text", text: "What is the main subject of this image?" },
        {
          type: "image_url",
          image_url: { url: imageUrl, detail: "low" },
        },
      ],
    },
  ],
  { model: "doubao-seed-1-6-vision-250815" },
);
console.log(response1.content);

console.log("\n" + "=".repeat(60) + "\n");

console.log("High detail (more accurate, slower):");
const response2 = await client.invoke(
  [
    {
      role: "user",
      content: [
        {
          type: "text",
          text: "Describe all the details you can see in this image.",
        },
        {
          type: "image_url",
          image_url: { url: imageUrl, detail: "high" },
        },
      ],
    },
  ],
  { model: "doubao-seed-1-6-vision-250815" },
);
console.log(response2.content);
```

**Analyze Video:**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  {
    role: "user",
    content: [
      {
        type: "text",
        text: "What is happening in this video? Describe the main events.",
      },
      {
        type: "video_url",
        video_url: {
          url: "https://example.com/video.mp4",
          fps: 1,
        },
      },
    ],
  },
];

const response = await client.invoke(messages, {
  model: "doubao-seed-1-6-vision-250815",
  temperature: 0.7,
});

console.log(response.content);
```

**Analyze Local Video (Base64):**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";
import fs from "fs";

const config = new Config();
const client = new LLMClient(config);

const videoBuffer = fs.readFileSync("./video.mp4");
const base64Video = videoBuffer.toString("base64");
const dataUri = `data:video/mp4;base64,${base64Video}`;

const messages = [
  {
    role: "user",
    content: [
      { type: "text", text: "Summarize the content of this video." },
      {
        type: "video_url",
        video_url: {
          url: dataUri,
          fps: 2,
        },
      },
    ],
  },
];

const response = await client.invoke(messages, {
  model: "doubao-seed-1-6-vision-250815",
  temperature: 0.7,
});

console.log(response.content);
```

**Mixed Media Analysis (Image + Video):**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [
  {
    role: "user",
    content: [
      {
        type: "text",
        text: "Compare this image and video. What are the similarities and differences?",
      },
      {
        type: "image_url",
        image_url: {
          url: "https://example.com/scene.jpg",
          detail: "high",
        },
      },
      {
        type: "video_url",
        video_url: {
          url: "https://example.com/scene-video.mp4",
          fps: 1.5,
        },
      },
    ],
  },
];

const stream = client.stream(messages, {
  model: "doubao-seed-1-6-vision-250815",
  temperature: 0.7,
});

for await (const chunk of stream) {
  if (chunk.content) {
    process.stdout.write(chunk.content.toString());
  }
}
```

**Video FPS Comparison:**

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const videoUrl = "https://example.com/action-video.mp4";

console.log("Low FPS (faster, cheaper):");
const response1 = await client.invoke(
  [
    {
      role: "user",
      content: [
        { type: "text", text: "What is the main action in this video?" },
        {
          type: "video_url",
          video_url: { url: videoUrl, fps: 0.5 },
        },
      ],
    },
  ],
  { model: "doubao-seed-1-6-vision-250815" },
);
console.log(response1.content);

console.log("\n" + "=".repeat(60) + "\n");

console.log("High FPS (more detailed, slower):");
const response2 = await client.invoke(
  [
    {
      role: "user",
      content: [
        {
          type: "text",
          text: "Describe all the actions and changes in this video.",
        },
        {
          type: "video_url",
          video_url: { url: videoUrl, fps: 3 },
        },
      ],
    },
  ],
  { model: "doubao-seed-1-6-vision-250815" },
);
console.log(response2.content);
```

**FPS Guidelines:**

- **0.2 - 0.5**: Quick overview, minimal detail, fastest and cheapest
- **1.0** (default): Balanced performance for most use cases
- **2.0 - 3.0**: Detailed analysis, good for action-heavy videos
- **4.0 - 5.0**: Maximum detail, best for frame-by-frame analysis

### Error Handling

```typescript
import { LLMClient, Config, APIError } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

try {
  const messages = [
    { role: "user", content: "What is artificial intelligence?" },
  ];

  const response = await client.invoke(messages);
  console.log("Success:", response.content);
} catch (error) {
  if (error instanceof APIError) {
    console.error("API Error:", error.message);
    console.error("Status Code:", error.statusCode);
  } else {
    console.error("Unexpected error:", error);
  }
}
```

### Streaming with Error Handling

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const messages = [{ role: "user", content: "Tell me about space exploration" }];

try {
  const stream = client.stream(messages, { temperature: 0.8 });

  for await (const chunk of stream) {
    if (chunk.content) {
      process.stdout.write(chunk.content.toString());
    }
  }
  console.log("\n\nStreaming completed successfully");
} catch (error) {
  console.error("\nStreaming error:", error);
}
```

### Custom Headers

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const customHeaders = {
  "x-custom-field": "custom-value",
  "x-request-id": "12345",
};

const client = new LLMClient(config, customHeaders);

const messages = [{ role: "user", content: "Explain machine learning" }];

const response = await client.invoke(messages, { temperature: 0.7 });
console.log(response.content);
```

### Extracting Forward Headers (Required)

**IMPORTANT**: Regardless of which backend framework you use (Next.js, Express, Koa, etc.), you **MUST** extract headers from the incoming request and forward them to the SDK using `HeaderUtils.extractForwardHeaders`. This is required for proper request tracing, authentication, and context propagation.

**IMPORTANT**: This feature requires `coze-coding-dev-sdk` version >=0.7.10. **MUST** check the sdk version before use it.

```typescript
import { HeaderUtils } from "coze-coding-dev-sdk";

// Extract headers from your request object
const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);
```

**Example with Next.js:**

```typescript
import { NextRequest, NextResponse } from "next/server";
import { LLMClient, Config, HeaderUtils } from "coze-coding-dev-sdk";

export async function POST(request: NextRequest) {
  const { prompt } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const config = new Config();
  const client = new LLMClient(config, customHeaders);

  const messages = [{ role: "user", content: prompt }];
  const response = await client.invoke(messages, { temperature: 0.7 });

  return NextResponse.json({ content: response.content });
}
```

**Example with Express:**

```typescript
import express, { Request, Response } from "express";
import { LLMClient, Config, HeaderUtils } from "coze-coding-dev-sdk";

const app = express();
app.use(express.json());

app.post("/api/chat", async (req: Request, res: Response) => {
  const { prompt } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(
    req.headers as Record<string, string>,
  );

  const config = new Config();
  const client = new LLMClient(config, customHeaders);

  const messages = [{ role: "user" as const, content: prompt }];
  const response = await client.invoke(messages, { temperature: 0.7 });

  res.json({ content: response.content });
});
```

### Conversation History Management

```typescript
import { LLMClient, Config } from "coze-coding-dev-sdk";

const config = new Config();
const client = new LLMClient(config);

const conversationHistory: Array<{
  role: "system" | "user" | "assistant";
  content: string;
}> = [{ role: "system", content: "You are a helpful coding assistant." }];

async function chat(userMessage: string): Promise<string> {
  conversationHistory.push({ role: "user", content: userMessage });

  const response = await client.invoke(conversationHistory, {
    temperature: 0.7,
  });

  conversationHistory.push({ role: "assistant", content: response.content });

  return response.content;
}

const response1 = await chat("What is TypeScript?");
console.log("AI:", response1);

const response2 = await chat("How is it different from JavaScript?");
console.log("AI:", response2);

const response3 = await chat("Show me a simple example");
console.log("AI:", response3);
```

## CLI Usage

The SDK includes a command-line tool `coze-coding-ai` for quick chat without writing code.

### Basic CLI Usage

```bash
coze-coding-ai chat --prompt "What is artificial intelligence?"
```

### CLI Options

```bash
coze-coding-ai chat [OPTIONS]

Options:
  -p, --prompt <text>       User message content [required]
  -s, --system <text>       System prompt for custom behavior
  --model <model>           Model to use (default: doubao-seed-1-8-251228)
  --temperature <number>    Temperature (0-2, default: 0.7)
  --stream                  Enable streaming output
  -H, --header <header>     Custom HTTP header (format: "Key: Value" or "Key=Value")
  --help                    Show this message and exit
```

### CLI Examples

**Basic chat:**

```bash
coze-coding-ai chat --prompt "Explain quantum computing"
```

**Chat with system prompt:**

```bash
coze-coding-ai chat \
  --prompt "Translate 'Hello' to French" \
  --system "You are a professional translator"
```

**Streaming response:**

```bash
coze-coding-ai chat \
  --prompt "Tell me a story about AI" \
  --stream
```

**Custom model and temperature:**

```bash
coze-coding-ai chat \
  --prompt "Write a creative poem" \
  --model doubao-seed-1-8-251228 \
  --temperature 1.5
```

**With custom headers:**

```bash
coze-coding-ai chat \
  --prompt "Explain machine learning" \
  --header "x-custom-field: custom-value" \
  --header "x-request-id: 12345"
```

**Combined options:**

```bash
coze-coding-ai chat \
  --prompt "Write a Python decorator example" \
  --system "You are a Python expert" \
  --model doubao-seed-1-8-251228 \
  --temperature 0.3 \
  --stream
```

## Key Points

- **Message Format**: Use simple message objects with `role` and `content` properties
- **Backend Only**: Never expose API keys in client-side code
- **Streaming vs Non-Streaming**: Use `stream()` for real-time output, `invoke()` for complete response
- **Config Management**: Use `Config` class for proper API authentication
- **Temperature Control**: Adjust based on task (low for factual, high for creative)
- **Thinking Mode**: Enable for complex reasoning tasks (math, logic, analysis)
- **Caching**: Use for multi-turn conversations to improve performance and reduce costs
- **Model Selection**: 8 models available - choose based on task requirements (speed, reasoning, vision, context length)
- **Error Handling**: Always use try-catch blocks for robust error handling
- **Conversation History**: Maintain message history for multi-turn conversations
- **Custom Headers**: Pass `customHeaders` to the constructor for request context headers
- **CLI Tool**: Use `coze-coding-ai chat` command for quick interactions without code
- **LangChain Integration**: Built on LangChain for compatibility with LangChain ecosystem
- **Async Generators**: Stream method returns AsyncGenerator for efficient streaming
