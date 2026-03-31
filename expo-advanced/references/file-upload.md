# 文件上传与处理规范

本文档涵盖前端页面间文件传递、前端上传文件到后端的完整规范。

## 1. 文件传输总则

**前端上传文件到后端**：必须使用 FormData，后端通过 multer 接收得到 buffer。

**后端处理文件的方式**（根据下游需求选择）：

| 下游需求 | 后端处理方式 | 返回给前端 |
|----------|-------------|-----------|
| 前端播放/展示、第三方 API 要求 URL | 上传到对象存储 | 公网签名 URL |
| 后续接口需要引用该文件 | 上传到对象存储 | 对象存储 key |
| 部分第三方 API 要求 Base64 | `buffer.toString('base64')` 转换 | 处理结果 |
| 部分第三方 API 要求二进制 | 直接使用 buffer | 处理结果 |

**禁止行为**：
- 禁止前端通过 JSON body 传递 Base64（应使用 FormData）
- 禁止服务端 http 接口定义本地 URI 参数，本地 URI 只在客户端有效，服务端无法访问。解决方案：引用已上传文件时，必须使用服务端返回的对象存储 key、公网 URL 或对象 ID（数据库中的记录 ID，前提是通过该 ID 可定位到对应文件）

## 2. 前端页面间传递文件（使用 URI）

**适用场景**：**前端页面间**需要传递图片、文件或其他大体积数据时。

> ⚠️ **注意**：本规则仅适用于**前端页面间的文件传递**，不适用于前后端接口通信。

**问题**：通过路由参数传递 Base64 会导致跳转卡顿、内存占用高、可能超出 URL 长度限制。

**✅ 正确做法**：通过前端路由参数传递文件 URI（轻量级字符串），目标页面直接使用 URI 进行后续处理。

```tsx
const photo = await cameraRef.current.takePictureAsync({ quality: 0.8, base64: false });
router.push({ pathname: '/result', params: { imageUri: photo.uri } });
```

**⚠️ 禁止行为**：禁止通过路由参数传递 Base64 字符串（如 `params: { imageData: 'data:image/jpeg;base64,...' }`），会导致页面跳转极慢。

## 3. 前端上传文件到后端（使用 FormData）

**适用场景**：需要将图片、音频等文件上传到后端 API 时。

> ⚠️ **为什么必须使用 FormData？** Base64 体积增加 33%、易超 Express 100KB 限制、内存效率低。

### 前端实现

**必须**使用 `createFormDataFile` 函数（已内置于 `client/utils/index.ts`，支持跨平台兼容），**禁止**手动构造文件对象。

```tsx
import { createFormDataFile } from '@/utils';  // 已内置，直接导入使用

const formData = new FormData();

// ✅ 使用 createFormDataFile 创建跨平台兼容的文件对象（Web 返回 File，移动端返回 { uri, type, name }）
// 参数：fileUri（来自 expo-image-picker、expo-camera 等返回的 uri）, fileName（上传文件名）, mimeType（MIME 类型）
const file = await createFormDataFile(imageUri, 'photo.jpg', 'image/jpeg');
formData.append('file', file as any); // 注意这里字段名称要与后端一致

// 可继续添加其他字段
formData.append('description', 'My photo');

// ✅ 发送请求，不要设置 Content-Type
await fetch(`${API_URL}/api/v1/upload`, {
  method: 'POST',
  body: formData
});
```

### 后端实现（Express + multer）

```typescript
import multer from 'multer';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 50 * 1024 * 1024 }  // 限制 50MB
});

app.post('/api/v1/upload', upload.single('file'), async (req, res) => {
  const { buffer, originalname, mimetype, size } = req.file!;

  // ✅ buffer 即为文件二进制内容，可直接用于：上传到对象存储、图片处理、传递给第三方 API
  const signedUrl = await objectStorage.upload(buffer, originalname, mimetype);
  
  // ✅ 若下游/第三方接口明确要求 Base64：在服务端从 buffer 转换
  // const base64 = buffer.toString('base64');
  // const dataUrl = `data:${mimetype};base64,${base64}`;

  // ✅ 返回对象存储的签名 URL
  res.json({ success: true, url: signedUrl });
});

// 错误处理中间件（放在路由之后）
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: '文件大小超过限制（最大 50MB）' });
  }
  next(err);
});
```

## 禁止事项汇总

| 禁止行为 | 正确做法 |
|----------|---------|
| 手动构造 `{ uri, type, name }` 文件对象 | 使用 `createFormDataFile` 函数 |
| 通过 JSON body 传递 Base64 字符串 | 使用 FormData 上传 |
| 手动设置 `Content-Type: multipart/form-data` | 让浏览器/RN 自动处理 |
| 后端从 `req.body` 读取文件 | 使用 multer + `req.file` |
| 后端返回本地文件路径 | 返回对象存储的签名 URL |
| 前端页面间传递 Base64 | 传递 URI 字符串 |
| 服务端接口定义本地 URI 参数 | 使用对象存储 key / 公网 URL / 对象 ID |