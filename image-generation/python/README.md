# Image Generation Skill Python SDK

This skill guides the implementation of image generation functionality using the coze-coding-dev-sdk package and CLI tool, enabling creation of high-quality images from text descriptions.

## Overview

Image Generation allows you to build applications that create visual content from text prompts using AI models, enabling creative workflows, design automation, and visual content production.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

```python
from coze_coding_dev_sdk import ImageGenerationClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
import requests

ctx = new_context(method="generate")

client = ImageGenerationClient(ctx=ctx)

response = client.generate(
    prompt="A futuristic city with flying vehicles at sunset",
    size="2K"
)

if response.success:
    img_data = requests.get(response.image_urls[0]).content
    with open("output.png", 'wb') as f:
        f.write(img_data)
```

**About Context (`ctx`):**

- `Context` is used for request tracking and tracing across distributed systems
- It automatically injects headers like `request_id`, `trace_id`, and `user_id` into API calls
- **Optional**: If you don't need request tracking, you can omit `ctx` parameter: `ImageGenerationClient()`
- Recommended for production environments to enable observability and debugging

## API Reference

### Client Initialization

```python
ImageGenerationClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None,
    custom_headers: Optional[Dict[str, str]] = None
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `ctx`: Context for request tracking (request_id, trace_id, user_id)
- `custom_headers`: Custom HTTP headers (e.g., `{"x-run-mode": "test_run"}`)

### generate() Method

```python
client.generate(
    prompt: str,
    size: Optional[str] = "2K",
    watermark: Optional[bool] = True,
    image: Optional[Union[str, List[str]]] = None,
    response_format: Optional[str] = "url",
    optimize_prompt_mode: Optional[str] = "standard",
    sequential_image_generation: Optional[str] = "disabled",
    sequential_image_generation_max_images: Optional[int] = 15
) -> ImageGenerationResponse
```

**Input Parameters:**

| Parameter                                | Type             | Default      | Description                                                             |
| ---------------------------------------- | ---------------- | ------------ | ----------------------------------------------------------------------- |
| `prompt`                                 | `str`            | Required     | Text description for image generation                                   |
| `size`                                   | `str`            | `"2K"`       | Image size: `"2K"`, `"4K"`, or `"WIDTHxHEIGHT"` (2560x1440 ~ 4096x4096) |
| `watermark`                              | `bool`           | `True`       | Add watermark to generated images                                       |
| `image`                                  | `str\|List[str]` | `None`       | Reference image URL(s) for image-to-image generation                    |
| `response_format`                        | `str`            | `"url"`      | Response format: `"url"` or `"b64_json"`                                |
| `optimize_prompt_mode`                   | `str`            | `"standard"` | Prompt optimization mode                                                |
| `sequential_image_generation`            | `str`            | `"disabled"` | Sequential generation: `"auto"` or `"disabled"`                         |
| `sequential_image_generation_max_images` | `int`            | `15`         | Max images for sequential generation (1-15)                             |

**Response Object:**

```python
class ImageGenerationResponse:
    model: str
    created: int
    data: List[ImageData]
    usage: Optional[UsageInfo]
    error: Optional[dict]

    @property
    def success(self) -> bool

    @property
    def image_urls(self) -> List[str]

    @property
    def image_b64_list(self) -> List[str]

    @property
    def error_messages(self) -> List[str]
```

**ImageData Fields:**

- `url`: Image URL (when `response_format="url"`)
- `b64_json`: Base64 encoded image (when `response_format="b64_json"`)
- `size`: Generated image size
- `error`: Error details if generation failed

**UsageInfo Fields:**

- `generated_images`: Number of images generated
- `output_tokens`: Output tokens used
- `total_tokens`: Total tokens used

## Usage Examples

### Basic Generation with Custom Headers

```python
from coze_coding_dev_sdk import ImageGenerationClient
from coze_coding_utils.runtime_ctx.context import Context, new_context

ctx = new_context(method="generate")

custom_headers = {
    "x-custom-field": "custom-value",
}

client = ImageGenerationClient(ctx=ctx, custom_headers=custom_headers)

response = client.generate(
    prompt="A serene mountain landscape",
    size="4K"
)
```

### Image-to-Image Generation

```python
from coze_coding_dev_sdk import ImageGenerationClient
from coze_coding_utils.runtime_ctx.context import Context, new_context

ctx = new_context(method="generate")

client = ImageGenerationClient(ctx=ctx)

response = client.generate(
    prompt="Transform into anime style",
    image="https://example.com/input.jpg",
    size="2K"
)
```

### Sequential Image Generation

```python
from coze_coding_dev_sdk import ImageGenerationClient
from coze_coding_utils.runtime_ctx.context import Context, new_context

ctx = new_context(method="generate")

client = ImageGenerationClient(ctx=ctx)

response = client.generate(
    prompt="A story of a cat's adventure",
    sequential_image_generation="auto",
    sequential_image_generation_max_images=5,
    size="2K"
)

