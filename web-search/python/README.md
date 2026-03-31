# Web Search Skill Python SDK

This skill guides the implementation of web search functionality using the coze-coding-dev-sdk package and CLI tool, enabling retrieval of real-time information from the web with AI-powered summaries.

## Overview

Web Search allows you to build applications that retrieve current information from the internet, including web pages, images, and AI-generated summaries, enabling information retrieval, content discovery, and research automation.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

## Quick Start

```python
from coze_coding_dev_sdk import SearchClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="search.web")

client = SearchClient(ctx=ctx)

response = client.web_search(
    query="Python programming language",
    count=5
)

if response.web_items:
    for item in response.web_items:
        print(f"Title: {item.title}")
        print(f"URL: {item.url}")
        print(f"Snippet: {item.snippet}\n")
```

**About Context (`ctx`):**

- `Context` is used for request tracking and tracing across distributed systems
- It automatically injects headers like `request_id`, `trace_id`, and `user_id` into API calls
- **Optional**: If you don't need request tracking, you can omit `ctx` parameter: `SearchClient()`
- Recommended for production environments to enable observability and debugging

## API Reference

### Client Initialization

```python
SearchClient(
    config: Optional[Config] = None,
    ctx: Optional[Context] = None,
    custom_headers: Optional[Dict[str, str]] = None
)
```

**Parameters:**

- `config`: SDK configuration (API key, base URL, timeout)
- `ctx`: Context for request tracking (request_id, trace_id, user_id)
- `custom_headers`: Custom HTTP headers (e.g., `{"x":"x"}`)

### search() Method

```python
client.search(
    query: str,
    search_type: str = "web",
    count: Optional[int] = 10,
    need_content: Optional[bool] = False,
    need_url: Optional[bool] = False,
    sites: Optional[str] = None,
    block_hosts: Optional[str] = None,
    need_summary: Optional[bool] = True,
    time_range: Optional[str] = None
) -> SearchResponse
```

**Input Parameters:**

| Parameter       | Type   | Default | Description                                                   |
| --------------- | ------ | ------- | ------------------------------------------------------------- |
| `query`         | `str`  | Required| Search query text                                             |
| `search_type`   | `str`  | `"web"` | Search type: `"web"`, `"web_summary"`, or `"image"`           |
| `count`         | `int`  | `10`    | Number of results to return                                   |
| `need_content`  | `bool` | `False` | Only return results with full content                         |
| `need_url`      | `bool` | `False` | Only return results with original URL                         |
| `sites`         | `str`  | `None`  | Comma-separated list of sites to search within                |
| `block_hosts`   | `str`  | `None`  | Comma-separated list of sites to exclude                      |
| `need_summary`  | `bool` | `True`  | Whether to include AI-generated summary                       |
| `time_range`    | `str`  | `None`  | Time range filter (e.g., "1d", "1w", "1m")                    |

### web_search() Method

Simplified method for web search with basic parameters.

```python
client.web_search(
    query: str,
    count: Optional[int] = 10,
    need_summary: Optional[bool] = True
) -> SearchResponse
```

### web_search_with_summary() Method

Web search with guaranteed AI-generated summary.

```python
client.web_search_with_summary(
    query: str,
    count: Optional[int] = 10
) -> SearchResponse
```

### image_search() Method

Search for images instead of web pages.

```python
client.image_search(
    query: str,
    count: Optional[int] = 10
) -> SearchResponse
```

**Response Object:**

```python
class SearchResponse:
    web_items: List[WebItem]
    image_items: List[ImageItem]
    summary: Optional[str]
```

**WebItem Fields:**

- `id`: Result ID
- `sort_id`: Sort order ID
- `title`: Page title
- `site_name`: Website name
- `url`: Page URL
- `snippet`: Content snippet/preview
- `summary`: AI-generated precise summary (if available)
- `content`: Full page content (if `need_content=True`)
- `publish_time`: Publication time
- `logo_url`: Site logo URL
- `rank_score`: Relevance score
- `auth_info_des`: Authority description
- `auth_info_level`: Authority level

**ImageItem Fields:**

- `id`: Result ID
- `sort_id`: Sort order ID
- `title`: Image title
- `site_name`: Source website name
- `url`: Source page URL
- `publish_time`: Publication time
- `image`: ImageInfo object with:
  - `url`: Image URL
  - `width`: Image width
  - `height`: Image height
  - `shape`: Image shape description

## Usage Examples

### Basic Web Search

```python
from coze_coding_dev_sdk import SearchClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="search.web")

client = SearchClient(ctx=ctx)

response = client.web_search(
    query="Artificial Intelligence trends 2024",
    count=10
)

for item in response.web_items:
    print(f"{item.title}")
    print(f"Source: {item.site_name}")
    print(f"URL: {item.url}")
    print(f"Snippet: {item.snippet[:100]}...")
    print(f"Authority: {item.auth_info_des}\n")
```

### Web Search with AI Summary

```python
from coze_coding_dev_sdk import SearchClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="search.web")

client = SearchClient(ctx=ctx)

response = client.web_search_with_summary(
    query="History of artificial intelligence",
    count=5
)

print("=" * 60)
print("AI Summary:")
print("=" * 60)
print(response.summary)
print("\n" + "=" * 60)
print(f"Search Results ({len(response.web_items)} items):")
print("=" * 60)

for i, item in enumerate(response.web_items, 1):
    print(f"\n{i}. {item.title}")
    print(f"   Source: {item.site_name}")
    print(f"   URL: {item.url}")
```

