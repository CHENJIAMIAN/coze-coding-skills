# expo-av 音频录制与播放 SOP

## 依赖安装

```bash
cd client && npx expo install expo-av
```

## 1. 音频播放

**创建音频**：必须设置 `isLooping: false` 防止循环播放。

```tsx
const { sound } = await Audio.Sound.createAsync(
  { uri: audioUrl },
  { shouldPlay: false, isLooping: false, rate: speechRate, shouldCorrectPitch: true },
  (status) => { if (status.isLoaded && status.didJustFinish) setIsPlaying(false); }
);
```

**播放控制**：播放完成后需 `setPositionAsync(0)` 重置位置才能重新播放。

```tsx
const status = await soundRef.current.getStatusAsync();
if (status.isLoaded && status.positionMillis >= (status.durationMillis || 0)) {
  await soundRef.current.setPositionAsync(0);
}
await soundRef.current.playAsync();
```

## 2. 音频录制

### 交互模式（根据需求选择）

- **点击切换（推荐）**：点击开始/再点击停止，按钮文字或图标随状态切换
- **长按录音**：`onPressIn` 开始录音，`onPressOut` 停止录音

### 技术要点

| 要点 | 说明 |
|------|------|
| **权限必须提前申请** | 进入页面时或首次点击录音按钮时先调用 `Audio.requestPermissionsAsync()`，权限确认后再允许录音操作。禁止在 `onPressIn` 中申请权限（弹窗会导致 `onPressOut` 丢失，状态卡死） |
| **Recording 对象管理** | 同一时间只能有一个 Recording 对象。停止录音后需 `stopAndUnloadAsync()` 并将 `recordingRef.current = null`；开始录音前检查 `if (recordingRef.current)` 存在则先清理，防止异常情况 |
| **音频模式设置** | 录音前调用 `Audio.setAudioModeAsync({ allowsRecordingIOS: true })` |
| **录音品质** | 语音识别场景用 `Audio.RecordingOptionsPresets.HIGH_QUALITY`，一般场景用 `DEFAULT` |

### 通用录音示例

```tsx
import { Audio } from 'expo-av';
import { useRef, useState, useEffect } from 'react';
import { Alert } from 'react-native';

const [isRecording, setIsRecording] = useState(false);
const [hasPermission, setHasPermission] = useState(false);
const recordingRef = useRef<Audio.Recording | null>(null);

// 1.组件挂载时申请录音权限，必须使用Audio.requestPermissionsAsync(兼容移动端和web)，不能在onPressIn中申请
useEffect(() => {
  (async () => {
    const { status } = await Audio.requestPermissionsAsync();
    setHasPermission(status === 'granted');
  })();
}, []);

const startRecording = async () => {
  if (!hasPermission) {
    const { status } = await Audio.requestPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('需要权限', '请授予录音权限');
      return;
    }
    setHasPermission(true);
  }

  if (recordingRef.current) {
    await recordingRef.current.stopAndUnloadAsync();
    recordingRef.current = null;
  }

  try {
    await Audio.setAudioModeAsync({ allowsRecordingIOS: true, playsInSilentModeIOS: true });
    const recording = new Audio.Recording();
    await recording.prepareToRecordAsync(Audio.RecordingOptionsPresets.HIGH_QUALITY);
    await recording.startAsync();
    recordingRef.current = recording; // 2. 开始录音后，将recording对象赋值给ref，后续操作都通过ref操作
    setIsRecording(true);
  } catch (error) {
    console.error('录音失败:', error);
  }
};

const stopRecording = async () => {
  if (!recordingRef.current) return;

  try {
    await recordingRef.current.stopAndUnloadAsync();
    const uri = recordingRef.current.getURI();
    recordingRef.current = null; // 重置引用，防止重复使用
    setIsRecording(false); // 重置状态，准备下一次录音

    if (uri) {
      handleRecordingComplete(uri);// 3. 录音完成后，调用处理函数处理录音文件: 如上传到服务器，如播放
    }
  } catch (error) {
    console.error('停止录音失败:', error);
  }
};
```

### app.config.ts 插件配置

```typescript
plugins: [
  [
    'expo-av',
    {
      microphonePermission: '需要使用麦克风进行录音'
    }
  ]
]
```

## 禁止事项

- 禁止使用 `react-native-audio-recorder-player`（不支持 Web 端，导入会红屏）
- 禁止使用 `react-native-permissions`，必须使用来自`expo-av`包的 `Audio.requestPermissionsAsync()` 申请录音权限
