# LLM (Large Language Model) Skill Python SDK

This skill guides the implementation of large language model functionality using the coze-coding-dev-sdk package and CLI tool, enabling creation of conversational AI applications with advanced features like streaming, thinking mode, and caching.

## Overview

LLM allows you to build applications that leverage powerful language models for text generation, conversational AI, content creation, code generation, and complex reasoning tasks. The SDK provides both streaming and non-streaming interfaces with support for multi-turn conversations and multimodal inputs.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [HumanMessage(content="What is machine learning?")]

response = client.invoke(messages=messages)

print(response.content)
```

**About Context (`ctx`):**

- `Context` is used for request tracking and tracing across distributed systems
- It automatically injects headers like `request_id`, `trace_id`, and `user_id` into API calls
- **Optional**: If you don't need request tracking, you can omit `ctx` parameter: `LLMClient()`
- Recommended for production environments to enable observability and debugging

## API Reference

### Client Initialization

```python
LLMClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `ctx`: Context for request tracking (request_id, trace_id, user_id)

### Message Types

The SDK uses LangChain message format for conversations:

```python
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

SystemMessage(content="You are a helpful assistant")
HumanMessage(content="Hello!")
AIMessage(content="Hi! How can I help you?")
```

**Message Types:**

- `SystemMessage`: System prompt that defines AI behavior and role
- `HumanMessage`: User messages/questions
- `AIMessage`: AI responses (used in multi-turn conversations)

### Message Content Types

**IMPORTANT**: The `content` parameter can be either a `str` or a `list` (for multimodal inputs).

#### String Content (Text Only)

```python
HumanMessage(content="What is machine learning?")
```

#### List Content (Multimodal)

For multimodal inputs (text + images/videos), use a list of content blocks:

```python
HumanMessage(content=[
    {"type": "text", "text": "Describe this image"},
    {"type": "image_url", "image_url": {"url": "https://example.com/image.jpg"}}
])
```

**Supported Content Block Types:**

| Type | Structure | Description |
|------|-----------|-------------|
| `text` | `{"type": "text", "text": "..."}` | Text content |
| `image_url` | `{"type": "image_url", "image_url": {"url": "..."}}` | Image from URL |
| `video_url` | `{"type": "video_url", "video_url": {"url": "..."}}` | Video from URL |

**Examples:**

```python
# Text only (string)
HumanMessage(content="Hello, how are you?")

# Text only (list format)
HumanMessage(content=[
    {"type": "text", "text": "Hello, how are you?"}
])

# Single image with text
HumanMessage(content=[
    {"type": "text", "text": "What's in this image?"},
    {"type": "image_url", "image_url": {"url": "https://example.com/photo.jpg"}}
])

# Multiple images with text
HumanMessage(content=[
    {"type": "text", "text": "Compare these two images"},
    {"type": "image_url", "image_url": {"url": "https://example.com/image1.jpg"}},
    {"type": "image_url", "image_url": {"url": "https://example.com/image2.jpg"}}
])

# Video with text
HumanMessage(content=[
    {"type": "text", "text": "Summarize this video"},
    {"type": "video_url", "video_url": {"url": "https://example.com/video.mp4"}}
])

# Mixed content (text + image + video)
HumanMessage(content=[
    {"type": "text", "text": "Analyze the relationship between this image and video"},
    {"type": "image_url", "image_url": {"url": "https://example.com/image.jpg"}},
    {"type": "video_url", "video_url": {"url": "https://example.com/video.mp4"}}
])
```

### invoke() Method

Non-streaming method that returns complete response.

```python
client.invoke(
    messages: List[BaseMessage],
    model: str = "doubao-seed-1-8-251228",
    thinking: Optional[str] = "disabled",
    caching: Optional[str] = "disabled",
    temperature: Optional[float] = 1.0,
    frequency_penalty: Optional[float] = 0,
    top_p: Optional[float] = 0,
    max_tokens: Optional[int] = None,
    max_completion_tokens: Optional[int] = 32768,
    previous_response_id: Optional[str] = None,
    extra_headers: Optional[Dict[str, str]] = None
) -> AIMessage
```

**Input Parameters:**

