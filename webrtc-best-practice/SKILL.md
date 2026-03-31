---
name: webrtc-best-practice
description: 摄像头、麦克风、屏幕共享开发规范。当用户需求涉及：拍照、相机、视频通话、直播、录屏、二维码扫描、人脸识别等需要调用摄像头或麦克风的功能时，必须 MUST 阅读此规范！
---

# WebRTC 规范

## 摄像头功能开发指导

摄像头、麦克风、屏幕共享开发规范。当用户需求涉及：拍照、相机、视频通话、直播、录屏、二维码扫描、人脸识别等需要调用摄像头或麦克风的功能时，必须先阅读此规范。

### 规则 1：Video 元素禁止条件渲染

**❌ 错误**

```tsx
{
  isStreaming ? <video ref={videoRef} /> : <div>未开启</div>;
}
```

**✅ 正确**

```tsx
<video ref={videoRef} className={isStreaming ? "block" : "hidden"} />;
{
  !isStreaming && <div className="absolute inset-0">未开启</div>;
}
```

**原因**：条件渲染导致 `videoRef.current` 在需要时为 `null`。

---

### 规则 2：必须等待 loadedmetadata 事件

**❌ 错误**

```typescript
videoRef.current.srcObject = stream;
setIsStreaming(true); // 视频还没准备好
```

**✅ 正确**

```typescript
videoRef.current.srcObject = stream;
videoRef.current.onloadedmetadata = () => {
  videoRef.current?.play();
  setIsStreaming(true);
};
```

**原因**：`srcObject` 赋值后浏览器需要时间解码。

---

### 规则 3：操作前验证视频尺寸

**❌ 错误**

```typescript
if (videoRef.current) {
  ctx.drawImage(video, 0, 0); // 可能画出空白
}
```

**✅ 正确**

```typescript
if (!videoRef.current || !isStreaming) return;
if (video.videoWidth === 0) return;
ctx.drawImage(video, 0, 0, video.videoWidth, video.videoHeight);
```

---

### 规则 4：视频容器必须有尺寸约束

**❌ 错误 - 无约束导致画面撑满屏幕**

```tsx
<div className="min-h-screen flex flex-col">
  <div className="flex-1">
    <video className="w-full h-full" />
  </div>
</div>
```

**✅ 正确 - 添加 max-width 和 aspect-ratio**

```tsx
<div className="min-h-screen flex items-center justify-center p-4">
  <div className="w-full max-w-2xl">
    <div
      className="relative bg-black rounded-xl overflow-hidden"
      style={{ aspectRatio: "16/9" }}
    >
      <video className="w-full h-full object-cover" />
    </div>
  </div>
</div>
```

---

### 规则 5：弹出层使用 fixed 定位

**❌ 错误 - absolute 相对于错误的父元素**

```tsx
<div className="flex-1 relative">
  <video />
  {photo && <div className="absolute inset-0">预览</div>}
</div>
```

**✅ 正确 - fixed 定位独立于布局**

```tsx
{
  photo && (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center"
      style={{ backgroundColor: "rgba(0,0,0,0.9)" }}
    >
      <img src={photo} />
    </div>
  );
}
```

---

### 规则 6：预览内容禁止嵌套无尺寸容器

**❌ 错误 - 多余的无尺寸容器导致图片不显示**

```tsx
{
  capturedPhoto && (
    <div className="relative">
      {" "}
      {/* ❌ 没有尺寸 */}
      <img className="absolute inset-0 w-full h-full" src={capturedPhoto} />
    </div>
  );
}
```

**✅ 正确 - 直接相对于有尺寸的父容器定位**

```tsx
{
  /* 方案1：使用 Fragment */
}
{
  capturedPhoto && (
    <>
      <img
        className="absolute inset-0 w-full h-full object-cover"
        src={capturedPhoto}
      />
    </>
  );
}

{
  /* 方案2：容器必须有尺寸 */
}
{
  capturedPhoto && (
    <div className="absolute inset-0">
      {" "}
      {/* ✅ inset-0 提供尺寸 */}
      <img className="w-full h-full object-cover" src={capturedPhoto} />
    </div>
  );
}
```

**原因**：中间容器无尺寸时，内部 `absolute` 元素尺寸为 0。

---

### 规则 7：Tailwind CSS 4 透明度语法

**❌ 禁止**

```tsx
className = "bg-black bg-opacity-50";
className = "bg-black/50";
```

**✅ 必须使用内联样式**

```tsx
style={{ backgroundColor: "rgba(0,0,0,0.5)" }}
```

---

### Video 元素必需属性

```tsx
<video
  ref={videoRef}
  autoPlay
  playsInline // iOS 必需
  muted // 自动播放策略要求
/>
```

---

### 组件卸载清理

```typescript
useEffect(() => {
  return () => {
    streamRef.current?.getTracks().forEach((track) => track.stop());
  };
}, []);
```

---

### 问题自查表

| 症状         | 原因                  | 解决                           |
| ------------ | --------------------- | ------------------------------ |
| 点击无反应   | video 条件渲染        | 始终渲染，CSS 控制显隐         |
| 黑屏         | 未等待 loadedmetadata | 在回调中更新状态               |
| 拍照空白     | videoWidth === 0      | 验证尺寸后再操作               |
| 画面超大     | 无尺寸约束            | 添加 max-width + aspect-ratio  |
| 弹窗重叠     | 用了 absolute         | 改用 fixed                     |
| 照片预览黑屏 | 嵌套无尺寸容器        | 用 Fragment 或给容器加 inset-0 |
| 遮罩透明     | CSS4 语法             | 用内联 rgba                    |
