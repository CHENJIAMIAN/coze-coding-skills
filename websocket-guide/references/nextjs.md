# Next.js WebSocket 集成

## 概述

Next.js 的开发/生产服务器原生不支持 WebSocket。需要使用 **自定义服务器**（`src/server.ts`），在 5000 端口同时运行 Next.js 和 WebSocket。

## 项目结构

```
project/
├── src/
│   ├── server.ts          # 自定义服务器（HTTP + WS 共用 5000 端口）
│   ├── app/               # Next.js App Router 页面
│   ├── ws-handlers/       # WS 端点业务逻辑（每个端点一个文件）
│   │   └── data.ts        # /ws/data 端点处理器示例
│   └── lib/
│       └── ws-client.ts   # 客户端 WS 工具
├── next.config.ts
└── package.json
```

## 自定义服务器（`src/server.ts`）

```typescript
import { createServer } from 'http';
import { parse } from 'url';
import next from 'next';
import { WebSocketServer } from 'ws';
import type { IncomingMessage } from 'http';
import type { Duplex } from 'stream';

const dev = process.env.COZE_PROJECT_ENV !== 'PROD';
const hostname = process.env.HOSTNAME || 'localhost';
const PORT = 5000;

// Create Next.js app
const app = next({ dev, hostname, port });
const handle = app.getRequestHandler();

// ─── WS 路由注册（与 SKILL.md 通用模式一致）────────
const wssMap = new Map<string, WebSocketServer>();

function registerWsEndpoint(path: string): WebSocketServer {
  const wss = new WebSocketServer({ noServer: true });
  wssMap.set(path, wss);
  return wss;
}

function handleUpgrade(req: IncomingMessage, socket: Duplex, head: Buffer) {
  const { pathname } = new URL(req.url!, `http://${req.headers.host}`);
  const wss = wssMap.get(pathname);
  if (wss) {
    wss.handleUpgrade(req, socket, head, (ws) => wss.emit('connection', ws, req));
  } else if (!dev) {
    // 生产环境销毁未注册的 upgrade 请求，防止连接泄漏
    // 开发环境不销毁 —— Next.js HMR 需要通过 /_next/webpack-hmr 建立 WebSocket
    socket.destroy();
  }
}

// ─── 注册端点 & 绑定业务逻辑 ──────────────────────
// 按需注册 WS 端点，每个端点的消息处理逻辑放在 src/ws-handlers/ 下
// 示例:
//   import { setupDataHandler } from './ws-handlers/data';
//   setupDataHandler(registerWsEndpoint('/ws/data'));

app.prepare().then(() => {
  const server = createServer(async (req, res) => {
    try {
      const parsedUrl = parse(req.url!, true);
      await handle(req, res, parsedUrl);
    } catch (err) {
      console.error('Error occurred handling', req.url, err);
      res.statusCode = 500;
      res.end('Internal server error');
    }
  });
  server.once('error', err => {
    console.error(err);
    process.exit(1);
  });

  server.on('upgrade', handleUpgrade);

  server.listen(port, () => {
    console.log(
      `> Server listening at http://${hostname}:${port} as ${
        dev ? 'development' : process.env.COZE_PROJECT_ENV
      }`,
    );
  });
});
```

### WS 端点处理器示例（`src/ws-handlers/data.ts`）

业务逻辑独立于 `src/server.ts`，每个端点一个文件：

```typescript
import { WebSocket, type WebSocketServer } from 'ws';
import type { WsMessage } from '../lib/ws-client';

export function setupDataHandler(wss: WebSocketServer) {
  wss.on('connection', (ws: WebSocket) => {
    ws.on('message', (raw) => {
      const msg: WsMessage = JSON.parse(raw.toString());
      if (msg.type === 'ping') {
        ws.send(JSON.stringify({ type: 'pong', payload: null }));
        return;
      }
      // TODO: 在此实现 /ws/data 端点的业务消息处理逻辑
    });
  });
}
```

> **注意**：`WebSocket` 必须作为**值导入**（不能用 `import type`），因为 `WebSocket.OPEN` / `WebSocket.CLOSED` 等常量是运行时值。`WebSocketServer` 仅用作类型标注，可以用 `type` 导入。

## 依赖安装

安装依赖：`pnpm install ws` 和 `pnpm install -D @types/ws tsup`

## 脚本命令

- dev: "npx tsx watch src/server.ts"
- build: "npx next build && npx tsup src/server.ts --format cjs --platform node --target node20 --outDir dist --no-splitting --no-minify"
- start: "node dist/server.js"

检查对应脚本是否按照如上命令正确设置.

## tsconfig.json

tsup 编译产物输出到项目根目录 `dist/`，而 `tsconfig.json` 的 `include` 通常包含 `**/*.ts`，会匹配到 `dist/` 下的文件导致类型检查冲突。必须确保 `tsconfig.json` 的 `exclude` 中包含 `"dist"`：

```json
{
  "exclude": ["node_modules", "dist"]
}
``` 


## 客户端使用（React 组件）

```typescript
'use client';

import { useEffect, useRef, useCallback } from 'react';
import { createWsConnection, type WsMessage } from '@/lib/ws-client';

export function useWebSocket(path: string, onMessage: (msg: WsMessage) => void) {
  const connRef = useRef<ReturnType<typeof createWsConnection>>();

  useEffect(() => {
    connRef.current = createWsConnection({ path, onMessage });
    return () => connRef.current?.close();
  }, [path]);

  const send = useCallback((msg: WsMessage) => {
    connRef.current?.send(msg);
  }, []);

  return { send };
}
```

## 注意事项

- **不能使用 `next dev`** —— 开发环境必须通过 `npx tsx watch src/server.ts` 启动
- 自定义服务器包装了 Next.js 的请求处理器，所有 Next.js 功能（API Routes、SSR 等）正常工作
- 生产环境通过 tsup 编译 `src/server.ts` 到 `dist/server.js`
- WebSocketServer 必须设置 `noServer: true` —— 由 HTTP 服务器手动处理 upgrade 事件
- **`handleUpgrade` 中未匹配路径的处理**：开发环境不能调用 `socket.destroy()`（Next.js HMR 通过 `/_next/webpack-hmr` WebSocket 连接实现热更新），生产环境应销毁未注册的连接防止泄漏
- Next.js 的 HMR 内部使用自己的 WebSocket，`/ws/*` 前缀可避免路径冲突
