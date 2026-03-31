# Voice Skill Python SDK

This skill guides the implementation of voice functionality using the coze-coding-dev-sdk package and CLI tool, enabling both text-to-speech synthesis and speech-to-text recognition capabilities.

## Overview

Voice capabilities allow you to build applications with speech synthesis (TTS) and speech recognition (ASR), enabling voice assistants, audio content generation, transcription services, and voice-enabled user interfaces.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

### Text-to-Speech (TTS)

```python
from coze_coding_dev_sdk import TTSClient
from coze_coding_utils.runtime_ctx.context import new_context
import requests

ctx = new_context(method="tts.synthesize")

client = TTSClient(ctx=ctx)

audio_url, audio_size = client.synthesize(
    uid="user123",
    text="Hello, welcome to voice synthesis!"
)

audio_data = requests.get(audio_url).content
with open("output.mp3", 'wb') as f:
    f.write(audio_data)
```

### Automatic Speech Recognition (ASR)

```python
from coze_coding_dev_sdk import ASRClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="asr.recognize")

client = ASRClient(ctx=ctx)

text, data = client.recognize(
    uid="user123",
    url="https://example.com/audio.mp3"
)

print(f"Recognized text: {text}")
```

**About Context (`ctx`):**

- `Context` is used for request tracking and tracing across distributed systems
- It automatically injects headers like `request_id`, `trace_id`, and `user_id` into API calls
- **Optional**: If you don't need request tracking, you can omit `ctx` parameter: `TTSClient()` or `ASRClient()`
- Recommended for production environments to enable observability and debugging

## API Reference

## Text-to-Speech (TTS)

### Client Initialization

```python
TTSClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None,
    custom_headers: Optional[Dict[str, str]] = None
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `ctx`: Context for request tracking (request_id, trace_id, user_id)
- `custom_headers`: Custom HTTP headers (e.g., `{"x-run-mode": "test_run"}`)

### synthesize() Method

```python
client.synthesize(
    uid: str,
    text: Optional[str] = None,
    ssml: Optional[str] = None,
    speaker: str = "zh_female_xiaohe_uranus_bigtts",
    audio_format: str = "mp3",
    sample_rate: int = 24000,
    speech_rate: int = 0,
    loudness_rate: int = 0
) -> Tuple[str, int]
```

**Input Parameters:**

| Parameter       | Type   | Default                              | Description                                  |
| --------------- | ------ | ------------------------------------ | -------------------------------------------- |
| `uid`           | `str`  | Required                             | User unique identifier                       |
| `text`          | `str`  | `None`                               | Text to synthesize (required if no SSML)     |
| `ssml`          | `str`  | `None`                               | SSML format text (required if no text)       |
| `speaker`       | `str`  | `"zh_female_xiaohe_uranus_bigtts"`   | Voice/speaker ID                             |
| `audio_format`  | `str`  | `"mp3"`                              | Audio format: `"mp3"`, `"pcm"`, `"ogg_opus"` |
| `sample_rate`   | `int`  | `24000`                              | Sample rate (8000-48000 Hz)                  |
| `speech_rate`   | `int`  | `0`                                  | Speech rate adjustment (-50 to 100)          |
| `loudness_rate` | `int`  | `0`                                  | Volume adjustment (-50 to 100)               |

**Returns:** `Tuple[str, int]` - Audio URL and audio size in bytes

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

```python
ASRClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None,
    custom_headers: Optional[Dict[str, str]] = None
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `ctx`: Context for request tracking (request_id, trace_id, user_id)
- `custom_headers`: Custom HTTP headers (e.g., `{"x-run-mode": "test_run"}`)

### recognize() Method

```python
client.recognize(
    uid: Optional[str] = None,
    url: Optional[str] = None,
    base64_data: Optional[str] = None
) -> Tuple[str, dict]
```

**Input Parameters:**

| Parameter     | Type  | Default | Description                                     |
| ------------- | ----- | ------- | ----------------------------------------------- |
| `uid`         | `str` | `None`  | User unique identifier                          |
| `url`         | `str` | `None`  | Audio file URL (required if no base64_data)     |
| `base64_data` | `str` | `None`  | Base64 encoded audio (required if no URL)       |