### Advanced Search with Filters

```python
from coze_coding_dev_sdk import SearchClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="search.web")

client = SearchClient(ctx=ctx)

response = client.search(
    query="Python tutorials",
    search_type="web",
    count=15,
    need_content=True,
    need_url=True,
    sites="python.org,github.com,stackoverflow.com",
    time_range="1m",
    need_summary=True
)

for item in response.web_items:
    print(f"Title: {item.title}")
    print(f"URL: {item.url}")
    if item.content:
        print(f"Content preview: {item.content[:200]}...")
    print()
```

### Image Search

```python
from coze_coding_dev_sdk import SearchClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="search.image")

client = SearchClient(ctx=ctx)

response = client.image_search(
    query="cute cats",
    count=20
)

print(f"Found {len(response.image_items)} images\n")

for i, item in enumerate(response.image_items, 1):
    print(f"{i}. {item.title or 'Untitled'}")
    print(f"   Source: {item.site_name}")
    print(f"   Image URL: {item.image.url}")
    print(f"   Size: {item.image.width}x{item.image.height}")
    print(f"   Shape: {item.image.shape}\n")
```

### Search with Custom Headers

```python
from coze_coding_dev_sdk import SearchClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="search.web")

custom_headers = {
    "x-custom-field": "custom-value"
}

client = SearchClient(ctx=ctx, custom_headers=custom_headers)

response = client.web_search(
    query="Machine learning basics",
    count=10
)
```

### Block Specific Sites

```python
from coze_coding_dev_sdk import SearchClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="search.web")

client = SearchClient(ctx=ctx)

response = client.search(
    query="Technology news",
    search_type="web",
    count=10,
    block_hosts="example.com,spam-site.com",
    time_range="1d"
)
```

### Search with Time Range Filter

```python
from coze_coding_dev_sdk import SearchClient
from coze_coding_utils.runtime_ctx.context import new_context

ctx = new_context(method="search.web")

client = SearchClient(ctx=ctx)

response = client.search(
    query="Latest AI breakthroughs",
    search_type="web",
    count=10,
    time_range="1w"
)

for item in response.web_items:
    print(f"{item.title}")
    print(f"Published: {item.publish_time}")
    print(f"URL: {item.url}\n")
```

## CLI Usage

The SDK includes a command-line tool `coze-coding-ai` for quick web search without writing code.

### Basic CLI Usage

```bash
coze-coding-ai search "Python programming language"
```

### CLI Options

```bash
coze-coding-ai search QUERY [OPTIONS]

Options:
  -t, --type [web|image|web_summary]  Search type (default: web)
  -c, --count INTEGER                 Number of results (default: 10)
  -s, --summary                       Include AI summary (web type only)
  --need-content                      Only return results with full content
  --need-url                          Only return results with original URL
  --sites TEXT                        Comma-separated list of sites to search
  --block-hosts TEXT                  Comma-separated list of sites to exclude
  --time-range TEXT                   Time range filter (e.g., 1d, 1w, 1m)
  -o, --output PATH                   Save results to JSON file
  -f, --format [table|json|simple]    Output format (default: table)
  --help                              Show this message and exit
```

### CLI Examples

**Basic web search:**

```bash
coze-coding-ai search "AI latest developments"
```

**Web search with AI summary:**

```bash
coze-coding-ai search "Quantum computing principles" --type web_summary
```

**Image search:**

```bash
coze-coding-ai search "cute cats" --type image --count 20
```

**Advanced filtering:**

```bash
coze-coding-ai search "Python tutorials" \
  --sites "python.org,github.com" \
  --need-content \
  --count 15
```

**Recent news search:**

```bash
coze-coding-ai search "Technology news" \
  --time-range "1d" \
  --need-url \
  --count 20
```

**Block specific sites:**

```bash
coze-coding-ai search "Programming tips" \
  --block-hosts "spam-site.com,low-quality.com"
```

**Save results to JSON:**

```bash
coze-coding-ai search "Machine learning" \
  --count 10 \
  --output results.json
```

**Different output formats:**

```bash
coze-coding-ai search "AI research" --format json

coze-coding-ai search "AI research" --format simple

coze-coding-ai search "AI research" --format table
```

**Combined options:**

```bash
coze-coding-ai search "Python best practices" \
  --type web_summary \
  --count 15 \
  --sites "python.org,realpython.com,stackoverflow.com" \
  --time-range "1m" \
  --output python_practices.json \
  --format table
```

## Key Points

- **Search Types**: Support three types - `web` (basic), `web_summary` (with AI summary), and `image` (image search)
- **Backend Only**: Never expose API keys in client-side code
- **Error Handling**: Always check if `response.web_items` or `response.image_items` exist before accessing
- **Context Tracking**: Use `ctx` parameter for request tracing in production
- **Custom Headers**: Use `custom_headers` for mock mode or custom metadata
- **Time Range**: Use format like "1d" (1 day), "1w" (1 week), "1m" (1 month) for time filtering
- **Site Filtering**: Use comma-separated domain names for `sites` and `block_hosts` parameters
- **Authority Info**: Use `auth_info_level` and `auth_info_des` to assess result credibility
- **CLI Tool**: Use `coze-coding-ai search` command for quick searches without writing code
- **Rich Output**: CLI supports multiple output formats (table, json, simple) with colored display