| Parameter                  | Type             | Default                      | Description                                          |
| -------------------------- | ---------------- | ---------------------------- | ---------------------------------------------------- |
| `messages`                 | `List[BaseMessage]` | Required                  | List of conversation messages                        |
| `model`                    | `str`            | `"doubao-seed-1-8-251228"`   | Model ID to use                                      |
| `thinking`                 | `str`            | `"disabled"`                 | Thinking mode: `"enabled"` or `"disabled"`           |
| `caching`                  | `str`            | `"disabled"`                 | Caching mode: `"enabled"` or `"disabled"`            |
| `temperature`              | `float`          | `1.0`                        | Output randomness (0-2)                              |
| `frequency_penalty`        | `float`          | `0`                          | Repetition penalty (-2 to 2)                         |
| `top_p`                    | `float`          | `0`                          | Nucleus sampling (0-1)                               |
| `max_tokens`               | `int`            | `None`                       | Maximum output tokens                                |
| `max_completion_tokens`    | `int`            | `32768`                       | Maximum completion tokens                            |
| `previous_response_id`     | `str`            | `None`                       | Previous response ID for caching                     |
| `extra_headers`            | `Dict[str, str]` | `None`                       | Custom HTTP headers                                  |

### stream() Method

Streaming method that yields response chunks in real-time.

```python
client.stream(
    messages: List[BaseMessage],
    model: str = "doubao-seed-1-8-251228",
    thinking: Optional[str] = "disabled",
    caching: Optional[str] = "disabled",
    temperature: Optional[float] = 1.0,
    frequency_penalty: Optional[float] = 0,
    top_p: Optional[float] = 0,
    max_tokens: Optional[int] = None,
    max_completion_tokens: Optional[int] = 32768,
    previous_response_id: Optional[str] = None,
    extra_headers: Optional[Dict[str, str]] = None
) -> Iterator[BaseMessageChunk]
```

**Parameters:** Same as `invoke()` method.

**Returns:** Iterator of message chunks with `content` and `response_metadata`.

### Available Models

| Model ID                          | Description                                | Best For                                            |
|-----------------------------------|--------------------------------------------|-----------------------------------------------------|
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

**Response Object:**

```python
class AIMessage:
    content: str | list[str | dict]  # Can be str, list[dict], or list[str]!
    response_metadata: dict
```

**IMPORTANT**: The `content` field of `AIMessage` can be:
- `str`: Plain text response
- `list[dict]`: Multimodal response with content blocks (e.g., `[{"type": "text", "text": "..."}]`)
- `list[str]`: List of text strings

Do NOT assume it's always a string. Never call string methods like `.strip()`, `.lower()`, etc. directly without checking the type first.

```python
# ❌ WRONG - May fail if content is a list
text = response.content.strip()

# ✅ CORRECT - Check type first
if isinstance(response.content, str):
    text = response.content.strip()
elif isinstance(response.content, list):
    if response.content and isinstance(response.content[0], str):
        # List of strings
        text = " ".join(response.content).strip()
    else:
        # List of dicts (multimodal response)
        text_parts = [item.get("text", "") for item in response.content if isinstance(item, dict) and item.get("type") == "text"]
        text = " ".join(text_parts).strip()

# ✅ CORRECT - Safe string conversion helper function
def get_text_content(content):
    if isinstance(content, str):
        return content
    elif isinstance(content, list):
        if content and isinstance(content[0], str):
            return " ".join(content)
        else:
            return " ".join(item.get("text", "") for item in content if isinstance(item, dict) and item.get("type") == "text")
    return str(content)
```

**Response Metadata Fields:**

- `id`: Response ID (for caching)
- `model`: Model used
- `usage`: Token usage information
- `finish_reason`: Completion reason

## Usage Examples

### Basic Chat (Non-Streaming)

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [HumanMessage(content="Explain quantum computing in simple terms")]

response = client.invoke(messages=messages, temperature=0.7)

print(response.content)
```

### Streaming Chat

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [HumanMessage(content="Tell me a story about AI")]

for chunk in client.stream(messages=messages, temperature=0.9):
    if chunk.content:
        print(chunk.content, end="", flush=True)
```

