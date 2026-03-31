# Voice Skill TypeScript SDK

This skill guides the implementation of voice functionality using the coze-coding-dev-sdk package and CLI tool, enabling both text-to-speech synthesis and speech-to-text recognition capabilities.

## Overview

Voice capabilities allow you to build applications with speech synthesis (TTS) and speech recognition (ASR), enabling voice assistants, audio content generation, transcription services, and voice-enabled user interfaces.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

### Text-to-Speech (TTS)

```typescript
import { TTSClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new TTSClient(config);

const response = await client.synthesize({
  uid: 'user123',
  text: 'Hello, welcome to voice synthesis!'
});

const audioData = await axios.get(response.audioUri, { responseType: 'arraybuffer' });
fs.writeFileSync('output.mp3', audioData.data);
```

### Automatic Speech Recognition (ASR)

```typescript
import { ASRClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new ASRClient(config);

const result = await client.recognize({
  uid: 'user123',
  url: 'https://example.com/audio.mp3'
});

console.log(`Recognized text: ${result.text}`);
```

**About Config:**

- `Config` manages SDK configuration including API key, base URL, and timeout settings
- API credentials are automatically loaded from environment variables
- **Optional**: You can pass custom configuration: `new Config({ apiKey: 'your-key', timeout: 30000 })`
- Recommended for production environments to enable proper authentication and error handling

## API Reference

## Text-to-Speech (TTS)

### Client Initialization

