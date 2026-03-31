# Fetch URL Skill Python SDK

This skill guides the implementation of URL content fetching functionality using the coze-coding-dev-sdk package, enabling URL content extraction and parsing capabilities.

## Overview

Fetch URL capabilities allow you to build applications that can fetch and extract structured content from any URL, including text, images, and links.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

- **Python SDK**: `coze-coding-dev-sdk >= 0.5.11`

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

```python
from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FetchClient(ctx=ctx)

response = client.fetch(url="https://example.com/article")

print(f"Title: {response.title}")
print(f"URL: {response.url}")
for item in response.content:
    if item.type == "text":
        print(f"Text: {item.text}")
    elif item.type == "image":
        print(f"Image: {item.image.display_url}")
    elif item.type == "link":
        print(f"Link: {item.url}")
```

**About Context (`ctx`):**

- `Context` is used for request tracking and tracing across distributed systems
- It automatically injects headers like `request_id`, `trace_id`, and `user_id` into API calls
- **Optional**: If you don't need request tracking, you can omit `ctx` parameter: `FetchClient()`
- Recommended for production environments to enable observability and debugging

## API Reference

### Client Initialization

```python
FetchClient(
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

### fetch() Method

```python
client.fetch(url: str) -> FetchResponse
```

Fetch and extract content from a URL.

**Input Parameters:**

| Parameter | Type  | Default  | Description  |
| --------- | ----- | -------- | ------------ |
| `url`     | `str` | Required | URL to fetch |

**Returns:** `FetchResponse` with extracted content

**Response Structure:**

```python
{
    "fetch_id": "...",
    "status_code": 0,  # 0 means success, non-0 means error
    "status_message": "success",
    "url": "https://...",
    "doc_id": "...",
    "title": "Page Title",
    "publish_time": "2024-01-01",
    "filetype": "html",
    "content": [
        {
            "type": "text",
            "text": "Content text..."
        },
        {
            "type": "image",
            "image": {
                "image_url": "https://...",
                "display_url": "https://...",
                "width": 800,
                "height": 600,
                "thumbnail_display_url": "https://..."
            }
        },
        {
            "type": "link",
            "url": "https://..."
        }
    ],
    "display_info": {
        "no_display": false,
        "no_display_reason": null
    }
}
```

**Content Item Types:**

| Type    | Description                                      |
| ------- | ------------------------------------------------ |
| `text`  | Text content, available in `text` field          |
| `image` | Image content, details in `image` object         |
| `link`  | Hyperlink, URL available in `url` field          |

**Image Object Fields:**

| Field                   | Type  | Description                        |
| ----------------------- | ----- | ---------------------------------- |
| `image_url`             | `str` | Original image URL                 |
| `display_url`           | `str` | Re-signed publicly accessible URL  |
| `width`                 | `int` | Image width                        |
| `height`                | `int` | Image height                       |
| `thumbnail_display_url` | `str` | Compressed thumbnail URL           |

## Usage Examples

### Basic URL Fetching

```python
from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FetchClient(ctx=ctx)

response = client.fetch(url="https://example.com/article")

print(f"Title: {response.title}")
print(f"Status: {'Success' if response.status_code == 0 else 'Failed'}")
```

### Extract Text Content

```python
from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FetchClient(ctx=ctx)

response = client.fetch(url="https://example.com/blog-post")

text_content = "\n".join(
    item.text for item in response.content if item.type == "text"
)

print(f"Article content: {text_content}")
```

### Extract Images

```python
from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FetchClient(ctx=ctx)

response = client.fetch(url="https://example.com/gallery")

images = [
    {
        "url": item.image.display_url,
        "width": item.image.width,
        "height": item.image.height,
        "thumbnail": item.image.thumbnail_display_url
    }
    for item in response.content if item.type == "image"
]

print(f"Found {len(images)} images")
for i, img in enumerate(images):
    print(f"Image {i + 1}: {img['url']} ({img['width']}x{img['height']})")
```

### Extract Links

```python
from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
client = FetchClient(ctx=ctx)

response = client.fetch(url="https://example.com/resources")

links = [item.url for item in response.content if item.type == "link"]

print(f"Found {len(links)} links: {links}")
```

### With Custom Headers

```python
from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

ctx = Context()
custom_headers = {
    "x-run-mode": "test_run",
    "x-custom-field": "custom-value"
}

client = FetchClient(ctx=ctx, custom_headers=custom_headers)

response = client.fetch(url="https://example.com/article")
print(f"Title: {response.title}")
```

### With FastAPI

```python
from fastapi import FastAPI, Request
from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

app = FastAPI()

@app.post("/api/fetch")
async def fetch_url(request: Request):
    body = await request.json()
    url = body.get("url")
    
    ctx = Context()
    client = FetchClient(ctx=ctx)
    
    response = client.fetch(url=url)
    
    return {
        "title": response.title,
        "content": [
            {"type": item.type, "text": item.text, "url": item.url}
            for item in response.content
        ],
        "url": response.url
    }
```

### With Flask

```python
from flask import Flask, request, jsonify
from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

app = Flask(__name__)

@app.route("/api/fetch", methods=["POST"])
def fetch_url():
    body = request.get_json()
    url = body.get("url")
    
    ctx = Context()
    client = FetchClient(ctx=ctx)
    
    response = client.fetch(url=url)
    
    return jsonify({
        "title": response.title,
        "content": [
            {"type": item.type, "text": item.text, "url": item.url}
            for item in response.content
        ],
        "url": response.url
    })
```

## Key Points

- **Backend Only**: Never expose API keys in client-side code
- **Context Tracking**: Use `ctx` parameter for request tracing in production
- **Custom Headers**: Use `custom_headers` for mock mode or custom metadata
- **Content Types**: Handle different content types (text, image, link) appropriately
- **Error Handling**: Check `status_code` in response (0 means success)
- **Image URLs**: Use `display_url` for publicly accessible image URLs
- **Thumbnails**: Use `thumbnail_display_url` for optimized image loading
