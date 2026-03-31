---
name: document-generation
description: Generate professional documents (PDF, DOCX, XLSX) from Markdown or HTML content using coze-coding-dev-sdk. Use this skill when creating reports, invoices, spreadsheets, or any content that needs to be exported in document formats. Documents are automatically uploaded to S3 and return download URLs with 24-hour expiry.
license: MIT
---

# Document Generation Skill

This skill guides the implementation of document generation functionality using the coze-coding-dev-sdk package, enabling creation of professional documents in PDF, DOCX, and XLSX formats from Markdown or HTML content.

## Overview

Document Generation allows you to build applications that create professional documents from structured content. The SDK converts Markdown or HTML content into various document formats and automatically uploads them to S3 storage, returning presigned download URLs.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

**Note**: For PPTX (PowerPoint) generation, please refer to the `pptx-generation` skill.

## Supported Languages

This skill currently supports Python SDK only. **You MUST refer to the detailed guide in the python folder.**

- **Python SDK** (>= 0.5.11): See [python/README.md](python/README.md) for full API reference, configuration options, and usage examples.

## Key Features

- Generate PDF from Markdown or HTML
- Generate DOCX from Markdown or HTML
- Generate XLSX from list data (dict or 2D list)
- Customizable page size, fonts, and margins
- Full CJK (Chinese, Japanese, Korean) character support
- CLI tool for quick generation

## Quick Start

```python
from coze_coding_dev_sdk import DocumentGenerationClient

client = DocumentGenerationClient()

markdown_content = """
# Project Report

## Executive Summary

This report provides an overview of the project progress.

## Key Findings

- Finding 1: Performance improved by 25%
- Finding 2: User satisfaction increased
"""

url = client.create_pdf_from_markdown(markdown_content, "project_report")
print(f"Download URL: {url}")
```

## Supported Formats

| Format | Input Types | Configuration |
|--------|-------------|---------------|
| PDF | Markdown, HTML | Page size, margins |
| DOCX | Markdown, HTML | Font, margins |
| XLSX | List of dicts, 2D list | Header color, auto width |

## Output

All methods return presigned S3 URLs valid for 24 hours.