**Returns:** `Tuple[str, dict]` - Recognized text and detailed response data

**Response Data Fields:**

- `text`: Recognized text
- `duration`: Audio duration in milliseconds
- `utterances`: Detailed recognition results with timestamps

## Usage Examples

### Basic Text-to-Speech

```python
from coze_coding_dev_sdk import TTSClient
from coze_coding_utils.runtime_ctx.context import new_context
import requests

ctx = new_context(method="tts.synthesize")

client = TTSClient(ctx=ctx)

audio_url, audio_size = client.synthesize(
    uid="user123",
    text="Welcome to our service!"
)

print(f"Audio URL: {audio_url}")
print(f"Audio size: {audio_size} bytes")

audio_data = requests.get(audio_url).content
with open("welcome.mp3", 'wb') as f:
    f.write(audio_data)
```

### TTS with Different Voices

```python
from coze_coding_dev_sdk import TTSClient
from coze_coding_utils.runtime_ctx.context import new_context
import requests

ctx = new_context(method="tts.synthesize")

client = TTSClient(ctx=ctx)

voices = {
    "male": "zh_male_m191_uranus_bigtts",
    "female": "zh_female_xiaohe_uranus_bigtts",
    "child": "zh_female_xueayi_saturn_bigtts"
}

text = "This is a voice test."

for name, speaker in voices.items():
    audio_url, _ = client.synthesize(
        uid="user123",
        text=text,
        speaker=speaker
    )
    
    audio_data = requests.get(audio_url).content
    with open(f"voice_{name}.mp3", 'wb') as f:
        f.write(audio_data)
    
    print(f"Generated {name} voice: voice_{name}.mp3")
```

### TTS with Custom Parameters

```python
from coze_coding_dev_sdk import TTSClient
from coze_coding_utils.runtime_ctx.context import new_context
import requests

ctx = new_context(method="tts.synthesize")

client = TTSClient(ctx=ctx)

audio_url, audio_size = client.synthesize(
    uid="user123",
    text="This is a fast and loud announcement!",
    speaker="zh_male_dayi_saturn_bigtts",
    audio_format="mp3",
    sample_rate=48000,
    speech_rate=30,
    loudness_rate=20
)

audio_data = requests.get(audio_url).content
with open("announcement.mp3", 'wb') as f:
    f.write(audio_data)

print(f"Generated high-quality audio: {audio_size} bytes")
```

### TTS with SSML

```python
from coze_coding_dev_sdk import TTSClient
from coze_coding_utils.runtime_ctx.context import new_context
import requests

ctx = new_context(method="tts.synthesize")

client = TTSClient(ctx=ctx)

ssml_text = """
<speak>
    <prosody rate="slow">Hello</prosody>
    <break time="500ms"/>
    <prosody rate="fast">Welcome to our service!</prosody>
</speak>
"""

audio_url, audio_size = client.synthesize(
    uid="user123",
    ssml=ssml_text,
    speaker="zh_female_vv_uranus_bigtts"
)

audio_data = requests.get(audio_url).content
with open("ssml_output.mp3", 'wb') as f:
    f.write(audio_data)
```

### TTS with Different Audio Formats

```python
from coze_coding_dev_sdk import TTSClient
from coze_coding_utils.runtime_ctx.context import new_context
import requests

ctx = new_context(method="tts.synthesize")

client = TTSClient(ctx=ctx)

text = "Audio format test"

formats = ["mp3", "pcm", "ogg_opus"]

for fmt in formats:
    audio_url, audio_size = client.synthesize(
        uid="user123",
        text=text,
        audio_format=fmt,
        sample_rate=24000
    )
    
    audio_data = requests.get(audio_url).content
    extension = "opus" if fmt == "ogg_opus" else fmt
    with open(f"output.{extension}", 'wb') as f:
        f.write(audio_data)
    
    print(f"Generated {fmt}: {audio_size} bytes")
```

### Basic Speech Recognition from URL

```python
from coze_coding_dev_sdk import ASRClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="asr.recognize")

client = ASRClient(ctx=ctx)

text, data = client.recognize(
    uid="user123",
    url="https://example.com/audio.mp3"
)

print(f"Recognized text: {text}")

duration = data.get("result", {}).get("duration")
if duration:
    print(f"Audio duration: {duration / 1000:.1f} seconds")
```

