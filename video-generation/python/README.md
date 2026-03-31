# Video Generation Skill Python SDK

This skill guides the implementation of video generation functionality using the coze-coding-dev-sdk package and CLI tool, enabling creation of high-quality videos from text descriptions and images.

## Overview

Video Generation allows you to build applications that create video content from text prompts and/or images using AI models, enabling creative workflows, animation automation, and video content production.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

```python
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="video.generate")

client = VideoGenerationClient(ctx=ctx)

video_url, response, last_frame_url = client.video_generation(
    content_items=[
        TextContent(text="A futuristic city with flying vehicles at sunset")
    ],
    model="doubao-seedance-1-5-pro-251215",
    resolution="720p",
    ratio="16:9",
    duration=5,
    watermark=False
)

if video_url:
    print(f"Video URL: {video_url}")
```

**About Context (`ctx`):**

- `Context` is used for request tracking and tracing across distributed systems
- Created using `new_context(method="service.operation")` factory function
- Automatically generates `run_id` and reads `space_id`, `project_id` from environment variables
- It automatically injects headers like `logid`, `run_id`, `space_id` into API calls
- **Optional**: If you don't need request tracking, you can omit `ctx` parameter: `VideoGenerationClient()`
- Recommended for production environments to enable observability and debugging

## Supported Models

⚠️ **Currently Supported Model**: The SDK currently only supports the following model:

- **doubao-seedance-1-5-pro-251215**: Latest pro model with full capabilities (default)

### Model Capabilities

**doubao-seedance-1-5-pro-251215** supports:

- **Text-to-Video**: Generate video from text prompt + optional parameters
- **Image-to-Video (First Frame)**: Generate video from first frame + optional text prompt + optional parameters
- **Image-to-Video (First & Last Frame)**: Generate video from first frame + last frame + optional text prompt +
  optional parameters

> ⚠️ **Not Supported**: Image-to-Video with reference images (`role="reference_image"`) is NOT supported by this model.

## API Reference

### Client Initialization

```python
VideoGenerationClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None,
    custom_headers: Optional[Dict[str, str]] = None,
    verbose: bool = False
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `ctx`: Optional context for tracing and monitoring
- `custom_headers`: Custom HTTP headers (e.g., `{"x-run-mode": "test_run"}` **Note: Do NOT include this parameter in production code. It is only for internal testing purposes.**). 
- `verbose`: Enable verbose HTTP request logging

### video_generation() Method

```python
client.video_generation(
    content_items: List[Union[TextContent, ImageURLContent]],
callback_url: Optional[str] = None,
return_last_frame: Optional[bool] = False,
model: str = "doubao-seedance-1-5-pro-251215",
max_wait_time: int = 900,
resolution: Optional[str] = "720p",
ratio: Optional[str] = "16:9",
duration: Optional[int] = 5,
watermark: Optional[bool] = True,
seed: Optional[int] = None,
camerafixed: Optional[bool] = False,
generate_audio: Optional[bool] = True
) -> Tuple[Optional[str], Dict, str]
```

**Input Parameters:**

| Parameter           | Type                                        | Default                          | Description                                                                       |
|---------------------|---------------------------------------------|----------------------------------|-----------------------------------------------------------------------------------|
| `content_items`     | `List[Union[TextContent, ImageURLContent]]` | Required                         | Input content for video generation (text and/or images)                           |
| `callback_url`      | `str`                                       | `None`                           | Optional callback URL for task status notifications                               |
| `return_last_frame` | `bool`                                      | `False`                          | Return the last frame image of the generated video                                |
| `model`             | `str`                                       | `doubao-seedance-1-5-pro-251215` | Model name to use for generation                                                  |
| `max_wait_time`     | `int`                                       | `900`                            | Maximum wait time in seconds                                                      |
| `resolution`        | `str`                                       | `"720p"`                         | Video resolution (`"480p"`, `"720p"`, or `"1080p"`) |
| `ratio`             | `str`                                       | `"16:9"`                         | Video aspect ratio (`"16:9"`, `"9:16"`, `"1:1"`, `"4:3"`, `"3:4"`, `"21:9"`, `"adaptive"`) |
| `duration`          | `int`                                       | `5`                              | Video duration in seconds (4-12s for 1.5 pro, or -1 for smart selection)          |
| `watermark`         | `bool`                                      | `True`                           | Add watermark to generated videos                                                 |
| `seed`              | `int`                                       | `None`                           | Random seed for reproducible generation                                           |
| `camerafixed`       | `bool`                                      | `False`                          | Fix camera position during generation                                             |
| `generate_audio`    | `bool`                                      | `True`                           | Controls whether the generated video includes audio synchronized with the visuals |

**Content Types:**

```python
class TextContent:
    type: Literal["text"] = "text"
    text: str


