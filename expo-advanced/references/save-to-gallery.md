# expo-media-library 保存图片到相册 SOP

## 平台差异

`expo-media-library` 仅支持 iOS/Android，Web 端需使用 `<a>` 标签下载。

## 依赖安装

```bash
cd client && npx expo install expo-media-library expo-file-system
```

## 关键注意事项

| 注意点 | 说明 |
|--------|------|
| **writeOnly 参数** | `requestPermissionsAsync(true)` 只请求写入权限，避免 Android 13+ 的 AUDIO 权限错误 |
| **避免 createAlbumAsync** | 只用 `createAssetAsync`，`createAlbumAsync` 会在 Android 10+ 每次保存都弹确认框 |

## 完整实现

```tsx
import { Platform, Alert } from 'react-native';
import * as MediaLibrary from 'expo-media-library';
import * as FileSystem from 'expo-file-system/legacy';

const handleSaveImage = async (imageUrl: string) => {
  if (Platform.OS === 'web') {
    const link = document.createElement('a');
    link.href = imageUrl;
    link.download = `image_${Date.now()}.png`;
    link.target = '_blank';
    link.click();
    return;
  }
  const { status } = await MediaLibrary.requestPermissionsAsync(true);
  if (status !== 'granted') return Alert.alert('提示', '需要相册权限');
  // @ts-ignore
  const { uri } = await (FileSystem as any).downloadAsync(imageUrl, `${(FileSystem as any).cacheDirectory}img_${Date.now()}.png`);
  await MediaLibrary.createAssetAsync(uri);
  Alert.alert('成功', '图片已保存到相册');
}
```