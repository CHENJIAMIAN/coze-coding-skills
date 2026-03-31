---
name: pptx-generation
description: Generate professional PowerPoint presentations (PPTX) from Markdown or HTML content using coze-coding-dev-sdk. Use this skill when creating presentations, slide decks, or any content that needs to be exported in PPTX format. Documents are automatically uploaded to S3 and return download URLs with 24-hour expiry.
license: MIT
---

# PPTX Generation Skill

This skill guides the implementation of PPTX generation functionality using the coze-coding-dev-sdk package, enabling creation of professional PowerPoint presentations from Markdown or HTML content.

## Overview

PPTX Generation allows you to build applications that create professional presentations from structured content. The SDK converts Markdown or HTML content into PPTX format and automatically uploads them to S3 storage, returning presigned download URLs.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Supported Languages

This skill currently supports Python SDK only. **You MUST refer to the detailed guide in the python folder.**

- **Python SDK** (>= 0.5.11): See [python/README.md](python/README.md) for full API reference, design principles, and usage examples.

## Key Features

- Generate PPTX from Markdown content (use `---` to separate slides)
- Generate PPTX from HTML content (with 70+ shape types support)
- Design principles and color palette guidelines
- Advanced operations: text replacement, slide rearrangement
- CLI tool for quick generation

## Quick Start

```python
from coze_coding_dev_sdk import DocumentGenerationClient

client = DocumentGenerationClient()

presentation = """
# Company Overview

---

## About Us

- Founded in 2020
- 500+ employees
"""

url = client.create_pptx_from_markdown(presentation, "company_overview")
print(f"Download URL: {url}")
```

## Output

All methods return presigned S3 URLs valid for 24 hours.
