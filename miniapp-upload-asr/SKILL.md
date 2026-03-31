---
name: miniapp-upload-asr
description: 文件上传跨端实现规范（MUST READ）：当用户需求涉及「文件上传」「图片上传」「上传文件」时，必须加载此技能以确保 H5/小程序双端兼容！本技能解决使用 Network.uploadFile 实现文件上传时的跨端问题，包含：前端 uploadFile 正确用法与参数规范、后端 Multer file.path + file.buffer 双模式文件读取、Multer memoryStorage 配置、Content-Type boundary 问题修复、图片上传到大模型分析的完整流程。同时覆盖录音（RecorderManager 平台检测与 H5 降级）、语音识别（ASR 音频格式 WAV/16kHz 要求）等媒体功能的跨端适配。
---

# 媒体与上传功能跨端适配

## 一、录音功能跨端适配 (CRITICAL - RecorderManager 专项)

**核心问题**: RecorderManager 是微信小程序专有 API，H5 端不支持，必须进行平台检测和降级处理。

### 强制规则

1. ✅ **录音初始化前必须检测平台** (`Taro.getEnv() === Taro.ENV_TYPE.WEAPP`)
2. ✅ **H5 端必须提供降级提示**，不得直接调用 RecorderManager
3. ✅ **小程序端使用 `Taro.getRecorderManager()`**
4. ❌ **禁止**无检测直接调用 `Taro.getRecorderManager()`

### 标准实现模板

```typescript
import Taro from '@tarojs/taro'
import { useState, useEffect } from 'react'
import { Network } from '@/network'

export default function RecordPage() {
  const [recorderManager, setRecorderManager] = useState<Taro.RecorderManager | null>(null)
  const [isRecording, setIsRecording] = useState(false)
  const [audioPath, setAudioPath] = useState('')
  const isWeapp = Taro.getEnv() === Taro.ENV_TYPE.WEAPP

  useEffect(() => {
    // CRITICAL: 只在小程序端初始化 RecorderManager
    if (isWeapp) {
      const manager = Taro.getRecorderManager()

      manager.onStart(() => {
        console.log('录音开始')
        setIsRecording(true)
      })

      manager.onStop((res) => {
        console.log('录音结束', res.tempFilePath)
        setAudioPath(res.tempFilePath)
        setIsRecording(false)
      })

      manager.onError((err) => {
        console.error('录音错误', err)
        Taro.showToast({ title: '录音失败', icon: 'none' })
      })

      setRecorderManager(manager)
    }
  }, [isWeapp])

  const handleStartRecord = () => {
    if (!isWeapp) {
      Taro.showToast({ title: 'H5端暂不支持录音', icon: 'none' })
      return
    }

    recorderManager?.start({
      format: 'mp3',
      sampleRate: 16000,
      numberOfChannels: 1
    })
  }

  const handleStopRecord = () => {
    recorderManager?.stop()
  }

  const handleUploadAudio = async () => {
    if (!audioPath) return

    try {
      await Network.uploadFile({
        url: '/api/upload-audio',
        filePath: audioPath,
        name: 'audio'
      })
      Taro.showToast({ title: '上传成功', icon: 'success' })
    } catch (error) {
      console.error('上传失败', error)
    }
  }

  return (
    <View className="p-4">
      {isWeapp ? (
        <>
          <Button onClick={handleStartRecord} disabled={isRecording}>
            开始录音
          </Button>
          <Button onClick={handleStopRecord} disabled={!isRecording}>
            停止录音
          </Button>
          {audioPath && (
            <Button onClick={handleUploadAudio}>
              上传录音
            </Button>
          )}
        </>
      ) : (
        <View className="flex items-center justify-center h-64 bg-gray-100 rounded-lg">
          <Text className="block text-gray-500 text-center">
            录音功能仅在小程序中可用{'\n'}
            请在微信小程序中打开体验完整功能
          </Text>
        </View>
      )}
    </View>
  )
}
```

### 常见错误

- **H5 端 getRecorderManager is not defined**：直接调用未检测平台 → `useEffect` 中检测平台后初始化
- **Web 端白屏（录音页）**：Text 未添加 `block` + useState 检测平台 → Text 加 `block` + 直接判断平台
- **小程序端录音无响应**：未监听 onStart/onStop 事件 → 初始化时绑定事件监听
- **录音文件上传失败**：未获取 tempFilePath → 在 onStop 回调中获取

