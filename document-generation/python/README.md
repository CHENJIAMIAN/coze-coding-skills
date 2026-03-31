# Document Generation Skill Python SDK

This skill guides the implementation of document generation functionality using the coze-coding-dev-sdk package and CLI tool, enabling creation of professional documents in PDF, DOCX, and XLSX formats from Markdown or HTML content.

## Overview

Document Generation allows you to build applications that create professional documents from structured content. The SDK converts Markdown or HTML content into various document formats and automatically uploads them to S3 storage, returning presigned download URLs.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

**Note**: For PPTX (PowerPoint) generation, please refer to the `pptx-generation` skill.

## Prerequisites

- **Python SDK**: `coze-coding-dev-sdk >= 0.5.11`

The coze-coding-dev-sdk package is already installed. Import it as shown in the examples below.

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
- Finding 3: Cost reduced by 15%

## Conclusion

The project has met all its objectives.
"""

url = client.create_pdf_from_markdown(markdown_content, "project_report")

print(f"Download URL: {url}")
```

## API Reference

### Client Initialization

```python
DocumentGenerationClient(
    pdf_config: Optional[PDFConfig] = None,
    docx_config: Optional[DOCXConfig] = None,
    xlsx_config: Optional[XLSXConfig] = None
)
```

**Parameters:**

- `pdf_config`: PDF generation configuration (page size, margins)
- `docx_config`: DOCX generation configuration (font, margins)
- `xlsx_config`: XLSX generation configuration (header color, auto width)

### Configuration Classes

#### PDFConfig

```python
from coze_coding_dev_sdk import PDFConfig

config = PDFConfig(
    page_size="A4",       # "A4" or "LETTER"
    left_margin=72,       # Left margin in points
    right_margin=72,      # Right margin in points
    top_margin=72,        # Top margin in points
    bottom_margin=18      # Bottom margin in points
)
```

#### DOCXConfig

```python
from coze_coding_dev_sdk import DOCXConfig

config = DOCXConfig(
    font_name="Noto Sans CJK SC",  # Font name (supports CJK)
    font_size=11,                   # Font size in points
    top_margin=0.75,                # Top margin in inches
    bottom_margin=0.75,             # Bottom margin in inches
    left_margin=0.75,               # Left margin in inches
    right_margin=0.75               # Right margin in inches
)
```

#### XLSXConfig

```python
from coze_coding_dev_sdk import XLSXConfig

config = XLSXConfig(
    header_bg_color="D9E1F2",  # Header background color (hex)
    auto_width=True             # Auto-adjust column width
)
```

### Document Generation Methods

**Important**: The `title` parameter in all methods **MUST be in English**. It is used for filename generation. Avoid spaces and special characters (use underscores instead).

```python
# Good examples
title = "quarterly_report"
title = "sales_data_2025"

# Bad examples (avoid these)
title = "季度报告"        # Non-English
title = "quarterly report" # Contains space
title = "report@2025"      # Special character
```

#### PDF Generation

```python
# From Markdown
url = client.create_pdf_from_markdown(markdown_content: str, title: str) -> str

# From HTML
url = client.create_pdf_from_html(html_content: str, title: str) -> str
```

#### DOCX Generation

```python
# From Markdown
url = client.create_docx_from_markdown(markdown_content: str, title: str) -> str

# From HTML
url = client.create_docx_from_html(html_content: str, title: str) -> str
```

#### XLSX Generation

```python
# From list of dictionaries
url = client.create_xlsx_from_list(
    data: List[Dict[str, Any]],
    title: str,
    sheet_name: str = "Sheet1"
) -> str

# From 2D list
url = client.create_xlsx_from_2d_list(
    data: List[List[Any]],
    title: str,
    sheet_name: str = "Sheet1",
    has_header: bool = True
) -> str

# Auto-detect format
url = client.create_xlsx(
    data: Union[List[Dict], List[List]],
    title: str,
    sheet_name: str = "Sheet1"
) -> str
```

#### Generic Generation

```python
from coze_coding_dev_sdk import DocumentFormat

url = client.generate(
    content: str,
    title: str,
    format: DocumentFormat = DocumentFormat.PDF,
    content_type: str = "markdown"  # "markdown" or "html"
) -> str
```

**DocumentFormat Options:**

- `DocumentFormat.PDF`
- `DocumentFormat.DOCX`

**Return Value:**

All methods return a presigned S3 URL (string) that is valid for 24 hours.

## Usage Examples

### Generate PDF Report

```python
from coze_coding_dev_sdk import DocumentGenerationClient, PDFConfig

config = PDFConfig(page_size="A4")
client = DocumentGenerationClient(pdf_config=config)

report = """
# Quarterly Sales Report

