# Node.js（Express + Vite）WebSocket 集成

## 概述

Express HTTP 服务器搭配 `ws` 处理 upgrade，共用 5000 端口。前端使用 Vite 构建，开发环境通过 Vite middleware 模式集成，生产环境由 Express 托管 Vite 构建产物。

Vite 的 HMR WebSocket 运行在独立端口（默认 6000），不与 5000 端口冲突，无需特殊处理。

## 项目结构

```
project/
├── server/
│   ├── server.ts          # Express + Vite + WS 服务器入口
│   ├── ws/
│   │   ├── index.ts       # WS 路由注册 + upgrade 处理
│   │   └── data.ts        # /ws/data 端点处理器
│   └── routes/
│       └── api.ts         # HTTP API 路由
├── src/                   # Vite 前端源码
│   ├── main.ts            # 前端入口
│   └── lib/
│       └── ws-client.ts   # 浏览器端 WS 客户端工具
├── index.html             # Vite 入口 HTML
├── vite.config.ts
├── package.json
└── tsconfig.json
```

## 服务入口（`server/server.ts`）
如果项目中已经有了，重点关注增加websocket逻辑, 其他如生产环境托管产物、开发环境热更新等如果原来有就保持，没有就就增加

```typescript
import express from 'express';
import { createServer } from 'http';
import path from 'path';
import { setupWsEndpoints, handleUpgrade } from './ws';
import apiRoutes from './routes/api';

const dev = process.env.COZE_PROJECT_ENV !== 'PROD';
const PORT = 5000;

const app = express();
const server = createServer(app);

app.use(express.json());
app.use('/api', apiRoutes); // 注册 API 路由

// 设置 WebSocket, **重点关注这边**
setupWsEndpoints();
server.on('upgrade', handleUpgrade);

async function start() {
  if (dev) {
    // 开发环境：Vite middleware 模式，HMR + 热更新
    // 读取项目 vite.config.ts 中的 HMR 端口配置，若未配置则默认 6000
    const { createServer: createViteServer, loadConfigFromFile, mergeConfig } = await import('vite');
    const loaded = await loadConfigFromFile({ command: 'serve', mode: 'development' });
    const existingHmrPort = loaded?.config?.server?.hmr && typeof loaded.config.server.hmr === 'object'
      ? loaded.config.server.hmr.port
      : undefined;
    const vite = await createViteServer(mergeConfig(loaded?.config ?? {}, {
      server: { middlewareMode: true, hmr: { port: existingHmrPort ?? 6000 } },
    }));
    app.use(vite.middlewares);
  } else {
    // 生产环境：托管 Vite 构建产物
    const distPath = path.resolve(process.cwd(), 'dist');
    app.use(express.static(distPath));
    // SPA fallback：所有未匹配路由返回 index.html（Express 5 使用 {*path} 语法）
    app.get('{*path}', (_req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  server.listen(PORT, () => {
    console.log(`> 服务就绪：http://localhost:${PORT} (${dev ? 'dev' : 'prod'})`);
  });
}

start();
```

## WS 路由注册（`server/ws/index.ts`）

```typescript
import { WebSocketServer } from 'ws';
import type { IncomingMessage } from 'http';
import type { Duplex } from 'stream';
import { setupDataEndpoint } from './data';

export interface WsMessage<T = unknown> {
  type: string;
  payload: T;
}

const endpoints = new Map<string, WebSocketServer>();

export function createEndpoint(path: string): WebSocketServer {
  const wss = new WebSocketServer({ noServer: true });
  endpoints.set(path, wss);
  return wss;
}

export function handleUpgrade(req: IncomingMessage, socket: Duplex, head: Buffer) {
  const { pathname } = new URL(req.url!, `http://${req.headers.host}`);
  const wss = endpoints.get(pathname);
  if (wss) {
    wss.handleUpgrade(req, socket, head, (ws) => wss.emit('connection', ws, req));
  } else {
    // 未注册的路径直接销毁，防止连接泄漏
    socket.destroy();
  }
}

export function setupWsEndpoints() {
  setupDataEndpoint();
  // 添加更多：setupChatEndpoint()、setupNotifyEndpoint() 等
}
```

## 端点处理器示例（`server/ws/data.ts`）

```typescript
import type { WebSocket } from 'ws';
import { createEndpoint, type WsMessage } from './index';

