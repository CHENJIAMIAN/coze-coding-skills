# Video Edit Skill Python SDK

This skill guides the implementation of video editing functionality using the coze-coding-dev-sdk package and CLI tool, enabling comprehensive video processing capabilities including frame extraction, trimming, concatenation, subtitle management, and audio operations.

## Overview

Video Edit capabilities allow you to build applications with professional video processing features, enabling automated video editing, content optimization, subtitle generation, and audio manipulation workflows.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

### Frame Extraction

```python
from coze_coding_dev_sdk.video_edit import FrameExtractorClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FrameExtractorClient(ctx=ctx)

response = client.extract_by_key_frame(
    url="https://example.com/video.mp4"
)

for frame in response.data.chunks:
    print(f"Frame {frame.index}: {frame.screenshot} at {frame.timestamp_ms}ms")
```

### Video Trimming

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

response = client.video_trim(
    video="https://example.com/video.mp4",
    start_time=10.0,
    end_time=30.0
)

print(f"Trimmed video: {response.url}")
```

### Video Concatenation

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

response = client.concat_videos(
    videos=[
        "https://example.com/video1.mp4",
        "https://example.com/video2.mp4",
        "https://example.com/video3.mp4"
    ]
)

print(f"Concatenated video: {response.url}")
```

**About Context (`ctx`):**

- `Context` is used for request tracking and tracing across distributed systems
- It automatically injects headers like `request_id`, `trace_id`, and `user_id` into API calls
- **Optional**: If you don't need request tracking, you can omit `ctx` parameter: `FrameExtractorClient()` or `VideoEditClient()`
- Recommended for production environments to enable observability and debugging

## API Reference

## Frame Extraction

### Client Initialization

```python
FrameExtractorClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None,
    custom_headers: Optional[Dict[str, str]] = None,
    verbose: bool = False
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `ctx`: Context for request tracking (request_id, trace_id, user_id)
- `custom_headers`: Custom HTTP headers (e.g., `{"x-run-mode": "test_run"}`)
- `verbose`: Enable verbose HTTP request logging

### extract_by_key_frame() Method

```python
client.extract_by_key_frame(
    url: str
) -> FrameExtractorResponse
```

Extract frames at key frame positions in the video.

**Input Parameters:**

| Parameter | Type  | Default  | Description           |
| --------- | ----- | -------- | --------------------- |
| `url`     | `str` | Required | Video URL             |

**Returns:** `FrameExtractorResponse` with frame list

### extract_by_interval() Method

```python
client.extract_by_interval(
    url: str,
    interval_ms: int
) -> FrameExtractorResponse
```

Extract frames at regular time intervals.

**Input Parameters:**

| Parameter     | Type  | Default  | Description                      |
| ------------- | ----- | -------- | -------------------------------- |
| `url`         | `str` | Required | Video URL                        |
| `interval_ms` | `int` | Required | Interval between frames in milliseconds |

**Returns:** `FrameExtractorResponse` with frame list

### extract_by_count() Method

```python
client.extract_by_count(
    url: str,
    count: int
) -> FrameExtractorResponse
```

Extract a specific number of frames evenly distributed across the video.

**Input Parameters:**

| Parameter | Type  | Default  | Description                |
| --------- | ----- | -------- | -------------------------- |
| `url`     | `str` | Required | Video URL                  |
| `count`   | `int` | Required | Number of frames to extract|

**Returns:** `FrameExtractorResponse` with frame list

**Response Structure:**

```python
{
    "code": 0,
    "msg": "success",
    "log_id": "...",
    "data": {
        "chunks": [
            {
                "index": 0,
                "screenshot": "https://...",
                "timestamp_ms": 0
            }
        ]
    }
}
```

## Video Editing

### Client Initialization

```python
VideoEditClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None,
    custom_headers: Optional[Dict[str, str]] = None,
    verbose: bool = False
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `ctx`: Context for request tracking (request_id, trace_id, user_id)
- `custom_headers`: Custom HTTP headers (e.g., `{"x-run-mode": "test_run"}`)
- `verbose`: Enable verbose HTTP request logging

### video_trim() Method

```python
client.video_trim(
    video: str,
    start_time: Optional[float] = None,
    end_time: Optional[float] = None,
    url_expire: Optional[int] = None
) -> VideoEditResponse
```

Trim video to a specific time range.