### Multi-Turn Conversation

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are a Python programming expert."),
    HumanMessage(content="What is a decorator?"),
]

response = client.invoke(messages=messages)
print(f"AI: {response.content}\n")

messages.append(AIMessage(content=response.content))
messages.append(HumanMessage(content="Can you show me an example?"))

response = client.invoke(messages=messages)
print(f"AI: {response.content}")
```

### Chat with System Prompt

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import SystemMessage, HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are a professional translator. Translate to French."),
    HumanMessage(content="Hello, how are you?")
]

response = client.invoke(messages=messages, temperature=0.3)
print(response.content)
```

### Thinking Mode (Deep Reasoning)

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import SystemMessage, HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are a math problem solver."),
    HumanMessage(content="If a pond's lily pads double every day and cover the pond in 48 days, how many days to cover half? Explain your reasoning.")
]

for chunk in client.stream(
    messages=messages,
    model="doubao-seed-1-8-251228",
    thinking="enabled",
    temperature=0.7
):
    if chunk.content:
        print(chunk.content, end="", flush=True)
```

### Caching for Multi-Turn Conversations

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

system_prompt = """You are a Python expert. Help users understand Python concepts.
Your answers should be:
1. Clear and concise
2. Include code examples
3. Explain key concepts
4. Provide best practices"""

messages = [
    SystemMessage(content=system_prompt),
    HumanMessage(content="What is a Python decorator?")
]

response_id = None
first_response = ""

for chunk in client.stream(messages=messages, caching="enabled", temperature=0.7):
    if chunk.content:
        print(chunk.content, end="", flush=True)
        first_response += chunk.content
    if chunk.response_metadata.get("id"):
        response_id = chunk.response_metadata.get("id")

print(f"\n\nResponse ID: {response_id}\n")

messages.append(AIMessage(content=first_response, response_metadata={"id": response_id}))
messages.append(HumanMessage(content="Show me a practical example."))

for chunk in client.stream(
    messages=messages,
    caching="enabled",
    previous_response_id=response_id,
    temperature=0.7
):
    if chunk.content:
        print(chunk.content, end="", flush=True)
```

### Multimodal Chat (Image Understanding)

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import SystemMessage, HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are a visual understanding assistant."),
    HumanMessage(content=[
        {
            "type": "text",
            "text": "Describe this image in detail."
        },
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/image.jpg"
            }
        }
    ])
]

for chunk in client.stream(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.7
):
    if chunk.content:
        print(chunk.content, end="", flush=True)
```

### Object Detection with Bounding Box Coordinates

When using the `doubao-seed-1-6-vision-250815` model for vision understanding, you can request the model to output bounding box coordinates for specific elements in the image.

**Coordinate System:**
- Uses relative coordinates with top-left corner as (0, 0)
- X-axis: horizontal direction, normalized to 1000
- Y-axis: vertical direction, normalized to 1000
- To convert to absolute coordinates: `absolute_x = x_min / 1000 * image_width`

**Output Format:**

```json
{
  "bbox": [
    {
      "topLeftX": x_min,
      "topLeftY": y_min,
      "bottomRightX": x_max,
      "bottomRightY": y_max
    },
    {
      "topLeftX": 20,
      "topLeftY": 20,
      "bottomRightX": 30,
      "bottomRightY": 30
    }
  ]
}
```

**Example:**

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import SystemMessage, HumanMessage
import json

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

bbox_prompt = """Please detect all people in this image and output their bounding box coordinates.

Output format:
{
  "bbox": [
    {
      "topLeftX": x_min,
      "topLeftY": y_min,
      "bottomRightX": x_max,
      "bottomRightY": y_max
    }
  ]
}

Note: Coordinates are relative values (0-1000), where (0,0) is top-left corner."""

messages = [
    SystemMessage(content="You are a visual object detection assistant."),
    HumanMessage(content=[
        {
            "type": "text",
            "text": bbox_prompt
        },
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/people.jpg"
            }
        }
    ])
]

response = client.invoke(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.3
)

print("Detection Result:")
print(response.content)

try:
    bbox_data = json.loads(response.content)
    
    image_width = 1920
    image_height = 1080
    
    print("\nAbsolute Coordinates:")
    for i, box in enumerate(bbox_data.get("bbox", [])):
        abs_x1 = box["topLeftX"] / 1000 * image_width
        abs_y1 = box["topLeftY"] / 1000 * image_height
        abs_x2 = box["bottomRightX"] / 1000 * image_width
        abs_y2 = box["bottomRightY"] / 1000 * image_height
        
        print(f"Object {i+1}:")
        print(f"  Top-Left: ({abs_x1:.1f}, {abs_y1:.1f})")
        print(f"  Bottom-Right: ({abs_x2:.1f}, {abs_y2:.1f})")
        print(f"  Width: {abs_x2 - abs_x1:.1f}, Height: {abs_y2 - abs_y1:.1f}")
except json.JSONDecodeError:
    print("Note: Response may contain additional text. Extract JSON part for parsing.")
```