### 关键检查点

- [ ] 是否在 `useEffect` 中初始化 RecorderManager
- [ ] 是否添加 `isWeapp` 平台检测变量
- [ ] 是否在按钮点击时再次检测平台（防御性编程）
- [ ] H5 端是否显示降级提示而非报错
- [ ] 是否正确处理 `onStart`/`onStop`/`onError` 事件

### 错误 vs 正确

```typescript
// ❌ 直接调用
const recorderManager = Taro.getRecorderManager()
// ❌ useState 检测平台（状态延迟）
const [isWeapp, setIsWeapp] = useState(false)
useEffect(() => { setIsWeapp(Taro.getEnv() === Taro.ENV_TYPE.WEAPP) }, [])

// ✅ 直接判断
const isWeapp = Taro.getEnv() === Taro.ENV_TYPE.WEAPP
// ✅ useEffect 中检测后初始化
useEffect(() => {
  if (isWeapp) {
    const manager = Taro.getRecorderManager()
    manager.onStop((res) => { console.log(res.tempFilePath) })
    setRecorderManager(manager)
  }
}, [isWeapp])
// ✅ 点击时再次检测
const handleStart = () => {
  if (!isWeapp) { Taro.showToast({ title: 'H5不支持', icon: 'none' }); return }
  recorderManager?.start({ format: 'mp3' })
}
```

---

## 二、语音识别音频格式规范 (CRITICAL - ASR API 兼容性)

**问题背景**:
ASR（自动语音识别）接口对音频格式有严格要求，不正确的音频格式会导致错误 `invalid argument, invalid format`（错误代码 11103）。

### 强制规则

1. ✅ **必须使用 WAV 格式录音**（16kHz 采样率，单声道）
2. ✅ **必须使用 Taro 原生方法处理音频数据**（避免编码问题）
3. ✅ **后端必须验证音频数据有效性**（长度、格式、base64 正确性）
4. ✅ **必须提供降级方案**（文本输入功能）
5. ❌ **禁止**使用 MP3 格式或其他不兼容格式

### 前端录音 + 转换

```typescript
// 前端录音配置（CRITICAL: 使用 WAV 格式）
recorderManager?.start({
  format: 'wav',        // 必须使用 WAV 格式
  sampleRate: 16000,    // 16kHz 采样率（ASR 标准）
  numberOfChannels: 1,  // 单声道
  frameSize: 50         // 帧大小
})

// 音频数据转换（CRITICAL: 使用 Taro 原生方法）
const fileSystemManager = Taro.getFileSystemManager()
const arrayBuffer = fileSystemManager.readFileSync(audioPath)
const base64 = Taro.arrayBufferToBase64(arrayBuffer) // 使用 Taro 原生方法

// 上传到后端
await Network.request({
  url: '/api/asr/recognize',
  method: 'POST',
  data: { audioData: base64 }
})
```

### 后端验证增强

```typescript
@Post('recognize')
@HttpCode(200)
async recognize(@Body() body: { audioData: string }) {
  const { audioData } = body

  // CRITICAL: 验证音频数据
  if (!audioData || audioData.length === 0) {
    throw new BadRequestException('音频数据为空')
  }

  // 验证 base64 格式
  const base64Regex = /^[A-Za-z0-9+/]+={0,2}$/
  if (!base64Regex.test(audioData)) {
    throw new BadRequestException('音频数据格式错误')
  }

  // 打印调试信息（便于问题排查）
  console.log('音频数据长度:', audioData.length)
  console.log('音频数据预览:', audioData.substring(0, 100))
  console.log('音频数据类型:', typeof audioData)

  // 调用 ASR 服务
  try {
    const result = await this.asrService.recognize(audioData)
    return { code: 200, msg: 'success', data: result }
  } catch (error) {
    console.error('ASR 识别失败:', error.message)
    throw new BadRequestException('语音识别失败，请重试')
  }
}
```

### 降级方案（必须提供）

