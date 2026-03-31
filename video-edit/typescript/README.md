# Video Edit Skill TypeScript SDK

This skill guides the implementation of video editing functionality using the coze-coding-dev-sdk package, enabling comprehensive video processing capabilities including frame extraction, trimming, concatenation, subtitle management, and audio operations.

## Overview

Video Edit capabilities allow you to build applications with professional video processing features, enabling automated video editing, content optimization, subtitle generation, and audio manipulation workflows.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

### Frame Extraction

```typescript
import { FrameExtractorClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FrameExtractorClient(config);

const response = await client.extractByKeyFrame('https://example.com/video.mp4');

for (const frame of response.data.chunks) {
  console.log(`Frame ${frame.index}: ${frame.screenshot} at ${frame.timestamp_ms}ms`);
}
```

### Video Trimming

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const response = await client.videoTrim('https://example.com/video.mp4', {
  startTime: 10.0,
  endTime: 30.0,
});

console.log(`Trimmed video: ${response.url}`);
```

### Video Concatenation

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const response = await client.concatVideos([
  'https://example.com/video1.mp4',
  'https://example.com/video2.mp4',
  'https://example.com/video3.mp4',
]);

console.log(`Concatenated video: ${response.url}`);
```

**About Config:**

- `Config` manages SDK configuration including API key, base URL, and timeout settings
- API credentials are automatically loaded from environment variables
- **Optional**: You can pass custom configuration: `new Config({ apiKey: 'your-key', timeout: 30000 })`
- Recommended for production environments to enable proper authentication and error handling

## API Reference

## Frame Extraction

### Client Initialization

```typescript
new FrameExtractorClient(
  config?: Config,
  customHeaders?: Record<string, string>,
  verbose?: boolean
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `customHeaders`: Custom HTTP headers (e.g., `{ "x-run-mode": "test_run" }`)
- `verbose`: Enable verbose HTTP request logging

### extractByKeyFrame() Method

```typescript
client.extractByKeyFrame(url: string): Promise<FrameExtractorResponse>
```

Extract frames at key frame positions in the video.

**Input Parameters:**

| Parameter | Type     | Default  | Description |
| --------- | -------- | -------- | ----------- |
| `url`     | `string` | Required | Video URL   |

**Returns:** `FrameExtractorResponse` with frame list

### extractByInterval() Method

```typescript
client.extractByInterval(url: string, intervalMs: number): Promise<FrameExtractorResponse>
```

Extract frames at regular time intervals.

**Input Parameters:**

| Parameter    | Type     | Default  | Description                             |
| ------------ | -------- | -------- | --------------------------------------- |
| `url`        | `string` | Required | Video URL                               |
| `intervalMs` | `number` | Required | Interval between frames in milliseconds |

**Returns:** `FrameExtractorResponse` with frame list

### extractByCount() Method

```typescript
client.extractByCount(url: string, count: number): Promise<FrameExtractorResponse>
```

Extract a specific number of frames evenly distributed across the video.

**Input Parameters:**

| Parameter | Type     | Default  | Description                 |
| --------- | -------- | -------- | --------------------------- |
| `url`     | `string` | Required | Video URL                   |
| `count`   | `number` | Required | Number of frames to extract |

**Returns:** `FrameExtractorResponse` with frame list

**Response Interface:**

```typescript
interface FrameExtractorResponse {
  code: number;
  msg: string;
  log_id: string;
  data: {
    chunks: FrameChunk[];
  };
}