class ImageURLContent:
    type: Literal["image_url"] = "image_url"
    image_url: ImageURL
    role: Optional[Literal["first_frame", "last_frame", "reference_image"]] = None


class ImageURL:
    url: str
```

**Response:**

Returns a tuple: `(video_url, response_dict, last_frame_url)`

- `video_url`: URL of the generated video (or `None` if failed/cancelled)
- `response_dict`: Complete response data dictionary
- `last_frame_url`: URL of the last frame image (if `return_last_frame=True`)

**Response Dictionary Example:**

```python
{
    "id": "cgt-2025******-****",
    "model": "doubao-seedance-1-5-pro-251215",
    "status": "succeeded",
    "content": {
        "video_url": "https://ark-content-generation-cn-beijing.tos-cn-beijing.volces.com/..."
    },
    "seed": 10,
    "resolution": "720p",
    "ratio": "16:9",
    "duration": 5,
    "framespersecond": 24,
    "usage": {
        "completion_tokens": 108900,
        "total_tokens": 108900
    },
    "created_at": 1743414619,
    "updated_at": 1743414673
}
```

### video_generation_async() Method

Async version of `video_generation()` for concurrent video generation tasks.

```python
async def video_generation_async(
        content_items: List[Union[TextContent, ImageURLContent]],
        callback_url: Optional[str] = None,
        return_last_frame: Optional[bool] = False,
        model: str = "doubao-seedance-1-5-pro-251215",
        max_wait_time: int = 900,
        resolution: Optional[str] = "720p",
        ratio: Optional[str] = "16:9",
        duration: Optional[int] = 5,
        watermark: Optional[bool] = True,
        seed: Optional[int] = None,
        camerafixed: Optional[bool] = False,
        generate_audio: Optional[bool] = True
) -> Tuple[Optional[str], Dict, str]
```

Parameters and return values are identical to `video_generation()`.

## Usage Examples

### Text-to-Video Generation

```python
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="video.generate")

client = VideoGenerationClient(ctx=ctx)

video_url, response, _ = client.video_generation(
    content_items=[
        TextContent(text="A serene mountain landscape with a flowing river")
    ],
    model="doubao-seedance-1-5-pro-251215",
    resolution="720p",
    ratio="16:9",
    duration=5,
    watermark=False
)

generated_video_url = video_url
```

### Image-to-Video (First Frame)

```python
from coze_coding_dev_sdk.video import (
    VideoGenerationClient,
    TextContent,
    ImageURLContent,
    ImageURL
)
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="video.generate")

client = VideoGenerationClient(ctx=ctx)

video_url, response, _ = client.video_generation(
    content_items=[
        TextContent(text="Animate this scene with gentle camera movement"),
        ImageURLContent(
            image_url=ImageURL(url="https://example.com/first-frame.jpg"),
            role="first_frame"
        )
    ],
    model="doubao-seedance-1-5-pro-251215",
    resolution="720p",
    ratio="16:9",
    duration=5
)

generated_video_url = video_url
```

### Image-to-Video (First & Last Frame)

```python
from coze_coding_dev_sdk.video import (
    VideoGenerationClient,
    TextContent,
    ImageURLContent,
    ImageURL
)
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="video.generate")

client = VideoGenerationClient(ctx=ctx)

video_url, response, _ = client.video_generation(
    content_items=[
        TextContent(text="Smooth transition between frames"),
        ImageURLContent(
            image_url=ImageURL(url="https://example.com/first-frame.jpg"),
            role="first_frame"
        ),
        ImageURLContent(
            image_url=ImageURL(url="https://example.com/last-frame.jpg"),
            role="last_frame"
        )
    ],
    model="doubao-seedance-1-5-pro-251215",
    resolution="720p",
    ratio="16:9",
    duration=5
)

generated_video_url = video_url
```

### Image-to-Video (Reference Images)

> ⚠️ **Note**: Reference images feature is **NOT supported** by `doubao-seedance-1-5-pro-251215`. This example is for
> reference only.

```python
# WARNING: This feature is NOT supported by doubao-seedance-1-5-pro-251215
# The following code is for reference only

from coze_coding_dev_sdk.video import (
    VideoGenerationClient,
    TextContent,
    ImageURLContent,
    ImageURL
)
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="video.generate")

client = VideoGenerationClient(ctx=ctx)

video_url, response, _ = client.video_generation(
    content_items=[
        TextContent(text="Create a video based on these reference images"),
        ImageURLContent(
            image_url=ImageURL(url="https://example.com/ref1.jpg"),
            role="reference_image"
        ),
        ImageURLContent(
            image_url=ImageURL(url="https://example.com/ref2.jpg"),
            role="reference_image"
        ),
        ImageURLContent(
            image_url=ImageURL(url="https://example.com/ref3.jpg"),
            role="reference_image"
        )
    ],
    model="doubao-seedance-1-5-pro-251215",
    resolution="720p",
    ratio="16:9",
    duration=5
)