### Video Understanding

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import SystemMessage, HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are a video content analyst."),
    HumanMessage(content=[
        {
            "type": "text",
            "text": "Analyze the main content and key information in this video."
        },
        {
            "type": "video_url",
            "video_url": {
                "url": "https://example.com/video.mp4"
            }
        }
    ])
]

for chunk in client.stream(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.7
):
    if chunk.content:
        print(chunk.content, end="", flush=True)
```

### Multiple Images Comparison

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context
from langchain_core.messages import SystemMessage, HumanMessage

ctx = Context()

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are an image analysis expert."),
    HumanMessage(content=[
        {
            "type": "text",
            "text": "Compare these two product images. What are the differences in design, color, and features?"
        },
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/product_v1.jpg"
            }
        },
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/product_v2.jpg"
            }
        }
    ])
]

response = client.invoke(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.5
)

print(response.content)
```

### Image OCR and Text Extraction

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context
from langchain_core.messages import SystemMessage, HumanMessage

ctx = Context()

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are an OCR assistant. Extract all text from images accurately."),
    HumanMessage(content=[
        {
            "type": "text",
            "text": "Please extract all the text from this document image. Maintain the original formatting as much as possible."
        },
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/document.png"
            }
        }
    ])
]

response = client.invoke(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.1
)

print(response.content)
```

### Chart and Data Analysis

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context
from langchain_core.messages import SystemMessage, HumanMessage

ctx = Context()

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are a data analyst expert at interpreting charts and graphs."),
    HumanMessage(content=[
        {
            "type": "text",
            "text": "Analyze this chart. What trends do you see? What insights can you extract from the data?"
        },
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/sales_chart.png"
            }
        }
    ])
]

response = client.invoke(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.3
)

print(response.content)
```

### Multi-Turn Conversation with Images

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

ctx = Context()

client = LLMClient(ctx=ctx)

messages = [
    SystemMessage(content="You are a helpful visual assistant."),
    HumanMessage(content=[
        {
            "type": "text",
            "text": "What do you see in this image?"
        },
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/scene.jpg"
            }
        }
    ])
]

response = client.invoke(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.7
)
print(f"AI: {response.content}\n")

messages.append(AIMessage(content=response.content))
messages.append(HumanMessage(content="How many people are in the image?"))

response = client.invoke(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.7
)
print(f"AI: {response.content}\n")

messages.append(AIMessage(content=response.content))
messages.append(HumanMessage(content="What are they wearing?"))

response = client.invoke(
    messages=messages,
    model="doubao-seed-1-6-vision-250815",
    temperature=0.7
)
print(f"AI: {response.content}")
```

### Adjusting Temperature for Different Tasks

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

print("Code Generation (temperature=0.2):")
response = client.invoke(
    messages=[HumanMessage(content="Write a Python function to sort a list")],
    temperature=0.2
)
print(response.content)

print("\n" + "="*60 + "\n")

print("Creative Writing (temperature=1.5):")
response = client.invoke(
    messages=[HumanMessage(content="Write a creative poem about AI")],
    temperature=1.5
)
print(response.content)
```

### Token Limit Control

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context, new_context
from langchain_core.messages import HumanMessage

ctx = new_context(method="invoke")

client = LLMClient(ctx=ctx)

messages = [HumanMessage(content="Explain machine learning in detail")]

response = client.invoke(
    messages=messages,
    max_completion_tokens=32768,
    temperature=0.7
)