export function setupDataEndpoint() {
  const wss = createEndpoint('/ws/data');

  wss.on('connection', (ws: WebSocket) => {
    console.log('客户端已连接到 /ws/data');

    ws.on('message', (raw) => {
      const msg: WsMessage = JSON.parse(raw.toString());

      if (msg.type === 'ping') {
        ws.send(JSON.stringify({ type: 'pong', payload: null }));
        return;
      }

      // 回显示例
      ws.send(JSON.stringify({ type: 'data:ack', payload: msg.payload }));
    });

    // 心跳
    let alive = true;
    const interval = setInterval(() => {
      if (!alive) return ws.terminate();
      alive = false;
      ws.ping();
    }, 30000);

    ws.on('pong', () => { alive = true; });
    ws.on('close', () => clearInterval(interval));
  });

  return wss;
}
```

## 新增端点

添加新 WS 端点（如 `/ws/chat`）：

1. 创建 `server/ws/chat.ts`：

```typescript
import { WebSocket } from 'ws';
import { createEndpoint, type WsMessage } from './index';

export function setupChatEndpoint() {
  const wss = createEndpoint('/ws/chat');

  const clients = new Set<WebSocket>();

  wss.on('connection', (ws: WebSocket) => {
    clients.add(ws);

    ws.on('message', (raw) => {
      const msg: WsMessage = JSON.parse(raw.toString());
      if (msg.type === 'ping') {
        ws.send(JSON.stringify({ type: 'pong', payload: null }));
        return;
      }
      // 广播给所有客户端
      for (const client of clients) {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(raw.toString());
        }
      }
    });

    ws.on('close', () => clients.delete(ws));
  });
}
```

> **注意**：`WebSocket` 必须作为**值导入**（不能用 `import type`），因为 `WebSocket.OPEN` / `WebSocket.CLOSED` 等常量是运行时值。

2. 在 `server/ws/index.ts` 中注册：

```typescript
import { setupChatEndpoint } from './chat';

export function setupWsEndpoints() {
  setupDataEndpoint();
  setupChatEndpoint();  // 在此添加
}
```

## 脚本命令

开发环境使用 `tsx watch` 直接运行 TypeScript（Vite 以 middleware 模式内嵌），生产环境分两步构建：

- dev: npx tsx watch server/server.ts
- build: npx vite build && npx tsup server/server.ts --format cjs --platform node --target node20 --outDir dist-server --no-splitting --no-minify --external vite
- start: node dist-server/server.js

> **构建说明**：`vite build` 将前端编译到 `dist/`，`tsup` 将服务端编译到 `dist-server/`。生产环境 Express 通过 `express.static` 托管 `dist/` 下的前端产物。

## 依赖安装

- 运行时依赖：`npm install express ws`
- 开发/构建依赖：`npm install -D vite typescript tsx tsup @types/express @types/ws`

## tsconfig.json

`include` 必须同时包含 `src` 和 `server` 目录，`exclude` 必须排除编译产物目录：

```json
{
  "include": ["src", "server"],
  "exclude": ["node_modules", "dist", "dist-server"]
}
```

⚠️ 生产环境必须修改的文件：

- .coze 文件：确认 [deploy] 配置正确
- scripts/build.sh：确保前端和后端构建命令都正确
- scripts/start.sh：确保启动服务

后端代码如有变更，必须同步更新上述文件！

## 注意事项

- **开发环境**：Vite 以 middleware 模式嵌入 Express，HMR WebSocket 运行在 6000 端口，不与业务 WS（5000 端口 `/ws/*`）冲突
- **生产环境**：Express 托管 `dist/` 下的 Vite 构建产物，SPA 路由通过 fallback 到 `index.html` 实现
- **静态文件路径**：生产环境使用 `process.cwd()` 而非 `__dirname`，因为 tsup 编译后 `__dirname` 指向 `dist-server/`，相对路径会错
- **`noServer: true` 是必需的** —— 让 Express 拥有 HTTP 服务器，`ws` 负责 upgrade 路由
- 每个 WS 端点是 `server/ws/` 下的独立文件，结构清晰
- 必须使用 `createServer(app)` 而非 `app.listen()` —— 需要原始的 `http.Server` 实例来监听 `upgrade` 事件