```typescript
new TTSClient(
  config?: Config,
  customHeaders?: Record<string, string>
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `customHeaders`: Custom HTTP headers (e.g., `{ "x-run-mode": "test_run" }`)

### synthesize() Method

```typescript
client.synthesize(request: TTSRequest): Promise<TTSResponse>
```

**TTSRequest Interface:**

```typescript
interface TTSRequest {
  uid: string;
  text?: string;
  ssml?: string;
  speaker?: string;
  audioFormat?: 'mp3' | 'pcm' | 'ogg_opus';
  sampleRate?: 8000 | 16000 | 22050 | 24000 | 32000 | 44100 | 48000;
  speechRate?: number;
  loudnessRate?: number;
}
```

**Input Parameters:**

| Parameter      | Type     | Default                            | Description                                  |
| -------------- | -------- | ---------------------------------- | -------------------------------------------- |
| `uid`          | `string` | Required                           | User unique identifier                       |
| `text`         | `string` | `undefined`                        | Text to synthesize (required if no SSML)     |
| `ssml`         | `string` | `undefined`                        | SSML format text (required if no text)       |
| `speaker`      | `string` | `"zh_female_xiaohe_uranus_bigtts"` | Voice/speaker ID                             |
| `audioFormat`  | `string` | `"mp3"`                            | Audio format: `"mp3"`, `"pcm"`, `"ogg_opus"` |
| `sampleRate`   | `number` | `24000`                            | Sample rate (8000-48000 Hz)                  |
| `speechRate`   | `number` | `0`                                | Speech rate adjustment (-50 to 100)          |
| `loudnessRate` | `number` | `0`                                | Volume adjustment (-50 to 100)               |

**TTSResponse Interface:**

```typescript
interface TTSResponse {
  audioUri: string;
  audioSize: number;
}
```

**Returns:** Audio URL and audio size in bytes

### Available Voices

**General Purpose:**
- `zh_female_xiaohe_uranus_bigtts` - Xiaohe (default, general)
- `zh_female_vv_uranus_bigtts` - Vivi (Chinese & English)
- `zh_male_m191_uranus_bigtts` - Yunzhou (male)
- `zh_male_taocheng_uranus_bigtts` - Xiaotian (male)

**Audiobook/Reading:**
- `zh_female_xueayi_saturn_bigtts` - Children's audiobook

**Video Dubbing:**
- `zh_male_dayi_saturn_bigtts` - Dayi (male)
- `zh_female_mizai_saturn_bigtts` - Mizai (female)
- `zh_female_jitangnv_saturn_bigtts` - Motivational female
- `zh_female_meilinvyou_saturn_bigtts` - Charming girlfriend
- `zh_female_santongyongns_saturn_bigtts` - Smooth female
- `zh_male_ruyayichen_saturn_bigtts` - Elegant male

**Role Playing:**
- `saturn_zh_female_keainvsheng_tob` - Cute girl
- `saturn_zh_female_tiaopigongzhu_tob` - Playful princess
- `saturn_zh_male_shuanglangshaonian_tob` - Cheerful boy
- `saturn_zh_male_tiancaitongzhuo_tob` - Genius classmate
- `saturn_zh_female_cancan_tob` - Intellectual Cancan

### Audio Formats

| Format     | Description                  | Use Case                    |
| ---------- | ---------------------------- | --------------------------- |
| `mp3`      | MP3 compressed audio         | General use, web streaming  |
| `pcm`      | Raw PCM audio                | Processing, low latency     |
| `ogg_opus` | Ogg Opus compressed audio    | High quality, low bandwidth |

### Sample Rates

Supported: `8000`, `16000`, `22050`, `24000`, `32000`, `44100`, `48000` Hz

- `8000-16000`: Phone quality
- `22050-24000`: Standard quality (default)
- `32000-48000`: High quality

## Automatic Speech Recognition (ASR)

### Audio Requirements

Before using ASR, please ensure your audio meets the following requirements:

- **Audio Duration**: ≤ 2 hours
- **Audio Size**: ≤ 100MB
- **Supported Formats**: WAV/MP3/OGG OPUS/M4A

### Client Initialization

```typescript
new ASRClient(
  config?: Config,
  customHeaders?: Record<string, string>
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `customHeaders`: Custom HTTP headers (e.g., `{ "x-run-mode": "test_run" }`)

### recognize() Method

```typescript
client.recognize(request: ASRRequest): Promise<ASRResponse>
```

**ASRRequest Interface:**

```typescript
interface ASRRequest {
  uid?: string;
  url?: string;
  base64Data?: string;
}
```

**Input Parameters:**

| Parameter    | Type     | Default     | Description                                 |
| ------------ | -------- | ----------- | ------------------------------------------- |
| `uid`        | `string` | `undefined` | User unique identifier                      |
| `url`        | `string` | `undefined` | Audio file URL (required if no base64Data)  |
| `base64Data` | `string` | `undefined` | Base64 encoded audio (required if no URL)   |

**ASRResponse Interface:**

```typescript
interface ASRResponse {
  text: string;
  duration?: number;
  utterances?: any[];
  rawData: any;
}
```

**Response Fields:**

- `text`: Recognized text
- `duration`: Audio duration in milliseconds
- `utterances`: Detailed recognition results with timestamps
- `rawData`: Complete API response data

## Usage Examples

### Basic Text-to-Speech

```typescript
import { TTSClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new TTSClient(config);

const response = await client.synthesize({
  uid: 'user123',
  text: 'Welcome to our service!'
});

console.log(`Audio URL: ${response.audioUri}`);
console.log(`Audio size: ${response.audioSize} bytes`);

const audioData = await axios.get(response.audioUri, { responseType: 'arraybuffer' });
fs.writeFileSync('welcome.mp3', audioData.data);
```

### TTS with Different Voices

```typescript
import { TTSClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new TTSClient(config);

const voices = {
  male: 'zh_male_m191_uranus_bigtts',
  female: 'zh_female_xiaohe_uranus_bigtts',
  child: 'zh_female_xueayi_saturn_bigtts'
};

const text = 'This is a voice test.';

for (const [name, speaker] of Object.entries(voices)) {
  const response = await client.synthesize({
    uid: 'user123',
    text,
    speaker
  });
  
  const audioData = await axios.get(response.audioUri, { responseType: 'arraybuffer' });
  fs.writeFileSync(`voice_${name}.mp3`, audioData.data);
  
  console.log(`Generated ${name} voice: voice_${name}.mp3`);
}
```

### TTS with Custom Parameters

```typescript
import { TTSClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new TTSClient(config);

const response = await client.synthesize({
  uid: 'user123',
  text: 'This is a fast and loud announcement!',
  speaker: 'zh_male_dayi_saturn_bigtts',
  audioFormat: 'mp3',
  sampleRate: 48000,
  speechRate: 30,
  loudnessRate: 20
});

const audioData = await axios.get(response.audioUri, { responseType: 'arraybuffer' });
fs.writeFileSync('announcement.mp3', audioData.data);

console.log(`Generated high-quality audio: ${response.audioSize} bytes`);
```

### TTS with SSML

```typescript
import { TTSClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new TTSClient(config);

const ssmlText = `
<speak>
  <prosody rate="slow">Hello</prosody>
  <break time="500ms"/>
  <prosody rate="fast">Welcome to our service!</prosody>
</speak>
`;

const response = await client.synthesize({
  uid: 'user123',
  ssml: ssmlText,
  speaker: 'zh_female_vv_uranus_bigtts'
});

const audioData = await axios.get(response.audioUri, { responseType: 'arraybuffer' });
fs.writeFileSync('ssml_output.mp3', audioData.data);
```

### TTS with Different Audio Formats

```typescript
import { TTSClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new TTSClient(config);

const text = 'Audio format test';
const formats: Array<'mp3' | 'pcm' | 'ogg_opus'> = ['mp3', 'pcm', 'ogg_opus'];

for (const fmt of formats) {
  const response = await client.synthesize({
    uid: 'user123',
    text,
    audioFormat: fmt,
    sampleRate: 24000
  });
  
  const audioData = await axios.get(response.audioUri, { responseType: 'arraybuffer' });
  const extension = fmt === 'ogg_opus' ? 'opus' : fmt;
  fs.writeFileSync(`output.${extension}`, audioData.data);
  
  console.log(`Generated ${fmt}: ${response.audioSize} bytes`);
}
```

### Basic Speech Recognition from URL

```typescript
import { ASRClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new ASRClient(config);

const result = await client.recognize({
  uid: 'user123',
  url: 'https://example.com/audio.mp3'
});

console.log(`Recognized text: ${result.text}`);

if (result.duration) {
  console.log(`Audio duration: ${result.duration / 1000} seconds`);
}
```

### Speech Recognition from Base64

```typescript
import { ASRClient, Config } from 'coze-coding-dev-sdk';
import fs from 'fs';

const config = new Config();
const client = new ASRClient(config);

const audioData = fs.readFileSync('audio.mp3');
const audioBase64 = audioData.toString('base64');

const result = await client.recognize({
  uid: 'user123',
  base64Data: audioBase64
});

console.log(`Recognized text: ${result.text}`);
```

### Speech Recognition with Detailed Results

```typescript
import { ASRClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const client = new ASRClient(config);

const result = await client.recognize({
  uid: 'user123',
  url: 'https://example.com/audio.mp3'
});

console.log(`Full text: ${result.text}`);
console.log('\nDetailed results:');

if (result.utterances) {
  result.utterances.forEach((utterance, i) => {
    console.log(`\nSegment ${i + 1}:`);
    console.log(`  Text: ${utterance.text || ''}`);
    console.log(`  Start: ${utterance.start_time || 0}ms`);
    console.log(`  End: ${utterance.end_time || 0}ms`);
  });
}
```

### TTS + ASR Pipeline

```typescript
import { TTSClient, ASRClient, Config } from 'coze-coding-dev-sdk';

const config = new Config();
const ttsClient = new TTSClient(config);
const asrClient = new ASRClient(config);

const originalText = 'Hello, this is a test of the voice pipeline.';
console.log(`Original text: ${originalText}`);

const ttsResponse = await ttsClient.synthesize({
  uid: 'user123',
  text: originalText
});

console.log(`\nGenerated audio: ${ttsResponse.audioUri}`);
console.log(`Audio size: ${ttsResponse.audioSize} bytes`);

const asrResult = await asrClient.recognize({
  uid: 'user123',
  url: ttsResponse.audioUri
});

console.log(`\nRecognized text: ${asrResult.text}`);

if (originalText.toLowerCase() === asrResult.text.toLowerCase()) {
  console.log('\n✓ Perfect match!');
} else {
  console.log('\n⚠ Text differs (may be due to punctuation)');
}
```

### Batch TTS Generation

```typescript
import { TTSClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();
const client = new TTSClient(config);

const texts = [
  'Welcome to chapter one.',
  'Welcome to chapter two.',
  'Welcome to chapter three.'
];

for (let i = 0; i < texts.length; i++) {
  const response = await client.synthesize({
    uid: 'user123',
    text: texts[i],
    speaker: 'zh_female_xueayi_saturn_bigtts'
  });
  
  const audioData = await axios.get(response.audioUri, { responseType: 'arraybuffer' });
  fs.writeFileSync(`chapter_${i + 1}.mp3`, audioData.data);
  
  console.log(`Generated chapter ${i + 1}: ${response.audioSize} bytes`);
}
```

### TTS with Custom Headers

```typescript
import { TTSClient, Config } from 'coze-coding-dev-sdk';
import axios from 'axios';
import fs from 'fs';

const config = new Config();

const customHeaders = {
  'x-run-mode': 'test_run',
  'x-custom-field': 'custom-value'
};

const client = new TTSClient(config, customHeaders);

const response = await client.synthesize({
  uid: 'user123',
  text: 'Testing with custom headers'
});

const audioData = await axios.get(response.audioUri, { responseType: 'arraybuffer' });
fs.writeFileSync('test_output.mp3', audioData.data);
```

### Extracting Forward Headers (Required)

**IMPORTANT**: Regardless of which backend framework you use (Next.js, Express, Koa, etc.), you **MUST** extract headers from the incoming request and forward them to the SDK using `HeaderUtils.extractForwardHeaders`. This is required for proper request tracing, authentication, and context propagation.

**IMPORTANT**: This feature requires `coze-coding-dev-sdk` version >=0.7.10. **MUST** check the sdk version before use it.

```typescript
import { HeaderUtils } from 'coze-coding-dev-sdk';

// Extract headers from your request object
const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

// Pass customHeaders to your SDK client
const ttsClient = new TTSClient(config, customHeaders);
const asrClient = new ASRClient(config, customHeaders);
```

**Example with Next.js:**

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { TTSClient, ASRClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

export async function POST(request: NextRequest) {
  const { text, audioUrl } = await request.json();
  const customHeaders = HeaderUtils.extractForwardHeaders(request.headers);

  const config = new Config();

  if (text) {
    const ttsClient = new TTSClient(config, customHeaders);
    const response = await ttsClient.synthesize({
      uid: 'user123',
      text,
    });
    return NextResponse.json({ audioUri: response.audioUri });
  }

  if (audioUrl) {
    const asrClient = new ASRClient(config, customHeaders);
    const result = await asrClient.recognize({
      uid: 'user123',
      url: audioUrl,
    });
    return NextResponse.json({ text: result.text });
  }

  return NextResponse.json({ error: 'Missing text or audioUrl' }, { status: 400 });
}
```

**Example with Express:**

```typescript
import express, { Request, Response } from 'express';
import { TTSClient, ASRClient, Config, HeaderUtils } from 'coze-coding-dev-sdk';

const app = express();
app.use(express.json());

app.post('/api/tts', async (req: Request, res: Response) => {
  const { text } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(req.headers as Record<string, string>);

  const config = new Config();
  const ttsClient = new TTSClient(config, customHeaders);

  const response = await ttsClient.synthesize({
    uid: 'user123',
    text,
  });

  res.json({ audioUri: response.audioUri });
});

app.post('/api/asr', async (req: Request, res: Response) => {
  const { audioUrl } = req.body;
  const customHeaders = HeaderUtils.extractForwardHeaders(req.headers as Record<string, string>);

  const config = new Config();
  const asrClient = new ASRClient(config, customHeaders);

  const result = await asrClient.recognize({
    uid: 'user123',
    url: audioUrl,
  });

  res.json({ text: result.text });
});
```

### Error Handling

```typescript
import { TTSClient, ASRClient, Config, APIError, ValidationError } from 'coze-coding-dev-sdk';

const config = new Config();

try {
  const ttsClient = new TTSClient(config);
  const response = await ttsClient.synthesize({
    uid: 'user123',
    text: 'Hello world'
  });
  console.log('TTS Success:', response.audioUri);
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Validation Error:', error.message);
  } else if (error instanceof APIError) {
    console.error('API Error:', error.message);
    console.error('Status Code:', error.statusCode);
  } else {
    console.error('Unexpected error:', error);
  }
}

try {
  const asrClient = new ASRClient(config);
  const result = await asrClient.recognize({
    uid: 'user123',
    url: 'https://example.com/audio.mp3'
  });
  console.log('ASR Success:', result.text);
} catch (error) {
  if (error instanceof APIError) {
    console.error('ASR API Error:', error.message);
  } else {
    console.error('Unexpected error:', error);
  }
}
```

## CLI Usage

The SDK includes command-line tools `coze-coding-ai tts` and `coze-coding-ai asr` for quick voice operations without writing code.

### TTS CLI Usage

**Basic CLI Usage:**

```bash
coze-coding-ai tts --text "Hello, welcome!"
```

**CLI Options:**

```bash
coze-coding-ai tts [OPTIONS]

Options:
  -t, --text <text>       Text to synthesize [required]
  --speaker <speaker>     Voice/speaker ID (default: zh_female_xiaohe_uranus_bigtts)
  --mock                  Use mock mode (test run)
  -H, --header <header>   Custom HTTP header (format: "Key: Value" or "Key=Value")
  --help                  Show this message and exit
```

**TTS CLI Examples:**

**Basic synthesis:**

```bash
coze-coding-ai tts --text "Hello, world!"
```

**With different voice:**

```bash
coze-coding-ai tts \
  --text "Video narration" \
  --speaker zh_male_dayi_saturn_bigtts
```

**With custom headers:**

```bash
coze-coding-ai tts \
  --text "Important announcement!" \
  --header "x-custom-field: custom-value" \
  --header "x-request-id: 12345"
```

**Mock mode (testing):**

```bash
coze-coding-ai tts \
  --text "Test synthesis" \
  --mock
```

### ASR CLI Usage

**Basic CLI Usage:**

```bash
coze-coding-ai asr --url https://example.com/audio.mp3
```

**CLI Options:**

```bash
coze-coding-ai asr [OPTIONS]

Options:
  -u, --url <url>         Audio file URL
  -f, --file <path>       Local audio file path (will be base64 encoded)
  -H, --header <header>   Custom HTTP header (format: "Key: Value" or "Key=Value")
  --help                  Show this message and exit
```

**ASR CLI Examples:**

**Recognize from URL:**

```bash
coze-coding-ai asr --url https://example.com/audio.mp3
```

**Recognize local file:**

```bash
coze-coding-ai asr --file audio.mp3
```

**With custom headers:**

```bash
coze-coding-ai asr \
  --url https://example.com/audio.mp3 \
  --header "x-custom-field: custom-value"
```

## Key Points

### Text-to-Speech (TTS)

- **Voice Selection**: 15+ voices available for different scenarios (general, audiobook, video, role-playing)
- **Audio Formats**: Support MP3, PCM, and Ogg Opus formats
- **Sample Rates**: 8000-48000 Hz range for different quality needs
- **Speech Control**: Adjust speech rate (-50 to +100) and volume (-50 to +100)
- **SSML Support**: Use SSML for advanced speech control (prosody, breaks, emphasis)
- **Backend Only**: Never expose API keys in client-side code
- **Config Management**: Use `Config` class for proper API authentication
- **Custom Headers**: Use `customHeaders` for mock mode or custom metadata
- **Streaming Response**: Audio is delivered via streaming for efficient processing

### Automatic Speech Recognition (ASR)

- **Input Methods**: Support URL and Base64 encoded audio
- **Audio Formats**: Support common audio formats (MP3, WAV, OGG OPUS, M4A)
- **Audio Limits**: Maximum 2 hours duration, 100MB file size
- **Detailed Results**: Get timestamps and segmented utterances
- **Duration Info**: Receive audio duration in response
- **Backend Only**: Never expose API keys in client-side code
- **Config Management**: Use `Config` class for proper API authentication
- **Custom Headers**: Use `customHeaders` for mock mode or custom metadata

### General

- **Pipeline Support**: Combine TTS and ASR for voice processing workflows
- **CLI Tools**: Use `coze-coding-ai tts` and `coze-coding-ai asr` for quick operations
- **Error Handling**: Always handle exceptions and check response status
- **User ID**: Use consistent `uid` for tracking and analytics
- **Mock Mode**: Use mock mode for testing without consuming resources
- **Validation**: SDK validates required parameters (text/ssml for TTS, url/base64Data for ASR)