print(response.content)
print(f"\nToken usage: {response.response_metadata.get('usage', {})}")
```

### Safe Response Content Handling

Since `AIMessage.content` can be either `str` or `list`, always handle both cases:

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context
from langchain_core.messages import HumanMessage
from typing import Union, List

ctx = Context()

client = LLMClient(ctx=ctx)

def get_text_content(content: str | list[str | dict]) -> str:
    """Safely extract text from AIMessage content."""
    if isinstance(content, str):
        return content
    elif isinstance(content, list):
        if content and isinstance(content[0], str):
            # List of strings
            return " ".join(content)
        else:
            # List of dicts (multimodal response)
            text_parts = []
            for item in content:
                if isinstance(item, dict) and item.get("type") == "text":
                    text_parts.append(item.get("text", ""))
            return " ".join(text_parts)
    else:
        return str(content)

messages = [HumanMessage(content="Hello, how are you?")]

response = client.invoke(messages=messages)

text = get_text_content(response.content)
print(f"Response: {text.strip()}")

if text:
    word_count = len(text.split())
    print(f"Word count: {word_count}")
```

### Streaming with Safe Content Handling

```python
from coze_coding_dev_sdk import LLMClient
from coze_coding_utils.runtime_ctx.context import Context
from langchain_core.messages import HumanMessage

ctx = Context()

client = LLMClient(ctx=ctx)

messages = [HumanMessage(content="Tell me a story")]

full_response = ""

for chunk in client.stream(messages=messages, temperature=0.9):
    if chunk.content:
        if isinstance(chunk.content, str):
            print(chunk.content, end="", flush=True)
            full_response += chunk.content
        elif isinstance(chunk.content, list):
            for item in chunk.content:
                if isinstance(item, dict) and item.get("type") == "text":
                    text = item.get("text", "")
                    print(text, end="", flush=True)
                    full_response += text

print(f"\n\nTotal length: {len(full_response)} characters")
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
  -p, --prompt TEXT       User message content [required]
  -s, --system TEXT       System prompt for custom behavior
  -t, --thinking          Enable chain-of-thought reasoning
  -o, --output PATH       Output file path (JSON format)
  --stream                Stream the response in real-time
  --help                  Show this message and exit
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

**Enable thinking mode:**

```bash
coze-coding-ai chat \
  --prompt "Solve this logic puzzle: If all roses are flowers..." \
  --thinking
```

**Save response to file:**

```bash
coze-coding-ai chat \
  --prompt "Explain machine learning" \
  --output response.json
```

**Combined options:**

```bash
coze-coding-ai chat \
  --prompt "Write a Python decorator example" \
  --system "You are a Python expert" \
  --stream \
  --output result.json
```

## Key Points

- **Message Format**: Use LangChain message types (`SystemMessage`, `HumanMessage`, `AIMessage`)
- **Content Types**: `content` can be `str` (text only) or `list` (multimodal with text/image/video blocks)
- **Response Content**: `AIMessage.content` can be `str`, `list[dict]`, or `list[str]` - never call `.strip()` directly without type checking
- **Backend Only**: Never expose API keys in client-side code
- **Streaming vs Non-Streaming**: Use `stream()` for real-time output, `invoke()` for complete response
- **Context Tracking**: Use `ctx` parameter for request tracing in production
- **Temperature Control**: Adjust based on task (low for factual, high for creative)
- **Thinking Mode**: Enable for complex reasoning tasks (math, logic, analysis)
- **Caching**: Use for multi-turn conversations to improve performance and reduce costs
- **Multimodal**: Support image and video understanding with vision models
- **Object Detection**: Vision model supports bounding box output with relative coordinates (0-1000 scale)
- **Coordinate Conversion**: Convert relative to absolute: `absolute_x = x_min / 1000 * image_width`
- **Token Limits**: Use `max_completion_tokens` to control output length and costs, default is 32768
- **Response ID**: Save `response_metadata['id']` for caching in follow-up requests
- **Model Selection**: 8 models available - choose based on task requirements (speed, reasoning, vision, context length)
- **CLI Tool**: Use `coze-coding-ai chat` command for quick interactions without code