generated_video_url = video_url
```

### Custom Headers and Mock Mode

```python
from coze_coding_dev_sdk import Config
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent

config = Config()

custom_headers = {
    "x-custom-field": "custom-value",
    "x-run-mode": "test_run"
}

client = VideoGenerationClient(config, custom_headers=custom_headers)

video_url, response, _ = client.video_generation(
    content_items=[
        TextContent(text="A modern office workspace")
    ],
    model="doubao-seedance-1-5-pro-251215",
    resolution="720p",
    ratio="16:9",
    duration=5
)

generated_video_url = video_url
```

### Return Last Frame

```python
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent

client = VideoGenerationClient()

video_url, response, last_frame_url = client.video_generation(
    content_items=[
        TextContent(text="A beautiful sunset over the ocean")
    ],
    model="doubao-seedance-1-5-pro-251215",
    resolution="720p",
    ratio="16:9",
    duration=5,
    return_last_frame=True
)

generated_video_url = video_url
last_frame = last_frame_url
```

### Error Handling

```python
from coze_coding_dev_sdk import APIError
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent

client = VideoGenerationClient()

try:
    video_url, response, _ = client.video_generation(
        content_items=[
            TextContent(text="A beautiful landscape")
        ],
        model="doubao-seedance-1-5-pro-251215",
        resolution="720p",
        ratio="16:9",
        duration=5
    )

    generated_video_url = video_url

except APIError as error:
    raise error
except Exception as error:
    raise error
```

### Batch Generation (Async)

For generating videos from multiple prompts, use `video_generation_async()` for parallel execution:

```python
import asyncio
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent

client = VideoGenerationClient()


async def batch_generate():
    prompts = [
        "A sunset over mountains",
        "A futuristic cityscape",
        "A serene beach scene"
    ]

    tasks = [
        client.video_generation_async(
            content_items=[TextContent(text=prompt)],
            model="doubao-seedance-1-5-pro-251215",
            resolution="720p",
            ratio="16:9",
            duration=5
        )
        for prompt in prompts
    ]

    results = await asyncio.gather(*tasks)
    return results


results = asyncio.run(batch_generate())

video_urls = [video_url for video_url, response, _ in results if video_url]
```

**Manual Concurrency Control:**

```python
import asyncio
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent

client = VideoGenerationClient()


async def generate_with_concurrency_limit(prompts: list[str], max_concurrent: int = 2):
    results = []

    for i in range(0, len(prompts), max_concurrent):
        batch = prompts[i:i + max_concurrent]
        batch_tasks = [
            client.video_generation_async(
                content_items=[TextContent(text=prompt)],
                model="doubao-seedance-1-5-pro-251215",
                resolution="720p",
                ratio="16:9",
                duration=5
            )
            for prompt in batch
        ]
        batch_results = await asyncio.gather(*batch_tasks)
        results.extend(batch_results)

    return results


prompts = [
    "A sunset over mountains",
    "A futuristic cityscape",
    "A serene beach scene",
    "A tropical rainforest",
    "A snowy mountain peak"
]

results = asyncio.run(generate_with_concurrency_limit(prompts, max_concurrent=2))

video_urls = [video_url for video_url, response, _ in results if video_url]
```

### Sequential Video Generation (Video Consistency)

Use the last frame of the previous video as the first frame of the next video to maintain visual consistency across multiple video segments:

```python
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent, ImageURLContent, ImageURL

client = VideoGenerationClient()

scene_prompts = [
    "A girl walking through a forest path, morning light filtering through trees",
    "The girl discovers a hidden waterfall, camera slowly approaching",
    "The girl sits by the waterfall, peaceful atmosphere, birds flying"
]

video_urls = []
last_frame_url = None

for i, prompt in enumerate(scene_prompts):
    content_items = [TextContent(text=prompt)]
    
    if last_frame_url:
        content_items.insert(0, ImageURLContent(image_url=ImageURL(url=last_frame_url)))
    
    video_url, response, last_frame_url = client.video_generation(
        content_items=content_items,
        model="doubao-seedance-1-5-pro-251215",
        resolution="720p",
        ratio="16:9",
        duration=5,
        return_last_frame=True
    )
    
    if video_url:
        video_urls.append(video_url)

final_videos = video_urls
```

**Key Points:**
- Set `return_last_frame=True` to get the last frame URL of each generated video
- Use `ImageURLContent` to pass the last frame as the first frame of the next video
- This ensures smooth visual transitions between consecutive video segments
- Ideal for creating story-driven or continuous scene videos

### Callback URL

```python
from coze_coding_dev_sdk.video import VideoGenerationClient, TextContent

