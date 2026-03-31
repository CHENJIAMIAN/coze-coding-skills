---
name: ui-design-ref
description: 根据参考风格预设生成高质感UI应用。在设计APP时必须优先加载和遵循。当用户要求开发APP、设计页面、创建UI界面时，务必触发此skill来获取视觉设计参考和通用UI规范。
---

## 工作流程

### 第一步：分析用户需求，选择风格

根据用户的 APP 类型和需求，从以下 9 种风格中选择**最适配的 1 种**，然后读取对应的参考文件：

| 风格 | 适用场景 | 参考文件 |
|------|----------|----------|
| **柔和卡片风** | AI工具、生活服务、SaaS、在线教育、习惯养成、健康管理 | `./reference/柔和卡片.md` |
| **极光柔和风** | 冥想正念、助眠、呼吸训练、情绪日记、星座占卜 | `./reference/极光柔和.md` |
| **杂志风** | 新闻阅读、博客、长文笔记、Mook类内容 | `./reference/杂志风.md` |
| **克莱因蓝高定风** | 电商精品、奢侈品展示、邀请函/票务、高端会员系统 | `./reference/克莱因蓝高定风.md` |
| **自然有机风** | 环保/可持续、有机食品、花园管理、瑜伽、户外徒步 | `./reference/自然有机.md` |
| **3D黏土风** | 儿童教育、健康生活、社交娱乐、轻量工具、趣味电商 | `./reference/3D黏土风.md` |
| **暗黑科技风** | 游戏面板、加密货币、开发者工具、数据监控、极客社区 | `./reference/暗黑科技风.md` |
| **玻璃拟态风** | 天气/仪表盘、音乐播放器、社交资料页、金融概览、智能家居 | `./reference/玻璃拟态.md` |
| **纯白极简风** | 笔记/效率工具、阅读类、博客、极简电商、SaaS管理 | `./reference/纯白极简风.md` |

### 第二步：输出布局设计方案（文字描述）

**导航结构：**
- TAB数量、名称、图标
- 导航位置（底部TabBar / 顶部导航 / 侧边栏）

**各TAB内布局类型：**
- 卡片网格：等宽卡片排列，适合展示同类内容
- 瀑布流：不等高卡片，适合图片/内容长度不一
- 列表：单列信息流，适合时间线/消息
- 宫格：图标+文字入口，适合功能导航
- 轮播+卡片组合：顶部焦点+下方内容
- 详情页：大图+信息卡片+操作按钮

**配图策略：** 使用 unsplash 配图

### 第三步：生成代码

参考所选风格的预设文件，提取以下要素后生成代码：
- **配色方案**：主色、辅色、背景色、文字色等
- **核心样式手法**：阴影、圆角、渐变等特征
- **组件风格**：按钮、卡片、输入框、导航栏等

**重要：不需要完整复刻参考文件，可根据具体APP特点灵活调整配色和布局。**

### 第四步：验收标准

- UI质感与所选风格一致
- 核心功能完整可用
- 结合应用特点适当改造

---

## 九种设计风格速览

