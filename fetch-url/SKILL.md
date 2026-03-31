---
name: fetch-url
description: Implement URL content fetching and extraction using coze-coding-dev-sdk. Use when building applications that need to fetch and parse web content, extract text, images, and links from URLs, or perform document parsing tasks. Supports various document formats including PDF, Office documents (doc/docx/ppt/pptx/xls/xlsx/csv), text files (txt/text), e-books (epub/mobi), XML, and images. Enables automatic content parsing and structured data extraction.
license: MIT
---

# Fetch URL Skill

This skill guides the implementation of URL content fetching functionality using the coze-coding-dev-sdk package, enabling URL content extraction and parsing capabilities.

## Overview

Fetch URL capabilities allow you to build applications that can fetch and extract structured content from any URL, including text, images, and links. It also supports parsing various document formats.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Supported Document Formats

This skill can parse various document types through URL:

- **PDF**: PDF documents
- **Office Documents**: doc/docx/ppt/pptx/xls/xlsx/csv
- **Text Files**: txt/text
- **E-books**: epub/mobi
- **XML**: XML documents
- **Images**: Various image formats

## Supported Languages

This skill supports both Python and TypeScript SDKs. Choose the appropriate version for your project. **You MUST refer to the detailed guide in the corresponding SDK folder.**

- **Python SDK** (>= 0.5.11): See [python/README.md](python/README.md) for installation, client initialization, and usage examples.
- **TypeScript SDK** (>= 0.7.17): See [typescript/README.md](typescript/README.md) for installation, client initialization, and usage examples.

## Key Features

- Fetch and extract content from any URL
- Parse various document formats (PDF, Office, E-books, etc.)
- Support for various content types (text, images, links)
- Automatic content parsing and structuring
- Display information and accessibility status
- Re-signed URLs for secure image access
