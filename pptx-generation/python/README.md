# PPTX Generation Skill Python SDK

Generate professional PowerPoint presentations from Markdown or HTML content using coze-coding-dev-sdk.

**IMPORTANT**: coze-coding-dev-sdk MUST be used in backend code only. Never use it in client-side code.

## Prerequisites

- **Python SDK**: `coze-coding-dev-sdk >= 0.5.11`

## Table of Contents

1. [Design Principles (CRITICAL)](#1-design-principles-critical) - **Read First!**
2. [Quick Start](#2-quick-start)
3. [API Reference](#3-api-reference)
4. [HTML to PPTX Guide](#4-html-to-pptx-guide) - Includes **Shape Types** and **Advanced Example**
5. [Prompt Engineering](#5-prompt-engineering-for-llm)
6. [Advanced Operations](#6-advanced-operations)
7. [CLI Commands](#7-cli-commands)
8. [Appendix: Complete Shape Reference](#appendix-complete-shape-reference)

---

## 1. Design Principles (CRITICAL)

**⚠️ MANDATORY**: Before creating ANY presentation, you MUST follow these design principles.

### 1.1 Design Workflow

```
Step 1: Analyze Content → Step 2: State Design Approach → Step 3: Generate Code
```

**You MUST explain your design choices BEFORE writing any code:**

```
Design Approach:
- Topic: [What is this presentation about?]
- Audience: [Who will view this?]
- Tone: [Professional/Creative/Educational/etc.]
- Color Palette: [Selected colors and why]
- Layout Style: [Full-width, two-column, etc.]
```

### 1.2 Design Checklist

| ✅ MUST DO | ❌ MUST NOT DO |
|-----------|---------------|
| State design approach BEFORE coding | Use random/default colors |
| Use web-safe fonts only | Mix too many fonts or colors |
| Create clear visual hierarchy | Create cluttered slides |
| Ensure strong contrast for readability | Skip the design explanation |
| Be consistent across slides | Ignore subject matter |

**Web-safe fonts**: Arial, Helvetica, Times New Roman, Georgia, Courier New, Verdana, Tahoma, Trebuchet MS, Impact

### 1.3 Color Palettes

Choose a palette that matches your content theme:

| Palette | Colors | Best For |
|---------|--------|----------|
| Classic Blue | `#1C2833` `#2E4053` `#AAB7B8` `#F4F6F6` | Corporate, Tech |
| Teal & Coral | `#5EA8A7` `#277884` `#FE4447` `#FFFFFF` | Modern, Startup |
| Bold Red | `#C0392B` `#E74C3C` `#F39C12` `#F1C40F` | Sales, Marketing |
| Warm Blush | `#A49393` `#EED6D3` `#E8B4B8` `#FAF7F2` | Fashion, Lifestyle |
| Black & Gold | `#BF9A4A` `#000000` `#F4F6F6` | Luxury, Finance |
| Forest Green | `#191A19` `#4E9F3D` `#1E5128` `#FFFFFF` | Environment, Health |
| Vibrant Orange | `#F96D00` `#F2F2F2` `#222831` | Youth, Sports |
| Deep Purple | `#B165FB` `#181B24` `#40695B` `#FFFFFF` | Gaming, Entertainment |

### 1.4 Layout Guidelines

| Content Type | Recommended Layout |
|-------------|-------------------|
| Single topic | Single-column, full-width |
| 2 items to compare | Two-column layout |
| 3 distinct concepts | Three-column layout |
| Image + description | Image on left, text on right |
| Data/charts | Full-slide or two-column with explanation |

**⚠️ Never use layouts with more placeholders than you have content.**

---

## 2. Quick Start

### From Markdown

```python
from coze_coding_dev_sdk import DocumentGenerationClient

client = DocumentGenerationClient()

presentation = """
# Company Overview

---

## About Us

- Founded in 2020
- 500+ employees

---

## Contact Us

- Website: www.example.com
"""

url = client.create_pptx_from_markdown(presentation, "company_overview")
print(f"Download URL: {url}")
```

### From HTML

```python
html_slides = [
    '<html><body style="background-color: #1C2833;"><h1 style="color: #FFFFFF;">Title</h1></body></html>',
    '<html><body><h2>Content</h2><ul><li>Point 1</li></ul></body></html>',
]
url = client.create_pptx_from_html(html_slides, "presentation")
```

**Key Points:**
- Use `---` to separate slides in Markdown
- Pass a list of HTML strings for multi-slide presentations
- The `title` parameter **MUST be in English** (used for filename)
- Returns a presigned S3 URL valid for 24 hours

---

## 3. API Reference

### Client Initialization

```python
from coze_coding_dev_sdk import DocumentGenerationClient, PPTXConfig

config = PPTXConfig(slide_width=10.0, slide_height=7.5)  # Optional
client = DocumentGenerationClient(pptx_config=config)
```

### Generation Methods

| Method | Input | Description |
|--------|-------|-------------|
| `create_pptx_from_markdown(content, title)` | Markdown string | Use `---` to separate slides |
| `create_pptx_from_html(content, title)` | HTML string or list | One HTML per slide |
| `create_pptx_from_html_file(path, title)` | File path or list | Load HTML from files |

**Title Requirements:**
```python
# ✅ Good
title = "quarterly_report"
title = "sales_data_2025"

# ❌ Bad
title = "季度报告"         # Non-English
title = "quarterly report"  # Contains space
```

### Markdown Elements Support

| Element | Syntax | Support |
|---------|--------|---------|
| Headings | `# H1` to `###### H6` | ✅ |
| Bold/Italic | `**bold**` `*italic*` | ✅ |
| Lists | `- item` or `1. item` | ✅ |
| Images | `![alt](url)` | ✅ |
| Tables | `\| col \|` | ✅ |
| Slide Break | `---` | ✅ |

---

## 4. HTML to PPTX Guide

### 4.1 Supported Elements

| Element | Support | Notes |
|---------|---------|-------|
| `<h1>` - `<h6>` | ✅ | Default sizes: h1=44pt, h2=36pt, etc. |
| `<p>` | ✅ | Default 18pt |
| `<ul>`, `<ol>` | ✅ | Direct `<li>` children only |
| `<img>` | ✅ | HTTP/HTTPS URLs or local paths |
| `<div>` | ✅ | Container for nested elements; renders as shape if has `background-color` or `border`. Use `data-shape` attribute for different shapes. |
| `<strong>`, `<b>` | ✅ | Renders as bold text |
| `<em>`, `<i>` | ✅ | Renders as italic text |
| `<table>`, `<span>`, `<a>` | ❌ | Not supported |

**Nested Elements**: Elements inside `<div>` inherit the parent's position. Child elements without `left`/`top` will be placed at the parent's position.

### 4.2 Shape Types (data-shape attribute)

Use the `data-shape` attribute on `<div>` elements to create different shapes:

```html
<div data-shape="oval" style="left: 50px; top: 100px; width: 80px; height: 80px; background-color: #E74C3C;"></div>
```

**Supported Shapes:**

| Category | Shape Names |
|----------|-------------|
| **Basic** | `rectangle` (default), `oval`/`circle`/`ellipse`, `rounded_rect`/`rounded_rectangle`, `diamond`, `triangle`, `right_triangle` |
| **Polygons** | `pentagon`, `hexagon`, `heptagon`, `octagon`, `decagon`, `dodecagon`, `parallelogram`, `trapezoid` |
| **Stars** | `star`/`star_5`, `star_4`, `star_6`, `star_8`, `star_16`, `star_24`, `star_32` |
| **Arrows** | `arrow`/`arrow_right`, `arrow_left`, `arrow_up`, `arrow_down`, `arrow_left_right`, `arrow_up_down`, `chevron` |
| **Special** | `heart`, `cloud`, `lightning_bolt`, `sun`, `moon`, `smiley_face`, `no_symbol` |
| **3D** | `cube`, `cylinder`/`can`, `donut`, `bevel`, `block_arc` |
| **Flowchart** | `flowchart_process`, `flowchart_decision`, `flowchart_data`, `flowchart_terminator` |
| **Callouts** | `callout`/`callout_rect`, `callout_rounded`, `callout_oval`, `callout_cloud`, `line_callout` |
| **Effects** | `explosion`/`explosion1`, `explosion2`, `frame`, `plaque`, `cross`/`plus`, `arc` |

**Example - Multiple Shapes:**
```html
<div data-shape="star_5" style="left: 50px; top: 100px; width: 80px; height: 80px; background-color: #FFD700;"></div>
<div data-shape="heart" style="left: 150px; top: 100px; width: 80px; height: 80px; background-color: #FF69B4;"></div>
<div data-shape="arrow_right" style="left: 250px; top: 100px; width: 100px; height: 60px; background-color: #3498DB;"></div>
```

### 4.3 Supported CSS Styles

**CSS Sources** (in order of precedence):
1. Inline `style` attribute (highest priority)
2. Class selectors (`.classname`)
3. ID selectors (`#elementid`)
4. Tag selectors (`h1`, `p`, etc.)

| Property | Support | Property | Support |
|----------|---------|----------|---------|
| `left`, `top` | ✅ | `font-family` | ❌ |
| `right`, `bottom` | ✅ | `margin`, `padding` | ❌ |
| `width`, `height` | ✅ | `border-radius` | ❌ |
| `font-size` | ✅ | `box-shadow` | ❌ |
| `color` | ✅ | `opacity` | ❌ |
| `text-align` | ✅ | `background-image` | ❌ |
| `font-weight: bold` | ✅ | `gradient` | ❌ |
| `background-color` | ✅ | `position` | ⚠️ Ignored |

**Note**: `position: absolute` is not required. Only `left`, `top`, `width`, `height` are needed.

**Example with `<style>` tag:**
```html
<html>
<head>
    <style>
        body { background-color: #1a1a2e; }
        .title { left: 50px; top: 50px; width: 800px; height: 80px; color: #e94560; font-size: 48px; }
        .card { width: 200px; height: 150px; background-color: #16213e; }
        #card1 { left: 50px; top: 250px; }
    </style>
</head>
<body>
    <h1 class="title">Title with CSS Class</h1>
    <div class="card" id="card1" data-shape="rounded_rect"></div>
</body>
</html>
```

### 4.4 Positioning (IMPORTANT)

**⚠️ For precise layouts, ALL elements MUST have: `left`, `top`, `width`, `height`**

```html
<!-- ✅ Absolute positioning (RECOMMENDED) -->
<h1 style="left: 50px; top: 30px; width: 800px; height: 60px; font-size: 36px;">
  Title
</h1>

<!-- ⚠️ Flow layout (less control) -->
<h1>Title</h1>
<p>Content flows below</p>
```

### 4.5 Slide Templates

**Title Slide:**
```html
<html>
<body style="background-color: #1C2833;">
  <h1 style="left: 50px; top: 200px; width: 860px; height: 80px; color: #FFFFFF; font-size: 48px; text-align: center;">
    Presentation Title
  </h1>
  <p style="left: 50px; top: 300px; width: 860px; height: 40px; color: #AAB7B8; font-size: 24px; text-align: center;">
    Subtitle
  </p>
</body>
</html>
```

**Content Slide:**
```html
<html>
<body style="background-color: #F4F6F6;">
  <div style="left: 0; top: 0; width: 960px; height: 60px; background-color: #2E4053;"></div>
  <h2 style="left: 30px; top: 10px; width: 900px; height: 40px; color: #FFFFFF; font-size: 28px;">
    Section Title
  </h2>
  <ul style="left: 50px; top: 100px; width: 860px; height: 400px; color: #1C2833; font-size: 20px;">
    <li>Point 1</li>
    <li>Point 2</li>
  </ul>
</body>
</html>
```

### 4.6 Advanced Example: AI Agent Slide with Shapes

This example demonstrates how to create a professional slide using shapes, arrows, and proper layout:

```html
<!DOCTYPE html>
<html>
<body style="background-color: #181B24;">
    <!-- Title -->
    <h1 style="left: 48px; top: 35px; width: 864px; height: 40px; color: #FFFFFF; font-size: 32px;">
        什么是 AI Agent？
    </h1>
    
    <!-- Description -->
    <p style="left: 48px; top: 85px; width: 864px; height: 50px; color: #E5E5E5; font-size: 16px;">
        可以围绕业务目标，持续执行"感知-规划-行动"闭环，并利用工具、记忆与反馈完成任务的智能体，而不仅是一次性对话机器人。
    </p>
    
    <!-- Step 1: Perceive -->
    <div data-shape="oval" style="left: 80px; top: 170px; width: 60px; height: 60px; background-color: #B165FB;"></div>
    <h2 style="left: 160px; top: 170px; width: 300px; height: 30px; color: #FFFFFF; font-size: 22px;">
        感知 Perceive
    </h2>
    <p style="left: 160px; top: 205px; width: 700px; height: 25px; color: #CCCCCC; font-size: 14px;">
        理解指令、上下文与环境状态
    </p>
    
    <!-- Arrow 1 -->
    <div data-shape="arrow_down" style="left: 95px; top: 245px; width: 30px; height: 40px; background-color: #B165FB;"></div>
    
    <!-- Step 2: Plan -->
    <div data-shape="oval" style="left: 80px; top: 300px; width: 60px; height: 60px; background-color: #B165FB;"></div>
    <h2 style="left: 160px; top: 300px; width: 300px; height: 30px; color: #FFFFFF; font-size: 22px;">
        规划 Plan
    </h2>
    <p style="left: 160px; top: 335px; width: 700px; height: 25px; color: #CCCCCC; font-size: 14px;">
        拆解任务并选择工具与路径
    </p>
    
    <!-- Arrow 2 -->
    <div data-shape="arrow_down" style="left: 95px; top: 375px; width: 30px; height: 40px; background-color: #B165FB;"></div>
    
    <!-- Step 3: Act -->
    <div data-shape="oval" style="left: 80px; top: 430px; width: 60px; height: 60px; background-color: #B165FB;"></div>
    <h2 style="left: 160px; top: 430px; width: 300px; height: 30px; color: #FFFFFF; font-size: 22px;">
        行动 Act
    </h2>
    <p style="left: 160px; top: 465px; width: 700px; height: 25px; color: #CCCCCC; font-size: 14px;">
        调用接口执行并返回可验证结果
    </p>
    
    <!-- Decorative elements -->
    <div data-shape="star_5" style="left: 800px; top: 180px; width: 50px; height: 50px; background-color: #40695B;"></div>
    <div data-shape="star_4" style="left: 750px; top: 350px; width: 40px; height: 40px; background-color: #B165FB;"></div>
    <div data-shape="hexagon" style="left: 820px; top: 420px; width: 45px; height: 45px; background-color: #40695B;"></div>
</body>
</html>
```

**Key Design Patterns Used:**
- **Deep Purple palette**: `#181B24` (background), `#B165FB` (primary), `#40695B` (accent)
- **Vertical flow layout**: Steps connected with `arrow_down` shapes
- **Icon circles**: `oval` shapes as step indicators
- **Decorative elements**: `star_5`, `star_4`, `hexagon` for visual interest
- **Text hierarchy**: `h1` for title, `h2` for step names, `p` for descriptions

### 4.7 Best Practices

1. **Use CSS classes or inline styles** - Both `<style>` tags and inline `style` attributes are supported
2. **Use absolute positioning** - Specify all four properties
3. **Use hex colors** - `#RRGGBB` format is most reliable
4. **Use pixel values** - e.g., `left: 100px`
5. **Test single slides first** - Verify layout before multi-slide
6. **Use shapes for visual elements** - `data-shape` attribute for icons and connectors
7. **Maintain consistent spacing** - Align elements vertically/horizontally

---

## 5. Prompt Engineering for LLM

When using LLM to generate PPTX HTML content, include the following design requirements in your prompt.

### 5.1 Design Requirements (Include in Prompt)

```
## Design Requirements

### Design Workflow
Before generating HTML, you MUST:
1. Analyze the topic and choose an appropriate color palette
2. State your design approach (palette, reason, layout)
3. Then generate HTML code

### HTML Format Requirements

**Supported Elements**:
- `<h1>` - `<h6>`: Headings (h1=44pt, h2=36pt, h3=28pt, h4=24pt)
- `<p>`: Paragraph text (default 18pt)
- `<ul>`, `<ol>`: Lists (only direct `<li>` children)
- `<img>`: Images (requires src, supports HTTP/HTTPS URLs)
- `<div>`: Container or shape element (see Shape Types below)
- `<strong>`, `<b>`: Bold text
- `<em>`, `<i>`: Italic text

**Shape Types** (use `data-shape` attribute on `<div>`):
- Basic: `rectangle`, `oval`/`circle`, `rounded_rect`, `diamond`, `triangle`
- Polygons: `pentagon`, `hexagon`, `octagon`
- Stars: `star_4`, `star_5`, `star_6`, `star_8`
- Arrows: `arrow_right`, `arrow_left`, `arrow_up`, `arrow_down`, `chevron`
- Special: `heart`, `cloud`, `lightning_bolt`, `sun`, `moon`
- Flowchart: `flowchart_process`, `flowchart_decision`, `flowchart_data`

**Unsupported Elements**:
- `<table>`, `<span>`, `<a>`, `<code>`

**Nested Elements**: Elements inside `<div>` inherit the parent's position.

### CSS Style Requirements

**Supported**:
- Position: `left`, `top`, `right`, `bottom`, `width`, `height` (must use pixel values)
- Font: `font-size` (px or pt), `font-weight: bold`, `font-style: italic`
- Color: `color`, `background-color` (use hex format #RRGGBB)
- Align: `text-align` (left, center, right)
- Border: `border-width`, `border-color` (div only)

**Unsupported**:
- `font-family`, `margin`, `padding`, `border-radius`, `box-shadow`, `opacity`, `background-image`, `gradient`, `position`

**Note**: `position: absolute` is not required. Only position properties (`left`, `top`, etc.) are needed.

### Positioning Rules (CRITICAL)

⚠️ **Every element MUST specify all four position properties**: `left`, `top`, `width`, `height`

### Slide Dimensions
- Standard: 960px × 720px (4:3) or 960px × 540px (16:9)
- All element positions and sizes should be within this range

### Color Palettes

| Palette | Colors | Best For |
|---------|--------|----------|
| Classic Blue | `#1C2833` `#2E4053` `#AAB7B8` `#F4F6F6` | Corporate, Tech |
| Black & Gold | `#BF9A4A` `#000000` `#F4F6F6` | Luxury, Finance |
| Forest Green | `#191A19` `#4E9F3D` `#1E5128` `#FFFFFF` | Environment, Health |
| Vibrant Orange | `#F96D00` `#F2F2F2` `#222831` | Youth, Sports |
| Deep Purple | `#B165FB` `#181B24` `#40695B` `#FFFFFF` | Creative, Entertainment |
```

### 5.2 Prompt Template

```
Create a [N]-slide presentation about "[TOPIC]".

Audience: [Target audience]
Tone: [Professional/Creative/Educational]

Slides:
1. Title slide
2. [Content description]
...

Output Format:
1. First, state your design analysis (topic, tone, palette, reason)
2. Then generate HTML with inline CSS, using absolute positioning (left, top, width, height) for all elements
```

### 5.3 Good vs Bad Prompts

**✅ Good Prompt:**
```
Create a 5-slide presentation about "AI in Healthcare" for a medical conference.

Audience: Healthcare professionals
Tone: Professional, scientific

Design: Choose colors that reflect healthcare themes.

Slides:
1. Title slide
2. Introduction to AI applications
3. Key benefits (bullet points)
4. Challenges
5. Conclusion

Output: HTML with inline CSS and absolute positioning.
```

**❌ Bad Prompt:**
```
Make a presentation about AI in healthcare.
```

### 5.4 Expected LLM Response Pattern

```
**Design Analysis**:
- Topic: AI in Healthcare
- Tone: Professional, trustworthy
- Palette: Classic Blue (#1C2833, #2E4053, #AAB7B8, #F4F6F6)
- Reason: Blue conveys trust, commonly associated with healthcare

**Generated HTML**:
[HTML code for each slide]
```

---

## 6. Advanced Operations

### Extract Text Inventory

```python
inventory = client.get_pptx_inventory("template.pptx")
```

Returns JSON with slide/shape structure, positions, and formatting.

### Replace Text

```python
replacements = {
    "slide-0": {
        "shape-0": {
            "paragraphs": [{"text": "New Title", "bold": True}]
        }
    }
}
url = client.replace_pptx_text("template.pptx", replacements, "output", validate_overflow=True)
```

### Rearrange Slides

```python
url = client.rearrange_pptx_slides("template.pptx", "output", [0, 2, 1, 3, 2])
```

- Indices are 0-based
- Same index can appear multiple times (duplicates slide)
- Omitted indices are deleted

---

## 7. CLI Commands

```bash
# Create from Markdown
coze-dev document pptx --input slides.md --title "presentation"

# Create from HTML files
coze-dev document pptx --input slide1.html --input slide2.html --title "deck" --format html

# Extract inventory
coze-dev document pptx inventory --input template.pptx

# Replace text
coze-dev document pptx replace --input template.pptx --replacements data.json --title "output"

# Rearrange slides
coze-dev document pptx rearrange --input template.pptx --title "output" --sequence "0,2,1,3"
```

---

## Summary

| Feature | Support |
|---------|---------|
| Markdown to PPTX | ✅ |
| HTML to PPTX | ✅ |
| Multi-slide | ✅ |
| Images (HTTP/local) | ✅ |
| Background colors | ✅ |
| Text styling | ✅ |
| Shapes (70+ types) | ✅ |
| Tables | ❌ |
| Animations | ❌ |
| Gradients | ❌ |

**Output**: All methods return presigned S3 URLs valid for 24 hours.

---

## Appendix: Complete Shape Reference

| Category | Shapes |
|----------|--------|
| **Basic** | `rectangle`, `oval`/`circle`/`ellipse`, `rounded_rect`/`rounded_rectangle`, `diamond`, `triangle`, `right_triangle` |
| **Polygons** | `pentagon`, `hexagon`, `heptagon`, `octagon`, `decagon`, `dodecagon`, `parallelogram`, `trapezoid` |
| **Stars** | `star`/`star_5`, `star_4`, `star_6`, `star_8`, `star_16`, `star_24`, `star_32` |
| **Arrows** | `arrow`/`arrow_right`, `arrow_left`, `arrow_up`, `arrow_down`, `arrow_left_right`, `arrow_up_down`, `chevron` |
| **Special** | `heart`, `cloud`, `lightning_bolt`, `sun`, `moon`, `smiley_face`, `no_symbol` |
| **3D** | `cube`, `cylinder`/`can`, `donut`, `bevel`, `block_arc` |
| **Flowchart** | `flowchart_process`, `flowchart_decision`, `flowchart_data`, `flowchart_terminator` |
| **Callouts** | `callout`/`callout_rect`, `callout_rounded`, `callout_oval`, `callout_cloud`, `line_callout` |
| **Effects** | `explosion`/`explosion1`, `explosion2`, `frame`, `plaque`, `cross`/`plus`, `arc` |