print(f"Generated {len(response.image_urls)} images")
```

### Base64 Response Format

```python
import base64
from coze_coding_dev_sdk import ImageGenerationClient
from coze_coding_utils.runtime_ctx.context import Context, new_context

ctx = new_context(method="generate")

client = ImageGenerationClient(ctx=ctx)

response = client.generate(
    prompt="A modern office workspace",
    response_format="b64_json",
    size="2K"
)

for i, b64_data in enumerate(response.image_b64_list):
    img_data = base64.b64decode(b64_data)
    with open(f"image_{i}.png", 'wb') as f:
        f.write(img_data)
```

### Extract URLs from Response

Use `extract_urls()` to get a unified list of image URLs from the response, regardless of the response format:

```python
from coze_coding_dev_sdk import ImageGenerationClient
from coze_coding_utils.runtime_ctx.context import Context, new_context

ctx = new_context(method="generate")

client = ImageGenerationClient(ctx=ctx)

response = client.generate(
    prompt="A beautiful landscape",
    size="2K"
)

urls = client.extract_urls(response)

for i, url in enumerate(urls):
    print(f"Image {i+1}: {url}")
```

**Note**:

- For `response_format="url"`: Returns direct HTTP URLs
- For `response_format="b64_json"`: Returns data URIs in format `data:image/png;base64,{base64_data}`
- Automatically raises `APIError` if any image generation failed

### Multiple Prompts Parallel Generation

For generating images from multiple prompts, use **async mode** for parallel execution to improve performance:

```python
import asyncio
from coze_coding_dev_sdk import ImageGenerationClient
from coze_coding_utils.runtime_ctx.context import Context, new_context

ctx = new_context(method="generate")

client = ImageGenerationClient(ctx=ctx)

async def generate_multiple_images():
    prompts = [
        "A sunset over mountains",
        "A futuristic cityscape",
        "A serene beach scene"
    ]

    tasks = [
        client.generate_async(prompt=prompt, size="2K")
        for prompt in prompts
    ]

    responses = await asyncio.gather(*tasks)

    for i, response in enumerate(responses):
        if response.success:
            print(f"Image {i+1}: {response.image_urls[0]}")
        else:
            print(f"Image {i+1} failed: {response.error_messages}")

asyncio.run(generate_multiple_images())
```

**Concurrency Control** (limit concurrent requests):

```python
import asyncio
from coze_coding_dev_sdk import ImageGenerationClient
from coze_coding_utils.runtime_ctx.context import Context, new_context

ctx = new_context(method="generate")

client = ImageGenerationClient(ctx=ctx)

async def generate_with_concurrency_limit():
    prompts = [
        "A sunset over mountains",
        "A futuristic cityscape",
        "A serene beach scene",
        "A tropical rainforest",
        "A snowy mountain peak"
    ]

    semaphore = asyncio.Semaphore(3)

    async def generate_with_semaphore(prompt: str):
        async with semaphore:
            return await client.generate_async(prompt=prompt, size="2K")

    tasks = [generate_with_semaphore(prompt) for prompt in prompts]
    responses = await asyncio.gather(*tasks)

    for i, response in enumerate(responses):
        if response.success:
            print(f"Image {i+1}: {response.image_urls[0]}")

asyncio.run(generate_with_concurrency_limit())
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
  -p, --prompt TEXT       Text description of the image [required]
  -o, --output PATH       Output file path [required]
  -s, --size TEXT         Image size: 2K, 4K, or WIDTHxHEIGHT (default: 2K)
  -i, --image TEXT        Reference image URL or path (for image-to-image)
  --images TEXT           Multiple reference images (can be used multiple times)
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

**Image-to-image generation:**

```bash
coze-coding-ai image \
  --prompt "Transform into anime style" \
  --image https://example.com/photo.jpg \
  --output anime_style.png
```

**Multiple reference images:**

```bash
coze-coding-ai image \
  --prompt "Combine these styles" \
  --images https://example.com/style1.jpg \
  --images https://example.com/style2.jpg \
  --output combined.png
```

**Mock mode (testing):**

```bash
coze-coding-ai image \
  --prompt "Test image generation" \
  --output test.png \
  --mock
```

## Key Points

- **Size Range**: Custom sizes must be `WIDTHxHEIGHT` within [2560x1440, 4096x4096]
- **Backend Only**: Never expose API keys in client-side code
- **Error Handling**: Always check `response.success` before accessing results
- **Context Tracking**: Use `ctx` parameter for request tracing in production
- **Custom Headers**: Use `custom_headers` for mock mode or custom metadata
- **Async Support**: For multiple prompts, use `generate_async()` with `asyncio.gather()` for parallel execution
- **Concurrency Control**: Use `asyncio.Semaphore` to limit concurrent requests and avoid rate limiting
- **CLI Tool**: Use `coze-coding-ai image` command for quick generation without writing code
- **Image URL Storage**: The returned image URLs are already stored in object storage with a valid expiration period. Unless absolutely necessary, you should use these URLs directly without re-uploading to your own object storage system