**Input Parameters:**

| Parameter    | Type    | Default | Description                              |
| ------------ | ------- | ------- | ---------------------------------------- |
| `video`      | `str`   | Required| Video URL                                |
| `start_time` | `float` | `0`     | Start time in seconds                    |
| `end_time`   | `float` | `None`  | End time in seconds (None = end of video)|
| `url_expire` | `int`   | `86400` | URL expiration time in seconds (max 30d) |

### concat_videos() Method

```python
client.concat_videos(
    videos: List[str],
    transitions: Optional[List[str]] = None,
    url_expire: Optional[int] = None
) -> VideoEditResponse
```

Concatenate multiple videos with optional transitions.

**Input Parameters:**

| Parameter     | Type         | Default | Description                                    |
| ------------- | ------------ | ------- | ---------------------------------------------- |
| `videos`      | `List[str]`  | Required| List of video URLs                             |
| `transitions` | `List[str]`  | `None`  | List of transition IDs (non-overlapping only)  |
| `url_expire`  | `int`        | `86400` | URL expiration time in seconds (max 30d)       |

**Available Transition IDs:**

| Transition Name | ID        |
|-----------------|-----------|
| 叶片翻转 (Leaf Flip) | `1182355` |
| 百叶窗 (Blinds) | `1182356` |
| 风吹 (Wind Blow) | `1182357` |
| 交替出场 (Alternate) | `1182359` |
| 旋转放大 (Rotate Zoom) | `1182360` |
| 泛开 (Spread) | `1182358` |
| 风车 (Windmill) | `1182362` |
| 多色混合 (Multi-color Mix) | `1182363` |
| 遮罩转场 (Mask Transition) | `1182364` |
| 六角形 (Hexagon) | `1182365` |
| 心型打开 (Heart Open) | `1182366` |
| 故障转换 (Glitch) | `1182367` |
| 飞眼 (Flying Eye) | `1182368` |
| 梦幻放大 (Dream Zoom) | `1182369` |
| 开门展现 (Door Open) | `1182370` |
| 对角擦除 (Diagonal Wipe) | `1182371` |
| 立方转换 (Cube) | `1182373` |
| 透镜变换 (Lens) | `1182374` |
| 晚霞转场 (Sunset) | `1182375` |
| 圆形打开 (Circle Open) | `1182376` |
| 圆形擦开 (Circle Wipe) | `1182377` |
| 圆形交替 (Circle Alternate) | `1182378` |
| 时钟扫开 (Clock Wipe) | `1182379` |

**Usage Example:**

```python
response = client.concat_videos(
    videos=["video1.mp4", "video2.mp4", "video3.mp4"],
    transitions=["1182356", "1182376"]  # 百叶窗, 圆形打开
)
```

### add_subtitles() Method

```python
client.add_subtitles(
    video: str,
    subtitle_config: SubtitleConfig,
    subtitle_url: Optional[str] = None,
    text_list: Optional[List[TextItem]] = None,
    url_expire: Optional[int] = None
) -> VideoEditResponse
```

Add subtitles to video with customizable styling.

**Input Parameters:**

| Parameter         | Type             | Default | Description                              |
| ----------------- | ---------------- | ------- | ---------------------------------------- |
| `video`           | `str`            | Required| Video URL                                |
| `subtitle_config` | `SubtitleConfig` | Required| Subtitle styling configuration           |
| `subtitle_url`    | `str`            | `None`  | Subtitle file URL (SRT/VTT/ASS)          |
| `text_list`       | `List[TextItem]` | `None`  | Text items with timestamps               |
| `url_expire`      | `int`            | `86400` | URL expiration time in seconds (max 30d) |

**SubtitleConfig Structure:**

```python
from coze_coding_dev_sdk.video_edit import SubtitleConfig, FontPosConfig

subtitle_config = SubtitleConfig(
    font_pos_config=FontPosConfig(
        pos_x="0",
        pos_y="90%",
        width="100%",
        height="10%"
    ),
    font_size=36,
    font_color="#FFFFFFFF",
    font_type="1525745",
    background_color="#00000000",
    background_border_width=0,
    border_width=1,
    border_color="#00000088"
)
```

**TextItem Structure:**

```python
from coze_coding_dev_sdk.video_edit import TextItem

text_item = TextItem(
    start_time=0.0,
    end_time=5.0,
    text="Hello, World!"
)
```

