# 瀑布流布局标准 (Masonry Layout SOP)

**核心目标**：实现 Pinterest 风格，既要防止"摩天大楼"毁版面，又要保证足够的参差感（高低错落）。

## 1. 数据预处理与高度限制算法

> ⚠️ **视觉优化策略**：为了保证瀑布流的"错落感"，**大幅放宽宽高比限制**。允许更扁的横图（制造断层）和适度长的竖图（制造流动感）。

```typescript
// utils/masonry.ts

export interface MasonryItem {
  id: string;
  imageUrl: string;
  aspectRatio: number; // 宽/高
  title?: string;
}

// 1. 视觉修正后的高度计算器
export function getOptimizedDimensions(
  originalAspectRatio: number, 
  columnWidth: number
) {
  // Visual V2 核心优化：拉大高低反差范围
  // Min 0.5: 允许最高为宽度的 2 倍 (长卡片) -> 制造流动感
  // Max 2.0: 允许最扁为宽度的 0.5 倍 (短卡片) -> 制造断层
  const CLAMPED_RATIO = Math.min(Math.max(originalAspectRatio, 0.5), 2.0);

  return {
    height: columnWidth / CLAMPED_RATIO,
    isClamped: originalAspectRatio < 0.5 
  };
}

// 2. 贪心分配算法 (Greedy Layout)
export function distributeItems<T extends MasonryItem>(
  items: T[],
  columnWidth: number,
  columns = 2
) {
  const FOOTER_HEIGHT = 64; // 标题+头像区域高度
  
  const columnArrays: T[][] = Array.from({ length: columns }, () => []);
  const columnHeights: number[] = Array(columns).fill(0);

  items.forEach((item) => {
    const { height: imgHeight } = getOptimizedDimensions(item.aspectRatio || 1, columnWidth);
    const totalItemHeight = imgHeight + FOOTER_HEIGHT;

    // 永远放入当前最矮的那一列
    const shortestIndex = columnHeights.indexOf(Math.min(...columnHeights));
    
    columnArrays[shortestIndex].push(item);
    columnHeights[shortestIndex] += totalItemHeight;
  });

  return columnArrays;
}

/**
 * [CRITICAL MOCK GENERATOR]
 * 开发阶段必须使用此函数生成测试数据！
 * 强制混合三种极端比例，严禁使用统一比例，否则无法验证瀑布流效果。
 */
export function generateMockMasonryData(count = 20): MasonryItem[] {
  return Array.from({ length: count }).map((_, i) => {
    // 强制分布逻辑：
    // - 20% 超扁 (16:9, ratio ~1.7) -> 制造缺口
    // - 50% 常规 (3:4 ~ 1:1, ratio 0.75 ~ 1.0) -> 填充基底
    // - 30% 超长 (9:16, ratio ~0.56) -> 制造瀑布流
    let ratio;
    const seed = Math.random();
    
    if (seed < 0.2) {
      ratio = 1.6 + Math.random() * 0.2; // 扁图
    } else if (seed < 0.7) {
      ratio = 0.75 + Math.random() * 0.4; // 常规图
    } else {
      ratio = 0.5 + Math.random() * 0.1; // 长图
    }

    // 生成对应尺寸的 picsum 图片，防止拉伸
    const w = 400;
    const h = Math.floor(w / ratio);
    
    return {
      id: String(i),
      imageUrl: `https://picsum.photos/${w}/${h}?random=${i}`, // 关键：URL带真实尺寸
      aspectRatio: ratio,
      title: seed < 0.3 ? `长标题测试 ${i} - 这是一个跨越多行的标题示例，用于测试底部高度自适应` : `短标题 ${i}`,
    };
  });
}
```

## 2. 组件实现规范

采用 `ScrollView` + `Flex Row` 结构，并强制使用 `expo-image` 优化性能。

```tsx
// components/MasonryGrid.tsx
import React, { useMemo } from 'react';
import { View, ScrollView, useWindowDimensions, StyleSheet, Pressable } from 'react-native';
import { Image } from 'expo-image';
import { distributeItems, getOptimizedDimensions, MasonryItem } from '@/utils/masonry';
import { ThemedText } from '@/components/ThemedText';
import { useTheme } from '@/hooks/useTheme';

export function MasonryGrid({ data }: { data: MasonryItem[] }) {
  const { width } = useWindowDimensions();
  const { theme } = useTheme();
  
  // 布局常量
  const COLUMNS = 2;
  const GAP = 12;
  const PADDING = 16;
  const COLUMN_WIDTH = (width - PADDING * 2 - GAP * (COLUMNS - 1)) / COLUMNS;

  // 使用 useMemo 缓存计算结果
  const columnData = useMemo(() => 
    distributeItems(data, COLUMN_WIDTH, COLUMNS), 
  [data, COLUMN_WIDTH]);

  return (
    <ScrollView contentContainerStyle={[styles.container, { padding: PADDING }]}>
      <View style={[styles.columnsProps, { gap: GAP }]}>
        {columnData.map((colItems, colIndex) => (
          <View key={colIndex} style={[styles.column, { gap: GAP }]}>
            {colItems.map((item) => {
              // 获取修正后的高度
              const { height } = getOptimizedDimensions(item.aspectRatio, COLUMN_WIDTH);
              
              return (
                <Pressable key={item.id} style={[styles.card, { backgroundColor: theme.surface }]}>
                  {/* 图片容器 */}
                  <View style={[styles.imageWrapper, { height, width: COLUMN_WIDTH }]}>
                    <Image
                      source={item.imageUrl}
                      style={{ flex: 1 }}
                      contentFit="cover" 
                      transition={200}
                    />
                  </View>
                  <View style={styles.textWrapper}>
                    <ThemedText numberOfLines={2} variant="caption">
                      {item.title}
                    </ThemedText>
                  </View>
                </Pressable>
              );
            })}
          </View>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flexGrow: 1 },
  columnsProps: { flexDirection: 'row' },
  column: { flex: 1 },
  card: { borderRadius: 12, overflow: 'hidden', marginBottom: 0 }, 
  imageWrapper: { overflow: 'hidden', backgroundColor: '#e1e1e1' },
  textWrapper: { padding: 8 },
});
```

## 禁止事项

- 数据的图片宽高比 (`aspectRatio`) **必须**随机生成多种比例，**绝对禁止**全部使用 1:1 方图，否则无法验证交错排列的视觉效果
- **严禁**使用 via.placeholder.com（该服务已失效）