interface FrameChunk {
  index: number;
  screenshot: string;
  timestamp_ms: number;
}
```

## Video Editing

### Client Initialization

```typescript
new VideoEditClient(
  config?: Config,
  customHeaders?: Record<string, string>,
  verbose?: boolean
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `customHeaders`: Custom HTTP headers (e.g., `{ "x-run-mode": "test_run" }`)
- `verbose`: Enable verbose HTTP request logging

### videoTrim() Method

```typescript
client.videoTrim(
  video: string,
  options?: {
    startTime?: number;
    endTime?: number;
    urlExpire?: number;
  }
): Promise<VideoEditResponse>
```

Trim video to a specific time range.

**Input Parameters:**

| Parameter   | Type     | Default   | Description                                |
| ----------- | -------- | --------- | ------------------------------------------ |
| `video`     | `string` | Required  | Video URL                                  |
| `startTime` | `number` | `0`       | Start time in seconds                      |
| `endTime`   | `number` | `undefined` | End time in seconds (undefined = end of video) |
| `urlExpire` | `number` | `86400`   | URL expiration time in seconds (max 30d)   |

### concatVideos() Method

```typescript
client.concatVideos(
  videos: string[],
  options?: {
    transitions?: string[];
    urlExpire?: number;
  }
): Promise<VideoEditResponse>
```

Concatenate multiple videos with optional transitions.

**Input Parameters:**

| Parameter     | Type       | Default | Description                                   |
| ------------- | ---------- | ------- | --------------------------------------------- |
| `videos`      | `string[]` | Required| List of video URLs                            |
| `transitions` | `string[]` | `undefined` | List of transition IDs (non-overlapping only) |
| `urlExpire`   | `number`   | `86400` | URL expiration time in seconds (max 30d)      |

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

```typescript
const response = await client.concatVideos(
  ['video1.mp4', 'video2.mp4', 'video3.mp4'],
  { transitions: ['1182356', '1182376'] }  // 百叶窗, 圆形打开
);
```

### addSubtitles() Method

```typescript
client.addSubtitles(
  video: string,
  subtitleConfig: SubtitleConfig,
  options?: {
    subtitleUrl?: string;
    textList?: TextItem[];
    urlExpire?: number;
  }
): Promise<VideoEditResponse>
```

Add subtitles to video with customizable styling.

**Input Parameters:**

| Parameter        | Type             | Default   | Description                              |
| ---------------- | ---------------- | --------- | ---------------------------------------- |
| `video`          | `string`         | Required  | Video URL                                |
| `subtitleConfig` | `SubtitleConfig` | Required  | Subtitle styling configuration           |
| `subtitleUrl`    | `string`         | `undefined` | Subtitle file URL (SRT/VTT/ASS)          |
| `textList`       | `TextItem[]`     | `undefined` | Text items with timestamps               |
| `urlExpire`      | `number`         | `86400`   | URL expiration time in seconds (max 30d) |

**SubtitleConfig Interface:**

```typescript
interface SubtitleConfig {
  font_pos_config: FontPosConfig;
  font_size?: number;
  font_color?: string;
  font_type?: string;
  background_color?: string;
  background_border_width?: number;
  border_width?: number;
  border_color?: string;
}

interface FontPosConfig {
  pos_x?: string;
  pos_y?: string;
  width?: string;
  height?: string;
}
```

**TextItem Interface:**

```typescript
interface TextItem {
  start_time: number;
  end_time: number;
  text: string;
}
```

**SubtitleConfig Parameters:**

| Parameter                 | Type     | Default        | Description                                    |
| ------------------------- | -------- | -------------- | ---------------------------------------------- |
| `font_pos_config`         | `FontPosConfig` | Required | Position and size configuration                |
| `font_size`               | `number` | `36`           | Font size in pixels                            |
| `font_color`              | `string` | `"#FFFFFFFF"`  | Font color in hex format (with alpha)          |
| `font_type`               | `string` | `"1525745"`    | Font Type (see Available Font Types section)   |
| `background_color`        | `string` | `"#00000000"`  | Background color in hex format                 |
| `background_border_width` | `number` | `0`            | Background border width                        |
| `border_width`            | `number` | `1`            | Text border width                              |
| `border_color`            | `string` | `"#00000088"`  | Border color in hex format                     |

**FontPosConfig Parameters:**

| Parameter | Type     | Default | Description                                      |
| --------- | -------- | ------- | ------------------------------------------------ |
| `pos_x`   | `string` | `"0"`   | X position (pixels or percentage, e.g., "0")     |
| `pos_y`   | `string` | `"90%"` | Y position (pixels or percentage, e.g., "90%")   |
| `width`   | `string` | `"100%"`| Width (pixels or percentage, e.g., "100%")       |
| `height`  | `string` | `"10%"` | Height (pixels or percentage, e.g., "10%")       |

**Note:** For available font Types, see the "Available Font Types" section under "Subtitle Management" in Key Points.

### compileVideoAudio() Method

```typescript
client.compileVideoAudio(
  video: string,
  audio: string,
  options?: {
    isVideoAudioSync?: boolean;
    outputSync?: OutputSync;
    isAudioReserve?: boolean;
    urlExpire?: number;
  }
): Promise<VideoEditResponse>
```

Combine video and audio tracks.

**Input Parameters:**

| Parameter          | Type         | Default   | Description                              |
| ------------------ | ------------ | --------- | ---------------------------------------- |
| `video`            | `string`     | Required  | Video URL                                |
| `audio`            | `string`     | Required  | Audio URL                                |
| `isVideoAudioSync` | `boolean`    | `false`   | Enable audio-video synchronization       |
| `outputSync`       | `OutputSync` | `undefined` | Sync configuration                       |
| `isAudioReserve`   | `boolean`    | `false`   | Keep original video audio                |
| `urlExpire`        | `number`     | `86400`   | URL expiration time in seconds (max 30d) |

**OutputSync Interface:**

```typescript
interface OutputSync {
  sync_method?: 'trim' | 'speed';
  sync_mode?: 'video' | 'audio';
}
```

### audioToSubtitle() Method

```typescript
client.audioToSubtitle(
  source: string,
  options?: {
    subtitleType?: 'srt' | 'webvtt';
    urlExpire?: number;
  }
): Promise<VideoEditResponse>
```

Convert speech in video/audio to subtitle file.

**Input Parameters:**

| Parameter      | Type     | Default | Description                              |
| -------------- | -------- | ------- | ---------------------------------------- |
| `source`       | `string` | Required| Video/Audio URL                          |
| `subtitleType` | `string` | `"srt"` | Subtitle format: "srt" or "webvtt"       |
| `urlExpire`    | `number` | `86400` | URL expiration time in seconds (max 30d) |

### extractAudio() Method

```typescript
client.extractAudio(
  video: string,
  options?: {
    format?: 'm4a' | 'mp3';
    urlExpire?: number;
  }
): Promise<VideoEditResponse>
```

Extract audio track from video.

**Input Parameters:**

| Parameter   | Type     | Default | Description                                      |
| ----------- | -------- | ------- | ------------------------------------------------ |
| `video`     | `string` | Required| Video URL                                        |
| `format`    | `string` | `"m4a"` | Audio format: "m4a" or "mp3"                     |
| `urlExpire` | `number` | `86400` | URL expiration time in seconds (min 1h, max 30d) |

**Response Interface:**

```typescript
interface VideoEditResponse {
  req_id: string;
  url: string;
  message?: string;
  video_meta?: {
    duration: number;
    resolution: string;
    type: string;
  };
  bill_info?: {
    duration: number;
    ratio: number;
  };
}
```

## Usage Examples

### Extract Frames by Key Frame

```typescript
import { FrameExtractorClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FrameExtractorClient(config);

const response = await client.extractByKeyFrame('https://example.com/video.mp4');

const frames = response.data.chunks;
for (const frame of frames) {
  const frameUrl = frame.screenshot;
  const timestampSec = frame.timestamp_ms / 1000;
}
```

### Extract Frames by Interval

```typescript
import { FrameExtractorClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FrameExtractorClient(config);

const response = await client.extractByInterval('https://example.com/video.mp4', 5000);

const frames = response.data.chunks;
for (const frame of frames) {
  const frameUrl = frame.screenshot;
  const timestampSec = frame.timestamp_ms / 1000;
}
```

### Extract Specific Number of Frames

```typescript
import { FrameExtractorClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FrameExtractorClient(config);

const response = await client.extractByCount('https://example.com/video.mp4', 10);

const frames = response.data.chunks;
```

### Trim Video

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const response = await client.videoTrim('https://example.com/video.mp4', {
  startTime: 10.5,
  endTime: 45.0,
});

const trimmedVideoUrl = response.url;
const duration = response.video_meta?.duration;
```

### Concatenate Videos with Transitions

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const response = await client.concatVideos(
  [
    'https://example.com/intro.mp4',
    'https://example.com/main.mp4',
    'https://example.com/outro.mp4',
  ],
  {
    transitions: ['1182356', '1182376'],
  }
);

const concatenatedVideoUrl = response.url;
```

### Add Subtitles with Custom Styling

```typescript
import { VideoEditClient, Config, SubtitleConfig, TextItem } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const subtitleConfig: SubtitleConfig = {
  font_pos_config: {
    pos_x: '0',
    pos_y: '90%',
    width: '100%',
    height: '10%',
  },
  font_size: 36,
  font_color: '#FFFFFFFF',
  font_type: '1525745',
  background_color: '#00000000',
  background_border_width: 0,
  border_width: 1,
  border_color: '#00000088',
};

const textList: TextItem[] = [
  { start_time: 0.0, end_time: 3.0, text: 'Hello, World!' },
  { start_time: 3.0, end_time: 6.0, text: 'Welcome to video editing!' },
  { start_time: 6.0, end_time: 9.0, text: 'Enjoy your content!' },
];

const response = await client.addSubtitles('https://example.com/video.mp4', subtitleConfig, {
  textList,
});

const videoWithSubtitlesUrl = response.url;
```

### Add Subtitles from File

```typescript
import { VideoEditClient, Config, SubtitleConfig } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const subtitleConfig: SubtitleConfig = {
  font_pos_config: {
    pos_x: '0',
    pos_y: '90%',
    width: '100%',
    height: '10%',
  },
  font_size: 36,
  font_color: '#FFFFFFFF',
  font_type: '1525745',
};

const response = await client.addSubtitles('https://example.com/video.mp4', subtitleConfig, {
  subtitleUrl: 'https://example.com/subtitles.srt',
});

const videoWithSubtitlesUrl = response.url;
```

### Compile Video and Audio

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const response = await client.compileVideoAudio(
  'https://example.com/video.mp4',
  'https://example.com/audio.mp3',
  {
    isAudioReserve: false,
  }
);

const compiledVideoUrl = response.url;
```

### Compile with Audio Sync

```typescript
import { VideoEditClient, Config, OutputSync } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const outputSync: OutputSync = {
  sync_method: 'trim',
  sync_mode: 'video',
};

const response = await client.compileVideoAudio(
  'https://example.com/video.mp4',
  'https://example.com/audio.mp3',
  {
    isVideoAudioSync: true,
    outputSync,
    isAudioReserve: false,
  }
);

const syncedVideoUrl = response.url;
```

### Convert Audio to Subtitle

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const response = await client.audioToSubtitle('https://example.com/video.mp4', {
  subtitleType: 'srt',
});

const subtitleFileUrl = response.url;
```

### Extract Audio from Video

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const response = await client.extractAudio('https://example.com/video.mp4', {
  format: 'mp3',
});

const extractedAudioUrl = response.url;
const duration = response.video_meta?.duration;
```

### Complete Video Processing Pipeline

```typescript
import { VideoEditClient, Config, SubtitleConfig } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

// Step 1: Trim video
const trimmed = await client.videoTrim('https://example.com/raw_video.mp4', {
  startTime: 5.0,
  endTime: 60.0,
});

// Step 2: Generate subtitles from audio
const subtitle = await client.audioToSubtitle(trimmed.url, {
  subtitleType: 'srt',
});

// Step 3: Add subtitles to video
const subtitleConfig: SubtitleConfig = {
  font_pos_config: {
    pos_x: '0',
    pos_y: '90%',
    width: '100%',
    height: '10%',
  },
  font_size: 36,
  font_color: '#FFFFFFFF',
  font_type: '1525745',
};

const final = await client.addSubtitles(trimmed.url, subtitleConfig, {
  subtitleUrl: subtitle.url,
});

const finalVideoUrl = final.url;
```

### Batch Frame Extraction (Parallel)

```typescript
import { FrameExtractorClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new FrameExtractorClient(config);

async function batchExtract() {
  const videos = [
    'https://example.com/video1.mp4',
    'https://example.com/video2.mp4',
    'https://example.com/video3.mp4',
  ];

  const results = await Promise.all(videos.map(url => client.extractByKeyFrame(url)));

  return results;
}

const results = await batchExtract();

const allFrames = results.map(response => response.data.chunks);
```

### Batch Video Trimming (Parallel)

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

async function batchTrim() {
  const videos = [
    { url: 'https://example.com/video1.mp4', start: 0, end: 30 },
    { url: 'https://example.com/video2.mp4', start: 10, end: 40 },
    { url: 'https://example.com/video3.mp4', start: 5, end: 35 },
  ];

  const results = await Promise.all(
    videos.map(({ url, start, end }) =>
      client.videoTrim(url, { startTime: start, endTime: end })
    )
  );

  return results;
}

const results = await batchTrim();

const trimmedUrls = results.map(response => response.url);
```

### Error Handling

```typescript
import { VideoEditClient, Config, APIError } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

try {
  const response = await client.videoTrim('https://example.com/video.mp4', {
    startTime: 0,
    endTime: 10,
  });

  const videoUrl = response.url;
} catch (error) {
  if (error instanceof APIError) {
    throw error;
  } else {
    throw error;
  }
}
```

### Custom Headers and Mock Mode

```typescript
import { VideoEditClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();

const customHeaders = {
  'x-run-mode': 'test_run',
  'x-custom-field': 'custom-value',
};

const client = new VideoEditClient(config, customHeaders);

const response = await client.videoTrim('https://example.com/video.mp4', {
  startTime: 0,
  endTime: 10,
});

const videoUrl = response.url;
```

### Extracting Forward Headers (Required)

**IMPORTANT**: Regardless of which backend framework you use (Next.js, Express, Koa, etc.), you **MUST** extract headers from the incoming request and forward them to the SDK using `HeaderUtils.extractForwardHeaders`. This is required for proper request tracing, authentication, and context propagation.

```typescript
import { HeaderUtils } from 'coze-coding-dev-sdk';

// Extract headers from your request object
const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

// Pass customHeaders to your SDK client
const client = new VideoEditClient(config, customHeaders);
const frameClient = new FrameExtractorClient(config, customHeaders);
```

**Example with Next.js:**

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { VideoEditClient, FrameExtractorClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

export async function POST(request: NextRequest) {
  const { videoUrl, startTime, endTime } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const config = new Config();
  const client = new VideoEditClient(config, customHeaders);

  const response = await client.videoTrim(videoUrl, {
    startTime,
    endTime,
  });

  return NextResponse.json({ url: response.url, videoMeta: response.video_meta });
}
```

**Example with Express:**

```typescript
import express, { Request, Response } from 'express';
import { VideoEditClient, FrameExtractorClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

const app = express();
app.use(express.json());

app.post('/api/video/trim', async (req: Request, res: Response) => {
  const { videoUrl, startTime, endTime } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(req.headers as Record<string, string>);

  const config = new Config();
  const client = new VideoEditClient(config, customHeaders);

  const response = await client.videoTrim(videoUrl, {
    startTime,
    endTime,
  });

  res.json({ url: response.url, videoMeta: response.video_meta });
});

app.post('/api/video/frames', async (req: Request, res: Response) => {
  const { videoUrl, count } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(req.headers as Record<string, string>);

  const config = new Config();
  const frameClient = new FrameExtractorClient(config, customHeaders);

  const frames = await frameClient.extractByCount(videoUrl, count || 10);

  res.json({ frames: frames.map((f) => ({ url: f.url, timestamp: f.timestamp })) });
});
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

| 字体名称                 | Font Type   | 备注        |
| ------------------------ | ----------- | ----------- |
| 方正兰亭大黑（繁体）     | `1525745`   | Set as default |
| 方正新楷体               | `1525743`   |             |
| 方正硬笔楷体             | `1525741`   |             |
| 方正悠宋506              | `1525739`   |             |
| 方正悠宋508              | `1525737`   |             |
| 方正兰亭黑简体           | `1234271`   |             |
| 方正兰亭圆简体           | `1234269`   |             |
| 方正兰亭圆简体粗         | `1234267`   | Bold        |
| 方正兰亭圆简体大         | `1234265`   | Large       |
| 方正兰亭圆简体特         | `1234263`   | Extra       |
| 方正兰亭圆简体细         | `1234259`   | Light       |
| 方正兰亭圆简体纤         | `1234257`   | Thin        |
| 方正兰亭圆简体中         | `1234255`   | Medium      |
| 方正兰亭圆简体中粗       | `1234253`   | Semi-Bold   |
| 方正兰亭圆简体准         | `1234251`   | Regular     |
| 方正综艺体               | `1234249`   |             |

##### 站酷字体 (Zcool Fonts)

| 字体名称           | Font Type   | 备注                              |
| ------------------ | ----------- | --------------------------------- |
| 站酷意大利体       | `1187225`   | ⚠️ 不支持中文 (No Chinese support) |
| 站酷仓耳渔阳体     | `1187223`   |                                   |
| 站酷高端黑         | `1187221`   |                                   |
| 站酷酷黑体         | `1187219`   |                                   |
| 站酷快乐体         | `1187217`   |                                   |
| 站酷文艺体         | `1187213`   |                                   |
| 站酷小薇 LOGO 体   | `1187211`   |                                   |

##### 其他字体 (Other Fonts)

| 字体名称           | Font Type     | 备注              |
| ------------------ | ------------- | ----------------- |
| 思源黑体           | `SY_Black`    | Source Han Sans   |
| 阿里巴巴普惠体     | `ALi_PuHui`   | Alibaba PuHuiTi   |
| 庞门正道标题体     | `PM_ZhengDao` |                   |

**Usage Example:**

```typescript
import { VideoEditClient, Config, SubtitleConfig } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new VideoEditClient(config);

const subtitleConfig: SubtitleConfig = {
  font_type: '1234271', // 方正兰亭黑简体
  font_size: 36,
  font_color: '#FFFFFFFF',
  font_pos_config: {
    pos_x: '0',
    pos_y: '90%',
    width: '100%',
    height: '10%',
  },
};

const response = await client.addSubtitles('https://example.com/video.mp4', subtitleConfig, {
  subtitleUrl: 'https://example.com/subtitle.srt',
});
```

### Audio Operations

- **Audio Extraction**: Extract audio track from video
- **Format Options**: M4A and MP3 output formats
- **Audio Compilation**: Combine video and audio tracks
- **Sync Options**: Trim or speed adjustment for audio-video sync
- **Reserve Original**: Option to keep original video audio

### General

- **Backend Only**: Never expose API keys in client-side code
- **Config Management**: Use `Config` class for proper API authentication
- **Custom Headers**: Use `customHeaders` for mock mode or custom metadata
- **Parallel Processing**: Use `Promise.all()` for batch processing
- **Error Handling**: Always handle exceptions and check response status
- **Verbose Mode**: Enable detailed HTTP logging for debugging
- **Mock Mode**: Use mock mode for testing without consuming resources
- **Billing Info**: Response includes billing information for cost tracking
- **URL Storage**: The returned URLs are already stored in object storage with a valid expiration period. Unless absolutely necessary, use these URLs directly without re-uploading to your own object storage system