**SubtitleConfig Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `font_pos_config` | `FontPosConfig` | Required | Position and size configuration |
| `font_size` | `int` | `36` | Font size in pixels |
| `font_color` | `str` | `"#FFFFFFFF"` | Font color in hex format (with alpha) |
| `font_type` | `str` | `1525745` | Font Type (see Available Font Types section) |
| `background_color` | `str` | `"#00000000"` | Background color in hex format |
| `background_border_width` | `int` | `0` | Background border width |
| `border_width` | `int` | `1` | Text border width |
| `border_color` | `str` | `"#00000088"` | Border color in hex format |

**FontPosConfig Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pos_x` | `str` | Required | X position (pixels or percentage, e.g., "0") |
| `pos_y` | `str` | Required | Y position (pixels or percentage, e.g., "90%") |
| `width` | `str` | Required | Width (pixels or percentage, e.g., "100%") |
| `height` | `str` | Required | Height (pixels or percentage, e.g., "10%") |

**Note:** For available font Types, see the "Available Font Types" section under "Subtitle Management" in Key Points.

### compile_video_audio() Method

```python
client.compile_video_audio(
    video: str,
    audio: str,
    is_video_audio_sync: Optional[bool] = None,
    output_sync: Optional[OutputSync] = None,
    is_audio_reserve: Optional[bool] = None,
    url_expire: Optional[int] = None
) -> VideoEditResponse
```

Combine video and audio tracks.

**Input Parameters:**

| Parameter             | Type         | Default | Description                              |
| --------------------- | ------------ | ------- | ---------------------------------------- |
| `video`               | `str`        | Required| Video URL                                |
| `audio`               | `str`        | Required| Audio URL                                |
| `is_video_audio_sync` | `bool`       | `False` | Enable audio-video synchronization       |
| `output_sync`         | `OutputSync` | `None`  | Sync configuration                       |
| `is_audio_reserve`    | `bool`       | `False` | Keep original video audio                |
| `url_expire`          | `int`        | `86400` | URL expiration time in seconds (max 30d) |

**OutputSync Structure:**

```python
from coze_coding_dev_sdk.video_edit import OutputSync

output_sync = OutputSync(
    sync_method="trim",  # "trim" or "speed"
    sync_mode="video"    # "video" or "audio"
)
```

### audio_to_subtitle() Method

```python
client.audio_to_subtitle(
    source: str,
    subtitle_type: Optional[str] = None,
    url_expire: Optional[int] = None
) -> VideoEditResponse
```

Convert speech in video/audio to subtitle file.

**Input Parameters:**

| Parameter       | Type  | Default  | Description                              |
| --------------- | ----- | -------- | ---------------------------------------- |
| `source`        | `str` | Required | Video/Audio URL                       
| `subtitle_type` | `str` | `"srt"`  | Subtitle format: "srt" or "webvtt"       |
| `url_expire`    | `int` | `86400`  | URL expiration time in seconds (max 30d) |

### extract_audio() Method

```python
client.extract_audio(
    video: str,
    format: Optional[str] = None,
    url_expire: Optional[int] = None
) -> VideoEditResponse
```

Extract audio track from video.

**Input Parameters:**

| Parameter    | Type  | Default | Description                              |
| ------------ | ----- | ------- | ---------------------------------------- |
| `video`      | `str` | Required| Video URL                                |
| `format`     | `str` | `"m4a"` | Audio format: "m4a" or "mp3"             |
| `url_expire` | `int` | `86400` | URL expiration time in seconds (min 1h, max 30d) |

```python
{
    "req_id": "...",
    "url": "https://...",
    "message": "success",
    "video_meta": {
        "duration": 120,
        "resolution": "1920x1080",
        "type": "video"
    },
    "bill_info": {
        "duration": 120,
        "ratio": 1.0
    }
}
```

## Usage Examples

### Extract Frames by Key Frame

```python
from coze_coding_dev_sdk.video_edit import FrameExtractorClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FrameExtractorClient(ctx=ctx)

response = client.extract_by_key_frame(
    url="https://example.com/video.mp4"
)

frames = response.data.chunks
for frame in frames:
    frame_url = frame.screenshot
    timestamp_sec = frame.timestamp_ms / 1000