```tsx
// 提供文本输入功能作为降级方案
<View className="p-4">
  <View className="mb-4">
    <Text className="block text-lg font-semibold mb-2">方式 1：语音记账（小程序）</Text>
    {isWeapp ? (
      <>
        <Button onClick={handleStartRecord} disabled={isRecording}>
          开始录音
        </Button>
        <Button onClick={handleStopRecord} disabled={!isRecording}>
          停止录音
        </Button>
      </>
    ) : (
      <Text className="block text-gray-500">
        语音功能仅在小程序中可用
      </Text>
    )}
  </View>

  <View>
    <Text className="block text-lg font-semibold mb-2">方式 2：文本记账（推荐）</Text>
    <Input
      className="w-full bg-gray-50 rounded-lg p-3"
      placeholder="今天在全家超市买了 35 元午餐"
      value={textInput}
      onInput={(e) => setTextInput(e.detail.value)}
    />
    <Button onClick={handleTextSubmit}>确认记账</Button>
  </View>
</View>
```

**使用建议**:
- **优先推荐文本输入**：更稳定可靠，所有平台可用
- **语音作为辅助**：仅在小程序端提供，依赖网络和 ASR 服务
- **错误处理**：提供明确的错误提示和重试机制

### 常见错误

- **ASR 错误 11103 (invalid format)**：使用 MP3 格式 → 改用 `format: 'wav'`
- **采样率不符**：使用 44100 → 设置 `sampleRate: 16000`
- **base64 编码错误**：用第三方库编码 → 用 `Taro.arrayBufferToBase64()`
- **后端收到空音频**：未正确读取录音文件 → 验证 tempFilePath 有效性
- **无降级方案**：只实现语音输入 → 必须同时提供文本输入

### 常见语音识别错误排查

- **错误代码 11103**
  - 错误信息：invalid argument, invalid format
  - 原因：音频格式不符合要求
  - 解决方案：使用 WAV 格式，16kHz 采样率

- **音频数据为空错误**
  - 错误信息：音频数据为空
  - 原因：未正确读取录音文件
  - 解决方案：检查 `tempFilePath` 是否有效

- **base64 格式错误**
  - 错误信息：base64 格式错误
  - 原因：音频数据编码问题
  - 解决方案：使用 `Taro.arrayBufferToBase64()`

- **ASR 服务调用失败**
  - 错误信息：ASR 服务调用失败
  - 原因：网络问题或服务不可用
  - 解决方案：提示用户使用文本输入，或重试

### 调试建议

如果语音识别仍有问题，检查以下信息：
- [ ] 音频数据长度是否大于 0
- [ ] 音频数据是否为有效的 base64 字符串
- [ ] 录音格式是否为 WAV（16kHz, 单声道）
- [ ] 后端是否正确接收到音频数据
- [ ] ASR 服务调用是否返回错误

### 关键检查点

- [ ] 录音格式是否为 WAV（不是 MP3）
- [ ] 采样率是否为 16000（不是 44100）
- [ ] 是否使用 `Taro.arrayBufferToBase64()` 转换
- [ ] 后端是否验证音频数据有效性
- [ ] 是否提供文本输入降级方案
- [ ] 是否正确处理 ASR 错误并提示用户

---

## 三、文件上传跨端适配

### 强制规则

1. **必须**使用 `Network.uploadFile()` —— 禁止 `Taro.uploadFile()`
2. **禁止**手动设置 `Content-Type`（让 Taro 自动处理 multipart boundary）
3. **禁止**使用 `Taro.getFileSystemManager().readFile()` 手动转 base64
4. **后端必须**同时支持 `file.path`（小程序）和 `file.buffer`（H5）

### 前端正确流程

```typescript
const res = await Taro.chooseImage({ count: 1 });
const uploadRes = await Network.uploadFile({
  url: '/api/upload',
  filePath: res.tempFilePaths[0],
  name: 'file',
  header: { 'Authorization': 'Bearer ...' } // 仅传鉴权，禁止设置 Content-Type
});
```

### 后端双模式读取

```typescript
@Post()
@HttpCode(200)
@UseInterceptors(FileInterceptor('file'))
async uploadFile(@UploadedFile() file: Express.Multer.File) {
  let content: Buffer
  if (file.path) {
    content = await fs.readFile(file.path)       // 小程序端
  } else if (file.buffer) {
    content = file.buffer                         // H5 端
  } else {
    throw new BadRequestException('无法获取文件内容')
  }
  return { code: 200, msg: 'success', data: { filename: file.originalname } }
}
```