## Q4 2024 Summary

### Revenue Overview

Total revenue for Q4 2024 reached $2.5M, representing a 15% increase over Q3.

### Key Metrics

| Metric | Q3 2024 | Q4 2024 | Change |
|--------|---------|---------|--------|
| Revenue | $2.17M | $2.5M | +15% |
| Customers | 1,200 | 1,450 | +21% |
| Orders | 3,500 | 4,200 | +20% |

### Regional Performance

1. **North America**: $1.2M (48%)
2. **Europe**: $800K (32%)
3. **Asia Pacific**: $500K (20%)

## Recommendations

- Expand marketing in APAC region
- Launch customer loyalty program
- Invest in product development
"""

url = client.create_pdf_from_markdown(report, "Q4_Sales_Report")
print(f"PDF Download: {url}")
```

### Generate DOCX Document

```python
from coze_coding_dev_sdk import DocumentGenerationClient, DOCXConfig

config = DOCXConfig(font_name="Noto Sans CJK SC", font_size=12)
client = DocumentGenerationClient(docx_config=config)

document = """
# 项目提案

## 项目背景

本项目旨在提升系统性能和用户体验。

## 项目目标

1. 提高系统响应速度 50%
2. 降低服务器成本 30%
3. 提升用户满意度至 95%

## 实施计划

### 第一阶段：需求分析（2周）

- 收集用户反馈
- 分析系统瓶颈
- 制定优化方案

### 第二阶段：开发实施（4周）

- 代码重构
- 数据库优化
- 缓存策略实施

### 第三阶段：测试上线（2周）

- 性能测试
- 用户验收测试
- 正式上线

## 预算估算

