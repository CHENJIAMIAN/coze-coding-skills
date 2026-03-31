---
name: shadcn-web-base-theme
description: MANDATORY This skill configures the essential shadcn/ui theme. Executed immediately after seeing "Project created successfully!" in the logs which is run by `coze init`. You cannot proceed with UI development without running this first.
---

# Shadcn 基础主题包

## 核心规则（CRITICAL RULES）

### **🚫 禁止硬编码颜色**

- 严禁使用 Hex/RGB 值（`#000000`）或 Tailwind 原生色盘（`bg-orange-500`）。
- **禁止使用蓝紫色的 AI 味渐变色**，尤其是 purple、indigo，**非必须情况请不要使用渐变色**
- **颜色和字体必须使用 `globals.css` 中的主题变量**
- **必须使用 Tailwind 的语义化变量**（`bg-background`, `text-foreground`）。如需调整色调强弱，请使用透明度修饰符（如 `bg-primary/10`, `text-primary/80`）。图表（Chart）场景使用 `--chart-1` ~ `--chart-5` 相关变量。

### 颜色使用正反例

**❌ 反例：硬编码或使用非语义化 Tailwind 颜色**

```tsx
// ❌ 错误：使用 Hex 值或 Tailwind 原生调色板（无法自动适配主题与暗色模式）
<div className="bg-[#0f172a] border-slate-200">
  {/* ❌ 错误：严禁使用 text-purple-50, 这会破坏主题一致性 */}
  <h2 className="text-purple-50">Slop</h2>
  {/* ❌ 错误：严禁使用 bg-orange-500, 这会破坏主题一致性 */}
  <span className="bg-orange-500 text-white">Status</span>
</div>
```

**❌ 反例：使用 AI 味的渐变色**

```tsx
// ❌ 错误：使用 AI 味的渐变色（无法自动适配主题与暗色模式）
<div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-8 rounded-xl">
  <h2>AI Slop</h2>
</div>
```

**✅ 正例：使用映射到 global.css 的语义化变量**

```tsx
// ✅ 正确：使用 bg-card (对应 var(--card)), text-muted-foreground (对应 var(--muted-foreground))
<div className="bg-card text-card-foreground border-border">
  <h2 className="text-muted-foreground">Good</h2>
</div>

// ✅ 正确：使用 muted/primary 的极低透明度，保持页面干净
<div className="bg-gradient-to-b from-muted/50 to-background">
  Clean
</div>
```

### **🚫 禁止硬编码圆角**

严禁写死像素值（如 `rounded-[8px]`）。**必须**使用 `rounded-md`, `rounded-lg` 等基于 `--radius` 的类。

## 增加 Shadcn 主题配置流程（MANDATORY）

在 `write_todos` 进行计划时，必须 **在 Nextjs 初始化（coze init 调用成功）时，必须设置 Shadcn 主题**。
❌`[]初始化 Next.js 项目 []编写前端页面`
✅`[]初始化 Next.js 项目 []配置 Shadcn 全局主题 []编写前端页面 `

## 核心主题配置工作流 (CRITICAL WORKFLOW)

### 运行主题脚本

```bash
# 配置主题 (可选 --default-dark 开启默认暗黑模式)
bash /path/to/shadcn-web-base-theme/scripts/theme.sh --colors <color> --fonts <font> --radius <radius> --shadow <shadow> [--default-dark]
```

参数：

- `--colors <color>`: `vintage-grey`, `retro-brown`, `artistic-green`, `emerald`, `green`, `lime`, `teal`, `cyan`, `sky`, `blue`, `indigo`, `violet`, `purple`, `fuchsia`, `low-pink`, `rose`, `red`, `neutral`, `orange`, `amber`, `yellow`, `bento-blue`, `supbase-green`, `tech-purple`
- `--fonts <font>`: `business`, `classic`, `playful`
- `--radius <radius>`: `none`, `2xs`, `xs`, `sm`, `md`, `lg`, `xl`, `2xl`
- `--shadow <shadow>`: `tool`, `artistic`, `bento`, `cool`, `retro`, `superbase`, `tech`, `vintage`
- `--default-dark`: 开启暗黑模式（可选）

详见：

- [colors](references/colors.md)
- [fonts](references/fonts.md)
- [radius](references/radius.md)
- [shadows](references/shadows.md)

#### 注意事项

- 具有 AI 属性的产品，配置主题时应剥离 AI 属性分析（如 AI 儿童绘本 → 为"儿童绘本"配置主题）
- **非必要少选择**：`blue`, `neutral` **出现频率较高，容易同质化**。`purple`, `violet`, `fuchsia`, `indigo` **AI 味较浓**。
- 当用户**提出了特殊的风格要求**，或者提供了**配色样式的特殊要求**，可以**在脚本运行结束后再进一步自定义 `globals.css`**