### 常见错误

- **400 Boundary not found**：手动设置 Content-Type → 删除 Content-Type header
- **后端 file.path undefined**：H5 端只有 buffer → 同时支持 path 和 buffer
- **H5 端 readFile 报错**：使用小程序专用 API → 用 `Network.uploadFile()`
- **上传 name 不匹配**：前端 name 与 FileInterceptor 不一致 → 确保两者一致

---

## 四、图片上传到大模型的配置规范 (CRITICAL)

**适用场景说明**:
本规范适用于需要**将图片传递给大模型进行 AI 分析**的场景（如图片识别、视觉理解等）。对于普通文件上传（仅存储到对象存储），请参考**第三节的跨端适配方案**（同时支持 `file.path` 和 `file.buffer`）。

### 强制规则

1. **必须 `memoryStorage()`**，不用 `diskStorage()`
2. **必须显式调用 `storage.upload()`** 上传到对象存储
3. **必须生成公网可访问 URL** 传递给大模型

**问题原因**:
文件上传后需要传递给大模型处理（如 AI 图片分析）时，常见以下配置错误：
1. **文件未上传到对象存储**: 直接使用本地文件路径，导致大模型无法访问
2. **未生成可访问的 URL**: 文件上传后没有生成公网可访问的 URL
3. **URL 权限配置错误**: 生成的 URL 不可公开访问或已过期
4. **⚠️ 文件仅保存到本地服务器**: 使用 `diskStorage()` 或其他本地存储方式，文件只保存在服务器本地磁盘而没有上传到对象存储，导致文件无法持久化保存或跨环境访问

**⚠️ 重要提醒：文件上传到对象存储需要显式调用**

很多情况下，文件上传后只保存在本地服务器（如使用 `diskStorage()`），而没有真正上传到对象存储。**必须在代码中显式调用 `storage.upload()` 方法才能将文件上传到对象存储服务（如 S3、OSS 等）**。

### 1. 配置 Multer

```typescript
// ✅ 使用内存存储，便于上传到对象存储
import { memoryStorage } from 'multer'

MulterModule.register({
  storage: memoryStorage(),  // 关键：使用内存存储，不保存到本地磁盘
  limits: { fileSize: 5 * 1024 * 1024 }
})
```

### 2. 上传图片到对象存储并生成 URL

```typescript
// ✅ 上传到对象存储并获取可访问的 URL
let imageUrl: string

// 如果是新上传的文件，上传到对象存储
if (file && file.buffer) {
  // ⚠️ CRITICAL: 必须显式调用 storage.upload() 将文件上传到对象存储
  // 否则文件只存在于内存或本地磁盘，无法持久化和跨环境访问
  const fileKey = await this.storage.upload({
    buffer: file.buffer,
    filename: file.originalname,
    mimetype: file.mimetype
  })

  // 生成公开可访问的 URL（确保 URL 指向对象存储而不是本地路径）
  imageUrl = await this.storage.getPublicUrl(fileKey)
}
// 如果是已存储的文件，直接获取 URL
else if (photo.imageKey) {
  imageUrl = await this.storage.getPublicUrl(photo.imageKey)
}
else {
  throw new Error('无法获取图片')
}

// 调用大模型进行图片分析（直接使用 URL）
const response = await this.aiClient.analyzeImage({
  prompt: '请描述这张图片的内容',
  imageUrl: imageUrl,
  model: 'gpt-4-vision-preview',
})
```

### 3. 完整的图片上传与 AI 分析 Controller 示例

```typescript
@Post('analyze')
@HttpCode(200)
@UseInterceptors(FileInterceptor('file'))
async analyzeImage(@UploadedFile() file: Express.Multer.File) {
  console.log('文件大小:', file.buffer.length)
  console.log('文件类型:', file.mimetype)

  // 1. 上传到对象存储
  const fileKey = await this.storageService.upload({
    buffer: file.buffer,
    filename: file.originalname,
    mimetype: file.mimetype
  })

  // 2. 生成公开可访问的 URL
  const imageUrl = await this.storageService.getPublicUrl(fileKey)

  // 3. 调用大模型分析图片
  const analysis = await this.aiService.analyzeImage({
    imageUrl: imageUrl,
    prompt: '请分析这张图片'
  })

  return {
    code: 200,
    msg: 'success',
    data: {
      fileKey,
      imageUrl,
      analysis
    }
  }
}
```