### 1. 柔和卡片风 (Soft Card UI)
**感觉：** 科技、高效、通透、友好
**核心特征：**
- 新拟态双层阴影（凸起/凹陷效果）
- 大圆角卡片 (borderRadius: 24)
- 暖灰白背景 (#F0F0F3)
- 渐变按钮 + 有色投影

### 2. 极光柔和风 (Aurora Style)
**感觉：** 治愈、梦幻、情绪化、艺术感
**核心特征：**
- 深空暗底 (#0D1026)
- 极光渐变辉光 (紫/青/粉)
- 毛玻璃卡片 (BlurView)
- 大圆角 (borderRadius: 28)

### 3. 杂志风 (Editorial Style)
**感觉：** 文艺、专业、阅读沉浸
**核心特征：**
- 极简黑白排版
- 衬线字体 + 强留白
- 无阴影，靠线条区分层级
- 编辑红点缀 (#C8102E)

### 4. 克莱因蓝高定风 (Klein Blue Luxury)
**感觉：** 高端、奢华、精致
**核心特征：**
- 克莱因蓝 (#002FA7) + 香槟金 (#C9A96E)
- 直角/小圆角设计
- 极细字重 + 大字间距
- 金色细线装饰

### 5. 自然有机风 (Organic Nature)
**感觉：** 温暖、自然、亲切
**核心特征：**
- 大地色系（森林绿、陶土棕）
- 有机不规则圆角（叶片/鹅卵石形）
- 米黄暖白背景 (#FDF8F0)
- 手绘虚线装饰

### 6. 3D黏土风 (Clay 3D)
**感觉：** 可爱、柔软、趣味、安全感
**核心特征：**
- 柔和粉彩配色（黏土紫、黏土粉）
- 黏土凸起阴影 + 白色内描边高光
- 大圆角胶囊感 (borderRadius: 24)
- 弹性动画入场 (withSpring)

### 7. 暗黑科技风 (Cyber Tech)
**感觉：** 硬核、极客、未来感、赛博朋克
**核心特征：**
- 纯黑底 (#0A0A0F) + 霓虹发光
- 电光青 (#00F0FF) + 霓虹紫 (#BF00FF)
- 霓虹发光边框 + 同色扩散阴影
- 等宽字体 (JetBrains Mono)

### 8. 玻璃拟态风 (Glassmorphism)
**感觉：** 轻盈、通透、现代、科技感
**核心特征：**
- 深空渐变背景
- 毛玻璃卡片 (rgba + blur)
- 高光内描边模拟光照折射
- 光斑装饰点缀

### 9. 纯白极简风 (Minimal White)
**感觉：** 克制、高级、专注、空气感
**核心特征：**
- 纯白大留白 (#FFFFFF)
- 极细线条分割（无阴影）
- 黑白灰为主 + 微妙强调色
- 排版为王，无多余装饰

---

## 主题驱动样式 [IMPORTANT]

所有页面**必须**使用主题驱动的样式方式，参考模板页面：

**styles.ts 模板**：
```tsx
import { StyleSheet } from 'react-native';
import { Spacing, BorderRadius, Theme } from '@/constants/theme';
export const createStyles = (theme: Theme) => {
  return StyleSheet.create({
    scrollContent: {
      flexGrow: 1,
      paddingHorizontal: Spacing.lg,
      paddingTop: Spacing["2xl"],
      paddingBottom: Spacing["5xl"],
    },
    header: {
      marginBottom: Spacing.xl,
    },
    submitButton: {
      backgroundColor: theme.primary,
      paddingVertical: Spacing.lg,
      paddingHorizontal: Spacing["2xl"],
      borderRadius: BorderRadius.lg,
      alignItems: 'center',
    },
  });
};
```

**index.tsx 模板**：
```tsx
import React, { useMemo } from 'react';
import { ScrollView, TouchableOpacity } from 'react-native';
import { useTheme } from '@/hooks/useTheme';
import { Screen } from '@/components/Screen';
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';
import { createStyles } from './styles';
export default function PageScreen() {
  const { theme, isDark } = useTheme();
  const styles = useMemo(() => createStyles(theme), [theme]);
  return (
    <Screen backgroundColor={theme.backgroundRoot} statusBarStyle={isDark ? 'light' : 'dark'}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <ThemedView level="root" style={styles.header}>
          <ThemedText variant="h3" color={theme.textPrimary}>标题</ThemedText>
        </ThemedView>
        {/* 页面内容 */}
        <TouchableOpacity style={styles.submitButton}>
          <ThemedText variant="smallMedium" color={theme.buttonPrimaryText}>主要按钮</ThemedText>
        </TouchableOpacity>
      </ScrollView>
    </Screen>
  );
}
```

**核心要点**：
- 使用 `createStyles(theme)` 工厂函数生成样式，通过 `useMemo` 缓存
- 从 `@/constants/theme` 导入 `Spacing`、`BorderRadius`、`Theme` 类型
- 使用 `ThemedText` 组件渲染文本，通过 `variant` 指定字体样式，通过 `color` 指定颜色
- 使用 `ThemedView` 组件渲染容器，通过 `level` 指定背景层级（root/default/tertiary）
- **所有颜色必须来自 `theme.*`**，参考下方颜色映射表选择合适的颜色键
- 间距使用 `Spacing.*`，圆角使用 `BorderRadius.*`

---

## 主题变更规范

分析用户每次对话意图，如果用户明确指定使用 暗色 或 亮色 主题，则优先满足用户需求，查看 `client/hooks/useTheme.ts` 代码，改成使用固定主题方案。
用户如果对于主题没有偏好，则无需修改。

---

## theme 颜色键映射表（定义在 `@/constants/theme.ts`）

**所有颜色属性（含图标/SVG 的 `color`）必须优先使用以下颜色键，仅当确实无匹配场景时才可自定义（但严禁使用 `#fff`/`#000`/`white`/`black`）：**

| 用途 | 使用方式 | 使用场景 |
|------|----------|----------|
| **文本** | `theme.textPrimary` | 主要文本、标题 |
| | `theme.textSecondary` | 次要文本、描述 |
| | `theme.textMuted` | 辅助文本、提示、placeholder |
| **背景** | `theme.backgroundRoot` | 页面根背景 |
| | `theme.backgroundDefault` | 默认容器背景、卡片背景 |
| | `theme.backgroundTertiary` | 三级背景、输入框背景（去线留白） |
| **边框** | `theme.border` | 默认边框 |
| | `theme.borderLight` | 浅色边框、去线留白背景 |
| **按钮** | `theme.primary` | 主按钮背景 |
| | `theme.buttonPrimaryText` | 主按钮文字、主按钮内图标 |
| **图标** | `theme.textPrimary` | 主要图标 |
| | `theme.textMuted` | 辅助图标、placeholder 图标 |
| | `theme.primary` | 强调图标、选中态图标 |
| | `theme.tabIconSelected` | Tab 选中图标 |
| **状态** | `theme.success` / `theme.error` | 成功/错误 |
| **品牌** | `theme.primary` | 主色调（Indigo）、Tab 选中色、强调色 |
| | `theme.accent` | 点缀色（Violet）、创意/魔法元素 |

---

## 样式属性安全规范 [CRITICAL]

Android 原生层对部分样式属性有严格校验，值非法时会导致应用崩溃。

**动态计算样式值时必须兜底**，如：
- `fontSize`/`lineHeight`：必须 > 0，用 `value || 14` 兜底
- `width`/`height`/`borderRadius`：不能为负，用 `Math.max(value, 0)` 兜底
- `opacity`：必须在 0-1 之间，用 `Math.min(Math.max(value, 0), 1)` 兜底

---

## 现代移动端 UI 设计原则 [CRITICAL]

生成页面时**必须**遵循以下 6 大设计法则。**Agent 需首先分析 App 的业务类型（如金融、社交、AI、健康），并根据「法则 1」选择或自行拓展符合当前开发场景的配色方案。**

### 1. 场景化色彩美学
> "拒绝千篇一律的蓝。根据业务性格，定制色彩情绪。"

*   **智能配色策略**：根据当前 App 类型选择 `theme` 色值，或者根据用户需求自行拓展更符合当前场景的配色，**严禁硬编码**，必须更新到 `constants/theme.ts`。

| App 类型 | 视觉关键词 | Primary (主色) | Background Root (根背景) | **Surface (卡片背景)** | Shadow Tone (阴影色相) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AI / SaaS** | 科技、冷静 | `#4F46E5` (Indigo) | `#F3F4F6` (Cool Gray) | `#FFFFFF` (纯白，强调高对比) | `#4F46E5` (蓝紫调) |
| **Fintech / 金融** | 信任、收敛 | `#0F172A` (Slate) | `#F8FAFC` (Slate-50) | `#FFFFFF` (纯白，强调清晰) | `#64748B` (蓝灰调) |
| **Personal / 日记** | 亲密、肤感 | `#EA580C` (Warm Orange) | `#FFF7ED` (Orange-50) | `rgba(255,255,255,0.7)` | `#C2410C` (暖橘调) |
| **Health / 运动** | 治愈、洁净 | `#059669` (Emerald) | `#F8FAFC` (冷瓷白) | `rgba(255,255,255,0.8)` | `#059669` (翠绿调) |
| **Social / 社交** | 活力、通透 | `#F43F5E` (Rose) | `#FAFAFA` (中性白) | `rgba(255,255,255,0.9)` | `#F43F5E` (红粉调) |
| **Edu / 阅读** | 护眼、纸质 | `#B45309` (Amber) | `#F5F5F4` (Stone-100) | `#FAFAF9` (Stone-50, 纸张白) | `#78716C` (暖灰调) |
| **Travel / 出行** | 蓝天、广阔 | `#0EA5E9` (Sky) | `#F0F9FF` (Sky-50) | `#FFFFFF` | `#0284C7` (天蓝调) |
| **Metaphysics / 周易** | 玄妙、古朴、檀木 | `#854D0E` (古铜金/Antique) | `#FFFCF5` (古书纸/Old Paper) | `rgba(255,253,240,0.95)` | `#451A03` (深檀褐) |
| **Gov / 政务** | 庄重、权威、正式 | `#B91C1C` (中国红/Official) | `#F9FAFB` (严谨灰/Gray-50) | `#FFFFFF` (纯白，严禁透明) | `#991B1B` (深红调) |

*   **色彩融合铁律 (Critical)**：
    *   **拒绝死白**：当 `Background Root` 为暖色（如 Orange/Yellow/Rose）或明显冷色（Green/Teal）时，卡片背景**严禁**使用 `#FFFFFF`。必须混合 2%~5% 的主色调，或者使用 80%~90% 透明度的白色（确保 View 层级正确）。
    *   **有色阴影**：
        *   **禁止**使用纯黑阴影 (`#000000`)。
        *   **必须**使用与主色调一致的颜色作为阴影色（参考表格 `Shadow Tone`），并设置极低透明度 (`opacity: 0.06` ~ `0.1`)。
        *   *原理*：黑色阴影在彩色背景上看起来像脏污，有色阴影才通透。
        *   使用boxShadow实现：`<View style={{ boxShadow: '0px 4px 6px rgba(79,70,229,0.1), 0px 1px 3px rgba(0,0,0,0.05)' }} />`
    *   **文字适配**：
        *   在**暖色背景**（如日记）上，文字尽量不要用冷灰 (`#4B5563`)，而要用**暖灰/棕褐**（如 `#422006` 或 `#78350F`）来保持画面的温润感。

### 2. 图标与符号系统
> "图标不是素材，是 UI 的一部分。"

*   **容器化**：
    *   **禁止裸奔**：不要直接放置一个孤立的 Icon。
    *   **禁止使用Emoji作为ICON，必须使用 @expo/vector-icons 中的图标集**，如 FontAwesome6。
    *   **做法**：创建一个 `View` 容器，设置 `theme.backgroundTertiary` 或 `theme.primary` (opacity 10%) 作为背景，设置圆角 (`borderRadius: 12`)，将图标居中放置。
    *   **代码范式**：
        ```tsx
        // 正确范例
        <View style={{
            width: 48, height: 48,
            borderRadius: 12,
            backgroundColor: theme.backgroundTertiary,
            justifyContent: 'center', alignItems: 'center'
        }}>
            <Icon name="Wallet" size={24} color={theme.textPrimary} />
        </View>
        ```
*   **视觉一致性**：图标的 `strokeWidth` (线宽) 建议统一设为 `2` 或 `1.5`，保持精致感。

### 3. 物理质感与深度
> "拒绝扁平，建立悬浮。"

*   **Hero Header 视觉锚点**：
    *   顶部使用 `theme.primary` 大色块建立品牌基调。
    *   下方内容区域使用 **负 Margin** 向上重叠覆盖 Header，营造前后景深。
*   **弥散阴影**：
    *   拒绝黑且硬的默认阴影。使用大范围 (`radius: 12-24`)、低透明度 (`opacity: 0.08-0.12`)、含环境色倾向的柔和阴影。

### 4. 极致的排版对比
> "用户不是在阅读，而是在扫描；只有大和小，没有中间态。"

*   **夸张的字号差**：
    *   **核心数据/标题**：极大、极粗。使用 `h1`/`h2` (32px-40px)，字重 Bold/Heavy。数字建议使用 Monospace 字体增加专业感。
    *   **辅助标签**：极小、极淡。使用 `caption` (11px-13px)，颜色使用 `theme.textMuted`。

### 5. 容器化设计与去线化
> "线框是束缚，容器是包裹；用空间代替线条。"

*   **输入框去线化**：
    *   抛弃描边风格。输入框使用 `theme.backgroundTertiary` (浅灰/浅色背景) + `borderRadius: 12-16`，配合深色文字形成内嵌感。
*   **卡片封装**：列表项拒绝使用全通分割线，应封装为独立的圆角卡片，卡片之间通过 `gap` 或 `marginBottom` 分隔。

### 6. 奢侈的留白与呼吸感
> "空间即质感；不要怕浪费屏幕。"

*   **Padding 是奢侈品**：
    *   容器内部 Padding 起步为 `Spacing.lg` (20px-24px)，甚至 `Spacing.xl`。
    *   如果内容看起来像 Excel 表格，说明 Padding 不够。
*   **布局间距**：全面使用 Flexbox 的 `gap` 属性（如 `gap: Spacing.lg`）来保证子元素间距的绝对统一。