### Speech Recognition from Base64

```python
from coze_coding_dev_sdk import ASRClient
from coze_coding_utils.runtime_ctx.context import new_context
import base64

ctx = new_context(method="asr.recognize")

client = ASRClient(ctx=ctx)

with open("audio.mp3", "rb") as f:
    audio_data = f.read()
    audio_base64 = base64.b64encode(audio_data).decode("utf-8")

text, data = client.recognize(
    uid="user123",
    base64_data=audio_base64
)

print(f"Recognized text: {text}")
```

### Speech Recognition with Detailed Results

```python
from coze_coding_dev_sdk import ASRClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="asr.recognize")

client = ASRClient(ctx=ctx)

text, data = client.recognize(
    uid="user123",
    url="https://example.com/audio.mp3"
)

print(f"Full text: {text}")
print(f"\nDetailed results:")

result = data.get("result", {})
utterances = result.get("utterances", [])

for i, utterance in enumerate(utterances, 1):
    print(f"\nSegment {i}:")
    print(f"  Text: {utterance.get('text', '')}")
    print(f"  Start: {utterance.get('start_time', 0)}ms")
    print(f"  End: {utterance.get('end_time', 0)}ms")
```

### TTS + ASR Pipeline

```python
from coze_coding_dev_sdk import TTSClient, ASRClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="tts.synthesize")

tts_client = TTSClient(ctx=ctx)
asr_client = ASRClient(ctx=ctx)

original_text = "Hello, this is a test of the voice pipeline."
print(f"Original text: {original_text}")

audio_url, audio_size = tts_client.synthesize(
    uid="user123",
    text=original_text
)

print(f"\nGenerated audio: {audio_url}")
print(f"Audio size: {audio_size} bytes")

recognized_text, data = asr_client.recognize(
    uid="user123",
    url=audio_url
)

print(f"\nRecognized text: {recognized_text}")

if original_text.lower() == recognized_text.lower():
    print("\n✓ Perfect match!")
else:
    print("\n⚠ Text differs (may be due to punctuation)")
```

### Batch TTS Generation

```python
from coze_coding_dev_sdk import TTSClient
from coze_coding_utils.runtime_ctx.context import new_context
import requests

ctx = new_context(method="tts.synthesize")

client = TTSClient(ctx=ctx)

texts = [
    "Welcome to chapter one.",
    "Welcome to chapter two.",
    "Welcome to chapter three."
]

for i, text in enumerate(texts, 1):
    audio_url, audio_size = client.synthesize(
        uid="user123",
        text=text,
        speaker="zh_female_xueayi_saturn_bigtts"
    )
    
    audio_data = requests.get(audio_url).content
    with open(f"chapter_{i}.mp3", 'wb') as f:
        f.write(audio_data)
    
    print(f"Generated chapter {i}: {audio_size} bytes")
```

### TTS with Custom Headers

```python
from coze_coding_dev_sdk import TTSClient
from coze_coding_utils.runtime_ctx.context import new_context
import requests

ctx = new_context(method="tts.synthesize")

custom_headers = {
    "x-run-mode": "test_run",
    "x-custom-field": "custom-value"
}

client = TTSClient(ctx=ctx, custom_headers=custom_headers)

audio_url, audio_size = client.synthesize(
    uid="user123",
    text="Testing with custom headers"
)

audio_data = requests.get(audio_url).content
with open("test_output.mp3", 'wb') as f:
    f.write(audio_data)
```

## CLI Usage

The SDK includes command-line tools `coze-coding-ai tts` and `coze-coding-ai asr` for quick voice operations without writing code.

### TTS CLI Usage

**Basic CLI Usage:**

```bash
coze-coding-ai tts "Hello, welcome!" --output hello.mp3
```

**CLI Options:**