### 关键检查点

- [ ] 文件已上传到对象存储（S3/OSS 等）
- [ ] ⚠️ **确认文件不是只保存在本地服务器**：检查代码中是否调用了 `storage.upload()` 将文件上传到对象存储
- [ ] 生成的 URL 可公开访问（或临时签名 URL 有效期足够长）
- [ ] URL 格式正确（https://...）
- [ ] 大模型能够访问该 URL（检查网络和权限）
- [ ] 添加适当的错误处理和日志输出

### 常见错误排查

**图片上传到大模型常见错误**：

- **大模型无法访问图片**
  - 原因：URL 不可公开访问
  - 解决方案：设置对象存储为公开读取或使用签名 URL

- **大模型返回 "invalid url"**
  - 原因：URL 格式错误或已过期
  - 解决方案：检查 URL 格式和有效期

- **文件上传失败**
  - 原因：对象存储配置错误
  - 解决方案：检查 Access Key、Secret Key 和 Bucket

- **file.buffer is undefined**
  - 原因：Multer 未使用 memoryStorage
  - 解决方案：改用 `storage: memoryStorage()`

- **⚠️ 文件只在本地而未上传到对象存储**
  - 原因：使用 diskStorage 或未调用上传方法
  - 解决方案：使用 memoryStorage + 显式调用 `storage.upload()`

### 配置选择指南

- **图片 → 大模型 AI 分析**：`memoryStorage()` + 对象存储，数据传递：图片 URL（本章规范，上传到对象存储后传递 URL）
- **普通文件上传（仅存储）**：双模式（见第三节），数据传递：file.path + file.buffer（跨端兼容，小程序用 path，H5 用 buffer）
- **大文件（>10MB）**：`diskStorage()` 或流式上传，数据传递：file.path（避免内存占用过高）

**重要提示**:
- 对于大模型图片分析，**推荐使用 URL 方式**，避免传输大量数据
- 确保对象存储的图片 URL 可公开访问，或使用足够有效期的签名 URL（建议 1 小时以上）

---

## 五、录音功能常见错误 (CRITICAL)

**录音功能常见错误及解决方案**：

- **🔴 Web 端白屏（录音页）**
  - 错误代码示例：Text 未添加 `block` 类 + 平台检测使用 useState
  - 正确做法：所有 Text 添加 `block` + 直接判断平台 `const isWeapp = Taro.getEnv() === WEAPP`

- **H5 端 getRecorderManager is not defined**
  - 错误代码示例：直接调用 `Taro.getRecorderManager()`
  - 正确做法：在 `useEffect` 中检测平台后初始化

- **小程序端录音无响应**
  - 错误代码示例：未监听 `onStart`/`onStop` 事件
  - 正确做法：必须在初始化时绑定事件监听

- **录音文件上传失败**
  - 错误代码示例：未获取 `tempFilePath`
  - 正确做法：在 `onStop` 回调中获取 `res.tempFilePath`

- **H5 端按钮点击报错**
  - 错误代码示例：未在按钮点击时检测平台
  - 正确做法：按钮点击前再次检测 `isWeapp`

**错误示例**:
```typescript
// ❌ 错误 1：Web 端白屏 - Text 未添加 block 类
<Text className="text-lg font-semibold">录音标题</Text>
<Text className="text-sm text-gray-500">00:00 / 01:30</Text>

// ❌ 错误 2：Web 端白屏 - 平台检测使用 useState 导致状态延迟
const [isWeapp, setIsWeapp] = useState(false)
useEffect(() => {
  setIsWeapp(Taro.getEnv() === Taro.ENV_TYPE.WEAPP)
}, [])

// ❌ 错误 3：直接调用，H5 端会报错
const recorderManager = Taro.getRecorderManager()

// ❌ 错误 4：未检测平台
const handleStartRecord = () => {
  recorderManager.start({ format: 'mp3' })
}
```