client = VideoGenerationClient()

video_url, response, _ = client.video_generation(
    content_items=[
        TextContent(text="A beautiful landscape")
    ],
    model="doubao-seedance-1-5-pro-251215",
    resolution="720p",
    ratio="16:9",
    duration=5,
    callback_url="https://your-domain.com/webhook/video-generation"
)

print(f"Task ID: {response['id']}")
print(f"Video URL: {video_url}")
```

## CLI Usage

The SDK includes a command-line tool `coze-coding-ai` for quick video generation without writing code.

### Basic CLI Usage

```bash
coze-coding-ai video --prompt "A futuristic city at sunset" --output result.json
```

### CLI Options

```bash
coze-coding-ai video [OPTIONS]

Options:
  -p, --prompt <text>          Text description of the video
  -i, --image-url <url>        Image URL (single or comma-separated for two images)
  -s, --size <size>            Video resolution (e.g., 1920x1080)
  -d, --duration <seconds>     Video duration (5-10 seconds)
  -m, --model <model>          Model name
  --callback-url <url>         Callback URL for task status notifications
  --return-last-frame          Return the last frame image
  --watermark                  Add watermark to the video
  --seed <number>              Random seed for reproducible generation
  --camerafixed                Fix camera position during generation
  -o, --output <path>          Output file path (JSON)
  -H, --header <header>        Custom HTTP header (format: "Key: Value" or "Key=Value")
  --mock                       Use mock mode (test run without actual generation)
  -v, --verbose                Show detailed HTTP request logs
  --help                       Show this message and exit
```

### CLI Examples

**Basic text-to-video:**

```bash
coze-coding-ai video \
  --prompt "A serene mountain landscape with a lake" \
  --size 1920x1080 \
  --duration 5 \
  --output result.json
```

**Image-to-video (first frame):**

```bash
coze-coding-ai video \
  --prompt "Animate this scene" \
  --image-url "https://example.com/first-frame.jpg" \
  --size 1280x720 \
  --duration 5 \
  --output result.json
```

**Image-to-video (first & last frame):**

```bash
coze-coding-ai video \
  --prompt "Smooth transition" \
  --image-url "https://example.com/first.jpg,https://example.com/last.jpg" \
  --size 1920x1080 \
  --duration 5 \
  --output result.json
```

**With custom model (optional, uses default if not specified):**

```bash
coze-coding-ai video \
  --prompt "A beautiful sunset" \
  --model "doubao-seedance-1-5-pro-251215" \
  --size 1920x1080 \
  --duration 5 \
  --output result.json
```

**With custom headers:**

```bash
coze-coding-ai video \
  --prompt "A beautiful sunset" \
  --header "x-custom-field: custom-value" \
  --header "x-request-id: 12345" \
  --output result.json
```

**Return last frame:**

```bash
coze-coding-ai video \
  --prompt "A beautiful sunset" \
  --return-last-frame \
  --output result.json
```

**Mock mode (testing):**

```bash
coze-coding-ai video \
  --prompt "Test video generation" \
  --mock \
  --output result.json
```

**With callback URL:**

```bash
coze-coding-ai video \
  --prompt "A futuristic city" \
  --callback-url "https://your-domain.com/webhook" \
  --output result.json
```

**Verbose mode:**

```bash
coze-coding-ai video \
  --prompt "A beautiful landscape" \
  --verbose \
  --output result.json
```

## Key Points

- **Duration Range**: Video duration must be between 5-10 seconds
- **Resolution Options**: Supports 480p, 720p, and 1080p resolutions
- **Aspect Ratios**: Supports 16:9, 9:16, 1:1, 4:3, 3:4, 21:9, and adaptive aspect ratios
- **Backend Only**: Never expose API keys in client-side code
- **Error Handling**: Always use try-catch blocks and check if `video_url` is not `None` before using results
- **Config Management**: Use `Config` class for proper API authentication
- **Custom Headers**: Use `custom_headers` for mock mode or custom metadata
- **Async Processing**: Use `video_generation_async()` for parallel execution of multiple video generation tasks
- **Concurrency Control**: Implement manual batching to limit concurrent requests and avoid rate limiting (recommended
  max 2-3 concurrent video generations)
- **CLI Tool**: Use `coze-coding-ai video` command for quick generation without writing code
- **Polling Mechanism**: The SDK automatically polls for task completion with a 5-second interval and 300-second timeout
- **Retry Logic**: Automatic retry with exponential backoff for rate limiting and timeout errors
- **Video URL Storage**: The returned video URLs are already stored in object storage with a valid expiration period.
  Unless absolutely necessary, you should use these URLs directly without re-uploading to your own object storage system