```bash
coze-coding-ai tts TEXT [OPTIONS]

Arguments:
  TEXT                    Text to synthesize [required]

Options:
  -o, --output PATH       Output audio file path [required]
  -u, --uid TEXT          User unique identifier (default: cli_user)
  -s, --speaker TEXT      Voice/speaker ID (default: zh_female_xiaohe_uranus_bigtts)
  -f, --format [mp3|pcm|ogg_opus]  Audio format (default: mp3)
  --sample-rate INTEGER   Sample rate in Hz (default: 24000)
  --speech-rate INTEGER   Speech rate -50 to 100 (default: 0)
  --loudness-rate INTEGER Volume -50 to 100 (default: 0)
  --ssml                  Use SSML format
  --mock                  Use mock mode (test run)
  --help                  Show this message and exit
```

**TTS CLI Examples:**

**Basic synthesis:**

```bash
coze-coding-ai tts "Hello, world!" --output hello.mp3
```

**With different voice:**

```bash
coze-coding-ai tts "Video narration" \
  --output narration.mp3 \
  --speaker zh_male_dayi_saturn_bigtts
```

**Fast and loud:**

```bash
coze-coding-ai tts "Important announcement!" \
  --output announcement.mp3 \
  --speech-rate 30 \
  --loudness-rate 20
```

**High quality audio:**

```bash
coze-coding-ai tts "High quality audio" \
  --output hq_audio.mp3 \
  --sample-rate 48000 \
  --format mp3
```

**SSML format:**

```bash
coze-coding-ai tts "<speak><prosody rate='slow'>Hello</prosody></speak>" \
  --output ssml.mp3 \
  --ssml
```

**Mock mode (testing):**

```bash
coze-coding-ai tts "Test synthesis" \
  --output test.mp3 \
  --mock
```

### ASR CLI Usage

**Basic CLI Usage:**

```bash
coze-coding-ai asr audio.mp3
```

**CLI Options:**

```bash
coze-coding-ai asr AUDIO [OPTIONS]

Arguments:
  AUDIO                   Audio file path or URL [required]

Options:
  -u, --uid TEXT          User unique identifier (default: cli_user)
  -o, --output PATH       Output text file path
  -f, --format [text|json]  Output format (default: text)
  --base64                Convert local file to base64 for upload
  --mock                  Use mock mode (test run)
  --help                  Show this message and exit
```

**ASR CLI Examples:**

**Recognize from URL:**

```bash
coze-coding-ai asr https://example.com/audio.mp3
```

**Recognize local file with base64:**

```bash
coze-coding-ai asr audio.mp3 --base64
```

**Save to file:**

```bash
coze-coding-ai asr audio.mp3 --base64 --output result.txt
```

**JSON output:**

```bash
coze-coding-ai asr audio.mp3 --base64 --format json
```

**Save JSON to file:**

```bash
coze-coding-ai asr audio.mp3 \
  --base64 \
  --format json \
  --output result.json
```

**Mock mode (testing):**

```bash
coze-coding-ai asr audio.mp3 --base64 --mock
```

## Key Points

### Text-to-Speech (TTS)

- **Voice Selection**: 15+ voices available for different scenarios (general, audiobook, video, role-playing)
- **Audio Formats**: Support MP3, PCM, and Ogg Opus formats
- **Sample Rates**: 8000-48000 Hz range for different quality needs
- **Speech Control**: Adjust speech rate (-50 to +100) and volume (-50 to +100)
- **SSML Support**: Use SSML for advanced speech control (prosody, breaks, emphasis)
- **Backend Only**: Never expose API keys in client-side code
- **Context Tracking**: Use `ctx` parameter for request tracing in production
- **Custom Headers**: Use `custom_headers` for mock mode or custom metadata

### Automatic Speech Recognition (ASR)

- **Input Methods**: Support URL and Base64 encoded audio
- **Audio Formats**: Support common audio formats (MP3, WAV, OGG OPUS, M4A)
- **Detailed Results**: Get timestamps and segmented utterances
- **Duration Info**: Receive audio duration in response
- **Backend Only**: Never expose API keys in client-side code
- **Context Tracking**: Use `ctx` parameter for request tracing in production
- **Custom Headers**: Use `custom_headers` for mock mode or custom metadata

### General

- **Pipeline Support**: Combine TTS and ASR for voice processing workflows
- **CLI Tools**: Use `coze-coding-ai tts` and `coze-coding-ai asr` for quick operations
- **Error Handling**: Always handle exceptions and check response status
- **User ID**: Use consistent `uid` for tracking and analytics
- **Mock Mode**: Use mock mode for testing without consuming resources