| 项目 | 费用 |
|------|------|
| 人力成本 | ¥200,000 |
| 服务器升级 | ¥50,000 |
| 其他费用 | ¥30,000 |
| **总计** | **¥280,000** |
"""

url = client.create_docx_from_markdown(document, "project_proposal")
print(f"DOCX Download: {url}")
```

### Generate XLSX Spreadsheet

```python
from coze_coding_dev_sdk import DocumentGenerationClient, XLSXConfig

config = XLSXConfig(header_bg_color="4472C4", auto_width=True)
client = DocumentGenerationClient(xlsx_config=config)

# From list of dictionaries
sales_data = [
    {"Product": "Widget A", "Q1": 1200, "Q2": 1500, "Q3": 1800, "Q4": 2100},
    {"Product": "Widget B", "Q1": 800, "Q2": 950, "Q3": 1100, "Q4": 1300},
    {"Product": "Widget C", "Q1": 2000, "Q2": 2200, "Q3": 2500, "Q4": 2800},
    {"Product": "Widget D", "Q1": 500, "Q2": 600, "Q3": 750, "Q4": 900},
]

url = client.create_xlsx_from_list(sales_data, "Sales_Report", "Quarterly Sales")
print(f"XLSX Download: {url}")

# From 2D list
data_2d = [
    ["Name", "Department", "Salary", "Start Date"],
    ["John Doe", "Engineering", 85000, "2022-01-15"],
    ["Jane Smith", "Marketing", 75000, "2021-06-01"],
    ["Bob Johnson", "Sales", 70000, "2023-03-20"],
]

url = client.create_xlsx_from_2d_list(data_2d, "Employee_List", "Employees")
print(f"XLSX Download: {url}")
```

### Generate HTML to PDF

```python
from coze_coding_dev_sdk import DocumentGenerationClient

client = DocumentGenerationClient()

html_content = """
<html>
<body>
    <h1 style="color: #333;">Invoice #12345</h1>
    
    <div style="margin: 20px 0;">
        <p><strong>Bill To:</strong> Acme Corporation</p>
        <p><strong>Date:</strong> January 15, 2025</p>
        <p><strong>Due Date:</strong> February 15, 2025</p>
    </div>
    
    <table style="width: 100%; border-collapse: collapse;">
        <thead>
            <tr style="background-color: #f0f0f0;">
                <th style="border: 1px solid #ddd; padding: 8px;">Item</th>
                <th style="border: 1px solid #ddd; padding: 8px;">Quantity</th>
                <th style="border: 1px solid #ddd; padding: 8px;">Price</th>
                <th style="border: 1px solid #ddd; padding: 8px;">Total</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td style="border: 1px solid #ddd; padding: 8px;">Consulting Services</td>
                <td style="border: 1px solid #ddd; padding: 8px;">10 hours</td>
                <td style="border: 1px solid #ddd; padding: 8px;">$150</td>
                <td style="border: 1px solid #ddd; padding: 8px;">$1,500</td>
            </tr>
            <tr>
                <td style="border: 1px solid #ddd; padding: 8px;">Software License</td>
                <td style="border: 1px solid #ddd; padding: 8px;">1</td>
                <td style="border: 1px solid #ddd; padding: 8px;">$500</td>
                <td style="border: 1px solid #ddd; padding: 8px;">$500</td>
            </tr>
        </tbody>
        <tfoot>
            <tr style="font-weight: bold;">
                <td colspan="3" style="border: 1px solid #ddd; padding: 8px; text-align: right;">Total:</td>
                <td style="border: 1px solid #ddd; padding: 8px;">$2,000</td>
            </tr>
        </tfoot>
    </table>
</body>
</html>
"""

url = client.create_pdf_from_html(html_content, "Invoice_12345")
print(f"Invoice PDF: {url}")
```

### Using Generic Generate Method

```python
from coze_coding_dev_sdk import DocumentGenerationClient, DocumentFormat

client = DocumentGenerationClient()

content = """
# Meeting Notes

## Date: January 15, 2025

## Attendees

- Alice (Product Manager)
- Bob (Developer)
- Charlie (Designer)

## Discussion Points

1. Q1 roadmap review
2. New feature prioritization
3. Bug fixes for v2.1

## Action Items

- [ ] Alice: Finalize requirements by Jan 20
- [ ] Bob: Complete API design by Jan 25
- [ ] Charlie: Deliver mockups by Jan 22

## Next Meeting

