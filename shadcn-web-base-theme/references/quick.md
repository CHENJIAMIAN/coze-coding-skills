# 参数速查

## 颜色（`--colors`）

| 色系      | 可选值                                                                |
| --------- | --------------------------------------------------------------------- |
| 蓝色系    | `blue`, `bento-blue`, `sky`, `cyan`, `indigo`                         |
| 绿色系    | `green`, `artistic-green`, `supbase-green`, `emerald`, `teal`, `lime` |
| 暖色系    | `orange`, `amber`, `yellow`, `red`, `rose`, `low-pink`, `fuchsia`     |
| 紫色系    | `purple`, `tech-purple`, `violet`                                     |
| 中性/复古 | `neutral`, `gray`, `vintage-grey`, `retro-brown`                      |

默认：`neutral`。详细说明见 [colors.md](references/colors.md)

## 字体（`--fonts`）

| 值         | 风格             | 推荐圆角                 |
| ---------- | ---------------- | ------------------------ |
| `business` | 商务、专业、现代 | `none`, `xs`, `sm`, `md` |
| `classic`  | 经典、优雅、传统 | `sm`, `md`               |
| `playful`  | 活泼、友好、年轻 | `lg`, `xl`, `2xl`        |

默认：`business`。详细说明见 [fonts.md](references/fonts.md)

## 圆角（`--radius`）

| 值          | 效果                       |
| ----------- | -------------------------- |
| `none`      | 完全直角，锋利技术感       |
| `2xs`, `xs` | 极小圆角，精致严谨         |
| `sm`        | 小圆角，专业精致           |
| `md`        | 中等圆角，平衡通用（默认） |
| `lg`        | 大圆角，友好亲近           |
| `xl`, `2xl` | 超大圆角，活泼可爱         |

默认：`md`。详细说明见 [radius.md](references/radius.md)

## 阴影（`--shadow`）

| 值          | 风格                 |
| ----------- | -------------------- |
| `tool`      | 标准实用（默认）     |
| `artistic`  | 微妙精致，适合画廊   |
| `bento`     | 现代卡片，Apple 风格 |
| `cool`      | 冷调科技感           |
| `retro`     | 复古怀旧             |
| `superbase` | 开发者风格           |
| `tech`      | 锐利未来感           |
| `vintage`   | 温暖阅读感           |

默认：`tool`。详细说明见 [shadows.md](references/shadows.md)

## 深色模式（`--default-dark`）

添加此参数开启默认深色模式。适用于开发者工具、多媒体应用、夜间模式优先的场景。