```

### Extract Frames by Interval

```python
from coze_coding_dev_sdk.video_edit import FrameExtractorClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FrameExtractorClient(ctx=ctx)

response = client.extract_by_interval(
    url="https://example.com/video.mp4",
    interval_ms=5000
)

frames = response.data
for frame in frames:
    frame_url = frame.screenshot
    timestamp_sec = frame.timestamp_ms / 1000
```

### Extract Specific Number of Frames

```python
from coze_coding_dev_sdk.video_edit import FrameExtractorClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FrameExtractorClient(ctx=ctx)

response = client.extract_by_count(
    url="https://example.com/video.mp4",
    count=10
)

frames = response.data.chunks
```

### Trim Video

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

response = client.video_trim(
    video="https://example.com/video.mp4",
    start_time=10.5,
    end_time=45.0
)

trimmed_video_url = response.url
duration = response.video_meta.duration
```

### Concatenate Videos with Transitions

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

response = client.concat_videos(
    videos=[
        "https://example.com/intro.mp4",
        "https://example.com/main.mp4",
        "https://example.com/outro.mp4"
    ],
    transitions=["1182356", "1182376"]
)

concatenated_video_url = response.url
```

### Add Subtitles with Custom Styling

```python
from coze_coding_dev_sdk.video_edit import (
    VideoEditClient,
    SubtitleConfig,
    FontPosConfig,
    TextItem
)
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

subtitle_config = SubtitleConfig(
    font_pos_config=FontPosConfig(
        pos_x="0",
        pos_y="90%",
        width="100%",
        height="10%"
    ),
    font_size=36,
    font_color="#FFFFFFFF",
    font_type="1525745",
    background_color="#00000000",
    background_border_width=0,
    border_width=1,
    border_color="#00000088"
)

text_list = [
    TextItem(start_time=0.0, end_time=3.0, text="Hello, World!"),
    TextItem(start_time=3.0, end_time=6.0, text="Welcome to video editing!"),
    TextItem(start_time=6.0, end_time=9.0, text="Enjoy your content!")
]

response = client.add_subtitles(
    video="https://example.com/video.mp4",
    subtitle_config=subtitle_config,
    text_list=text_list
)

video_with_subtitles_url = response.url
```

### Add Subtitles from File

```python
from coze_coding_dev_sdk.video_edit import (
    VideoEditClient,
    SubtitleConfig,
    FontPosConfig
)
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

subtitle_config = SubtitleConfig(
    font_pos_config=FontPosConfig(
        pos_x="0",
        pos_y="90%",
        width="100%",
        height="10%"
    ),
    font_size=36,
    font_color="#FFFFFFFF",
    font_type="1525745",
    background_color="#00000000",
    background_border_width=0,
    border_width=1,
    border_color="#00000088"
)

response = client.add_subtitles(
    video="https://example.com/video.mp4",
    subtitle_config=subtitle_config,
    subtitle_url="https://example.com/subtitles.srt"
)

video_with_subtitles_url = response.url
```

### Compile Video and Audio

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

response = client.compile_video_audio(
    video="https://example.com/video.mp4",
    audio="https://example.com/audio.mp3",
    is_audio_reserve=False
)

compiled_video_url = response.url
```

### Compile with Audio Sync

```python
from coze_coding_dev_sdk.video_edit import (
    VideoEditClient,
    OutputSync
)
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

output_sync = OutputSync(
    sync_method="trim",
    sync_mode="video"
)

response = client.compile_video_audio(
    video="https://example.com/video.mp4",
    audio="https://example.com/audio.mp3",
    is_video_audio_sync=True,
    output_sync=output_sync,
    is_audio_reserve=False
)

synced_video_url = response.url
```

### Convert Audio to Subtitle

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

response = client.audio_to_subtitle(
    source="https://example.com/video.mp4",
    subtitle_type="srt"
)

subtitle_file_url = response.url
```

### Extract Audio from Video

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

response = client.extract_audio(
    video="https://example.com/video.mp4",
    format="mp3"
)

extracted_audio_url = response.url
duration = response.video_meta.duration
```

### Complete Video Processing Pipeline