January 22, 2025 at 2:00 PM
"""

# Generate as PDF
pdf_url = client.generate(content, "Meeting_Notes", DocumentFormat.PDF, "markdown")
print(f"PDF: {pdf_url}")

# Generate as DOCX
docx_url = client.generate(content, "Meeting_Notes", DocumentFormat.DOCX, "markdown")
print(f"DOCX: {docx_url}")
```

## CLI Usage

The SDK includes a command-line tool `coze-dev` for quick document generation without writing code.

### Basic CLI Usage

```bash
coze-dev document pdf --content "# Hello World" --title "hello"
```

### CLI Commands

```bash
coze-dev document [COMMAND] [OPTIONS]

Commands:
  pdf      Generate PDF from Markdown or HTML
  docx     Generate DOCX from Markdown or HTML
  xlsx     Generate XLSX from JSON data
  convert  Generic format conversion
```

### PDF Command

```bash
coze-dev document pdf [OPTIONS]

Options:
  -i, --input PATH      Input file path (Markdown or HTML)
  -c, --content TEXT    Direct content input
  -t, --title TEXT      Document title (required)
  -f, --format TEXT     Content format: markdown, html (default: markdown)
  --page-size TEXT      Page size: A4, LETTER (default: A4)
```

**Examples:**

```bash
# From content
coze-dev document pdf --content "# Report\n\nThis is a report." --title "report"

# From file
coze-dev document pdf --input report.md --title "monthly_report"

# From pipe
cat report.md | coze-dev document pdf --title "piped_report"

# HTML content
coze-dev document pdf --content "<h1>Hello</h1>" --title "html_doc" --format html
```

### DOCX Command

```bash
coze-dev document docx [OPTIONS]

Options:
  -i, --input PATH      Input file path
  -c, --content TEXT    Direct content input
  -t, --title TEXT      Document title (required)
  -f, --format TEXT     Content format: markdown, html (default: markdown)
  --font TEXT           Font name (default: Noto Sans CJK SC)
  --font-size INT       Font size in points (default: 11)
```

**Examples:**

```bash
# Basic usage
coze-dev document docx --content "# Document\n\nContent here." --title "my_doc"

# With custom font
coze-dev document docx --input doc.md --title "styled_doc" --font "Arial" --font-size 12
```

### XLSX Command

```bash
coze-dev document xlsx [OPTIONS]

Options:
  -i, --input PATH      Input JSON file path
  -c, --content TEXT    Direct JSON content
  -t, --title TEXT      Document title (required)
  --sheet-name TEXT     Sheet name (default: Sheet1)
  --header-color TEXT   Header background color in hex (default: D9E1F2)
```

**Examples:**

```bash
# From JSON content (list of dicts)
coze-dev document xlsx --content '[{"Name": "John", "Age": 30}, {"Name": "Jane", "Age": 25}]' --title "users"

# From JSON file
coze-dev document xlsx --input data.json --title "sales_data" --sheet-name "Q4 Sales"

# From pipe
cat data.json | coze-dev document xlsx --title "piped_data"
```

### Convert Command

```bash
coze-dev document convert [OPTIONS]

Options:
  -i, --input PATH      Input file path (required)
  -t, --title TEXT      Document title (required)
  --from TEXT           Input format: markdown, html (default: markdown)
  --to TEXT             Output format: pdf, docx (required)
```

**Examples:**

```bash
# Markdown to PDF
coze-dev document convert --input report.md --title "report" --to pdf

# HTML to DOCX
coze-dev document convert --input page.html --title "document" --from html --to docx
```

## Markdown Formatting Guide

### Supported Markdown Elements

| Element | Syntax | PDF | DOCX |
|---------|--------|-----|------|
| Headings | `# H1` to `###### H6` | ✓ | ✓ |
| Bold | `**text**` | ✓ | ✓ |
| Italic | `*text*` | ✓ | ✓ |
| Lists | `- item` or `1. item` | ✓ | ✓ |
| Links | `[text](url)` | ✓ | ✓ |
| Images | `![alt](url)` | ✓ | ✓ |
| Tables | `\| col \|` | ✓ | ✓ |
| Code | `` `code` `` | ✓ | ✓ |
| Code Blocks | ` ```lang ``` ` | ✓ | ✓ |
| Blockquotes | `> quote` | ✓ | ✓ |
| Horizontal Rule | `---` | ✓ | ✓ |

## Key Points

- **Output Format**: All methods return presigned S3 URLs valid for 24 hours
- **Filename Generation**: Files are named `{title}_{timestamp}_{uuid}.{ext}` automatically
- **Title Parameter**: The `title` parameter **MUST be in English** (used for filename generation, no spaces or special characters recommended)
- **CJK Support**: Full support for Chinese, Japanese, Korean characters in document content
- **Backend Only**: Never expose document generation in client-side code
- **Content Types**: Support both Markdown and HTML input
- **Configuration**: Customize page size, fonts, margins, and colors
- **XLSX Data**: Support both list of dicts and 2D list formats
- **CLI Tool**: Use `coze-dev document` for quick generation without code
- **Pipe Support**: CLI commands support piping content from stdin
- **PPTX Generation**: For PowerPoint presentations, use the `pptx-generation` skill