**正确示例**:
```typescript
// ✅ 正确 1：Text 添加 block 类，避免 Web 端白屏
<Text className="block text-lg font-semibold">录音标题</Text>
<Text className="block text-sm text-gray-500">00:00 / 01:30</Text>

// ✅ 正确 2：平台检测直接判断，避免状态延迟
const isWeapp = Taro.getEnv() === Taro.ENV_TYPE.WEAPP

// ✅ 正确 3：在 useEffect 中检测平台后初始化
const [recorderManager, setRecorderManager] = useState<Taro.RecorderManager | null>(null)

useEffect(() => {
  if (isWeapp) {
    const manager = Taro.getRecorderManager()
    manager.onStop((res) => {
      console.log('录音文件路径:', res.tempFilePath)
    })
    setRecorderManager(manager)
  }
}, [isWeapp])

// ✅ 正确 4：按钮点击时再次检测平台
const handleStartRecord = () => {
  if (!isWeapp) {
    Taro.showToast({ title: 'H5端暂不支持录音', icon: 'none' })
    return
  }
  recorderManager?.start({ format: 'mp3' })
}
```

---

## 六、语音识别音频格式常见错误 (CRITICAL)

**语音识别音频格式常见错误及解决方案**：

- **🔴 ASR 错误 11103 (invalid format)**
  - 错误代码示例：使用 MP3 格式录音
  - 正确做法：改用 WAV 格式：`format: 'wav'`

- **音频采样率不符合要求**
  - 错误代码示例：使用默认采样率或 44100
  - 正确做法：设置为 16000：`sampleRate: 16000`

- **音频声道数错误**
  - 错误代码示例：使用立体声（2 声道）
  - 正确做法：设置为单声道：`numberOfChannels: 1`

- **base64 编码格式错误**
  - 错误代码示例：使用自定义编码方法或第三方库
  - 正确做法：使用 Taro 原生：`Taro.arrayBufferToBase64()`

- **后端收到空音频数据**
  - 错误代码示例：未正确读取录音文件或转换失败
  - 正确做法：验证 `tempFilePath` 有效性，打印调试信息

- **ASR 服务调用失败**
  - 错误代码示例：未处理 ASR 错误或网络异常
  - 正确做法：添加 try-catch，提供文本输入降级方案

- **前端未提供降级方案**
  - 错误代码示例：只实现语音输入，H5 或 ASR 失败时无法用
  - 正确做法：必须同时提供文本输入功能

**正确示例（语音识别音频格式）**:
```typescript
// ✅ 正确：使用 WAV 格式（ASR 兼容）
recorderManager?.start({
  format: 'wav',        // WAV 格式
  sampleRate: 16000,    // 16kHz 采样率
  numberOfChannels: 1,  // 单声道
  frameSize: 50
})

// ✅ 正确：使用 Taro 原生方法转换音频
const fileSystemManager = Taro.getFileSystemManager()
const arrayBuffer = fileSystemManager.readFileSync(audioPath)
const base64 = Taro.arrayBufferToBase64(arrayBuffer)

// ✅ 正确：后端验证音频数据
if (!audioData || audioData.length === 0) {
  throw new BadRequestException('音频数据为空')
}
console.log('音频数据长度:', audioData.length)

// ✅ 正确：提供降级方案
<Input
  placeholder="今天在全家超市买了 35 元午餐"
  value={textInput}
  onInput={(e) => setTextInput(e.detail.value)}
/>
<Button onClick={handleTextSubmit}>确认记账</Button>
```

**错误示例（语音识别音频格式）**:
```typescript
// ❌ 错误 1：使用 MP3 格式（ASR 不支持）
recorderManager?.start({
  format: 'mp3' // 导致 ASR 错误 11103
})

// ❌ 错误 2：采样率不符合要求
recorderManager?.start({
  format: 'wav',
  sampleRate: 44100 // 应该使用 16000
})

// ❌ 错误 3：使用第三方 base64 库
const base64 = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer))) // 可能导致编码问题

// ❌ 错误 4：后端未验证音频数据
@Post('recognize')
async recognize(@Body() body: { audioData: string }) {
  // 直接调用 ASR，未验证数据有效性
  return await this.asrService.recognize(body.audioData)
}

// ❌ 错误 5：未提供降级方案
// 只实现语音输入，ASR 失败时用户无法使用
```