```python
from coze_coding_dev_sdk.video_edit import (
    VideoEditClient,
    SubtitleConfig,
    FontPosConfig
)
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

# Step 1: Trim video
trimmed = client.video_trim(
    video="https://example.com/raw_video.mp4",
    start_time=5.0,
    end_time=60.0
)

# Step 2: Generate subtitles from audio
subtitle = client.audio_to_subtitle(
    source=trimmed.url,
    subtitle_type="srt"
)

# Step 3: Add subtitles to video
subtitle_config = SubtitleConfig(
    font_pos_config=FontPosConfig(
        pos_x="0",
        pos_y="90%",
        width="100%",
        height="10%"
    ),
    font_size=36,
    font_color="#FFFFFFFF",
    font_type="1525745",
    background_color="#00000000",
    background_border_width=0,
    border_width=1,
    border_color="#00000088"
)

final = client.add_subtitles(
    video=trimmed.url,
    subtitle_config=subtitle_config,
    subtitle_url=subtitle.url
)

final_video_url = final.url
```

### Batch Frame Extraction (Async)

```python
import asyncio
from coze_coding_dev_sdk.video_edit import FrameExtractorClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FrameExtractorClient(ctx=ctx)

async def batch_extract():
    videos = [
        "https://example.com/video1.mp4",
        "https://example.com/video2.mp4",
        "https://example.com/video3.mp4"
    ]
    
    tasks = [
        client.extract_by_key_frame_async(url)
        for url in videos
    ]
    
    results = await asyncio.gather(*tasks)
    return results

results = asyncio.run(batch_extract())

for response in results:
    frames = response.data.chunks
```

### Batch Video Trimming (Async)

```python
import asyncio
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

async def batch_trim():
    videos = [
        ("https://example.com/video1.mp4", 0, 30),
        ("https://example.com/video2.mp4", 10, 40),
        ("https://example.com/video3.mp4", 5, 35)
    ]
    
    tasks = [
        client.video_trim_async(url, start, end)
        for url, start, end in videos
    ]
    
    results = await asyncio.gather(*tasks)
    return results

results = asyncio.run(batch_trim())

trimmed_urls = [response.url for response in results]
```

### Error Handling

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_dev_sdk.core.exceptions import APIError
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = VideoEditClient(ctx=ctx)

try:
    response = client.video_trim(
        video="https://example.com/video.mp4",
        start_time=0,
        end_time=10
    )
    
    video_url = response.url
        
except APIError as error:
    raise error
except Exception as error:
    raise error
```

### Custom Headers and Mock Mode

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()

custom_headers = {
    "x-run-mode": "test_run",
    "x-custom-field": "custom-value"
}

client = VideoEditClient(ctx=ctx, custom_headers=custom_headers)

response = client.video_trim(
    video="https://example.com/video.mp4",
    start_time=0,
    end_time=10
)

video_url = response.url
```

## CLI Usage

The SDK includes command-line tools for quick video editing operations without writing code.

### Frame Extraction CLI

**Extract by key frame:**

```bash
coze-coding-ai video-edit extract-key-frame \
  --url "https://example.com/video.mp4" \
  --output frames.json
```

**Extract by interval:**

```bash
coze-coding-ai video-edit extract-interval \
  --url "https://example.com/video.mp4" \
  --interval 5.0 \
  --output frames.json
```

**Note:** CLI uses `--interval` in seconds (float), which is converted to milliseconds for the API call.

**Extract by count:**

```bash
coze-coding-ai video-edit extract-count \
  --url "https://example.com/video.mp4" \
  --count 10 \
  --output frames.json
```

### Video Editing CLI

**Trim video:**

```bash
coze-coding-ai video-edit trim \
  --video "https://example.com/video.mp4" \
  --start 10 \
  --end 30 \
  --output result.json
```

**Concatenate videos:**

```bash
coze-coding-ai video-edit concat \
  --videos "video1.mp4,video2.mp4,video3.mp4" \
  --output result.json
```

**Extract audio:**

```bash
coze-coding-ai video-edit extract-audio \
  --video "https://example.com/video.mp4" \
  --output result.json
```

**Note:** CLI command is `extract-audio`, which maps to the `extract_audio()` Python method.

**Convert to subtitle:**

```bash
coze-coding-ai video-edit audio-to-subtitle \
  --source "https://example.com/video.mp4" \
  --type srt \
  --output result.json
```

## Key Points

### Frame Extraction

- **Key Frame Extraction**: Extract frames at scene changes and key moments
- **Interval Extraction**: Extract frames at regular time intervals (milliseconds)
- **Count Extraction**: Extract a specific number of evenly distributed frames
- **Timestamp Info**: Each frame includes precise timestamp information
- **URL Access**: All extracted frames are accessible via URLs

