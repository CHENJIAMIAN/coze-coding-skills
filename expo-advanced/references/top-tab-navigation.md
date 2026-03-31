# 顶部 Tab 导航（页面内子 Tab）

**适用场景**：某个页面内部需要顶部可滑动切换的子 Tab（如首页下有：关注、推荐、热榜）。

## 技术选型

| 导航类型 | 使用方案 | 说明 |
|----------|----------|------|
| 底部 Tab Bar | Expo Router `(tabs)` 目录 | 路由级别，每个 Tab 是独立页面 |
| 顶部 Tab | `react-native-tab-view` 库 | 组件级别，在页面内部实现 |

## 安装

```bash
cd client && npx expo install react-native-tab-view react-native-pager-view
```

## 两种常见布局模式

**根据产品需求选择合适的布局**：

### 模式 A：无 Header（参考抖音/快手/小红书等风格）

```
┌─────────────────────────────────┐
│           StatusBar             │
├─────────────────────────────────┤
│  ☰  │ Tab1  Tab2  Tab3 ... │ 🔍 │ ← 顶部 Tab 栏（紧贴状态栏）
├─────────────────────────────────┤
│          Tab Content            │
└─────────────────────────────────┘
```

### 模式 B：有 Header（参考微博/B站等风格）

```
┌─────────────────────────────────┐
│           StatusBar             │
├─────────────────────────────────┤
│  Header（头像/标题/搜索框等）    │ ← 自定义 Header
├─────────────────────────────────┤
│     Tab1    Tab2    Tab3        │ ← 顶部 Tab 栏（Header 下方）
├─────────────────────────────────┤
│          Tab Content            │
└─────────────────────────────────┘
```

## 核心要求

| 要求 | 实现方式 |
|------|----------|
| **吸顶效果** | Header + TabBar 固定顶部，仅内容区滚动 |
| **手势滑动切换** | `react-native-pager-view` 原生手势 |
| **Tab 水平滚动** | Tab 多时设置 `scrollEnabled={true}` |
| **灵活 Header** | Header 作为独立组件，按需渲染 |

## 参考代码

```tsx
import { TabView, SceneMap, TabBar } from 'react-native-tab-view';

// ... 你的组件定义

const layout = useWindowDimensions();
const [index, setIndex] = React.useState(0);
const [routes] = React.useState([
  { key: 'first', title: '推荐' },
  { key: 'second', title: '热榜' },
]);

// 渲染通过 SceneMap 或 renderScene 映射的组件
const renderScene = SceneMap({
  first: FirstRoute,
  second: SecondRoute,
});

return (
  <View style={{ flex: 1, paddingTop: insets.top }}>
    {/* 模式 B 的 Header 插在这里 */}
    {showHeader && <Header />}
    
    <TabView
      navigationState={{ index, routes }}
      renderScene={renderScene}
      onIndexChange={setIndex}
      initialLayout={{ width: layout.width }}
      lazy // 开启懒加载
      renderTabBar={props => (
        <TabBar
          {...props}
          scrollEnabled={routes.length > 4}
          indicatorStyle={{ backgroundColor: 'white' }}
          style={{ backgroundColor: 'blue' }}
          tabStyle={routes.length > 4 ? { width: 'auto' } : {}}
        />
      )}
    />
  </View>
);
```

## 子 Tab 组件位置

放在对应 screen 目录下，如 `screens/home/tabs/RecommendTab.tsx`。

## 禁止事项

- **禁止**用嵌套 `(tabs)` 目录或 Expo Router 实现顶部 Tab，Expo Router 不支持嵌套 Tabs