### Video Editing

- **Format Support**: Supports common video formats (MP4, AVI, MKV, MOV)
- **Trimming**: Precise time-based video trimming (seconds)
- **Concatenation**: Join multiple videos with optional transitions
- **URL Expiration**: Configure output URL validity (1 second - 30 days)
- **Quality Preservation**: Maintains original video quality

### Subtitle Management

- **Format Support**: SRT, VTT, ASS subtitle formats
- **Custom Styling**: Full control over font, size, color, position
- **Text List**: Add subtitles programmatically with timestamps
- **File Upload**: Use existing subtitle files
- **Speech-to-Text**: Automatic subtitle generation from audio

#### Available Font Types

The following fonts are available for subtitle styling. Use the `font_type` parameter in `SubtitleConfig`:

##### 方正字体 (Founder Fonts)

| 字体名称 | Font Type | 备注 |
|---------|---------|------|
| 方正兰亭大黑（繁体） | `1525745` | Set as default |
| 方正新楷体 | `1525743` | |
| 方正硬笔楷体 | `1525741` | |
| 方正悠宋506 | `1525739` | |
| 方正悠宋508 | `1525737` | |
| 方正兰亭黑简体 | `1234271` | |
| 方正兰亭圆简体 | `1234269` | |
| 方正兰亭圆简体粗 | `1234267` | Bold |
| 方正兰亭圆简体大 | `1234265` | Large |
| 方正兰亭圆简体特 | `1234263` | Extra |
| 方正兰亭圆简体细 | `1234259` | Light |
| 方正兰亭圆简体纤 | `1234257` | Thin |
| 方正兰亭圆简体中 | `1234255` | Medium |
| 方正兰亭圆简体中粗 | `1234253` | Semi-Bold |
| 方正兰亭圆简体准 | `1234251` | Regular |
| 方正综艺体 | `1234249` | |

##### 站酷字体 (Zcool Fonts)

| 字体名称 | Font Type | 备注 |
|---------|---------|------|
| 站酷意大利体 | `1187225` | ⚠️ 不支持中文 (No Chinese support) |
| 站酷仓耳渔阳体 | `1187223` | |
| 站酷高端黑 | `1187221` | |
| 站酷酷黑体 | `1187219` | |
| 站酷快乐体 | `1187217` | |
| 站酷文艺体 | `1187213` | |
| 站酷小薇 LOGO 体 | `1187211` | |

##### 其他字体 (Other Fonts)

| 字体名称 | Font Type | 备注 |
|---------|---------|------|
| 思源黑体 | `SY_Black` | Source Han Sans |
| 阿里巴巴普惠体 | `ALi_PuHui` | Alibaba PuHuiTi |
| 庞门正道标题体 | `PM_ZhengDao` | |

**Usage Example:**

```python
from coze_coding_dev_sdk.video_edit import VideoEditClient, SubtitleConfig, FontPosConfig

subtitle_config = SubtitleConfig(
    font_type="1234271",  # 方正兰亭黑简体
    font_size=36,
    font_color="#FFFFFFFF",
    font_pos_config=FontPosConfig(
        pos_x="0",
        pos_y="90%",
        width="100%",
        height="10%"
    )
)

response = client.add_subtitles(
    video="https://example.com/video.mp4",
    subtitle_config=subtitle_config,
    subtitle_url="https://example.com/subtitle.srt"
)
```

### Audio Operations

- **Audio Extraction**: Extract audio track from video
- **Format Options**: M4A and MP3 output formats
- **Audio Compilation**: Combine video and audio tracks
- **Sync Options**: Trim or speed adjustment for audio-video sync
- **Reserve Original**: Option to keep original video audio

### General

- **Backend Only**: Never expose API keys in client-side code
- **Context Tracking**: Use `ctx` parameter for request tracing in production
- **Custom Headers**: Use `custom_headers` for mock mode or custom metadata
- **Async Support**: All methods have async versions for batch processing
- **Error Handling**: Always handle exceptions and check response status
- **Verbose Mode**: Enable detailed HTTP logging for debugging
- **Mock Mode**: Use mock mode for testing without consuming resources
- **Billing Info**: Response includes billing information for cost tracking