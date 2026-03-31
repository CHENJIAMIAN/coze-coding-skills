---
name: websocket-guide
description: 在 Web 项目中集成 WebSocket 实时数据通信的指南。所有服务（HTTP + WS）共用单一端口（5000），WebSocket 路径统一使用 /ws/* 前缀。支持 Next.js 和纯 Node.js 项目，使用 TypeScript。适用场景：(1) 为 Web 项目添加 WebSocket 或实时通信功能，(2) 创建 WS 服务端或客户端连接，(3) 将 ws 库集成到现有 HTTP 服务器，(4) 搭建实时数据推送/拉取，(5) 任何涉及 WebSocket、ws、实时消息、实时数据的 Web 项目场景。
---

# WebSocket 集成指南

在 Web 项目中集成 WebSocket 实时通信。HTTP 与 WS 共用 5000 端口，WS 路径统一在 `/ws/*` 下。

## 核心约束

- **单端口**：所有 HTTP 和 WebSocket 流量共用 **5000** 端口
- **路径前缀**：所有 WebSocket 端点使用 `/ws/{feature}` 路径
- **语言**：仅 TypeScript
- **WS 库**：使用 `ws` npm 包（不用 socket.io）
- **消息格式**：JSON `{ type: string, payload: unknown }`
- **生产部署**: 确保在dev环境和生产环境都的编译和启动脚本的正确性

## 框架选择

先判断项目类型，再决定实施方式：

| 项目类型 | 判断依据 | 实施方式 |
|---|---|---|
| **Next.js** | 存在 `next.config.*` | [references/nextjs.md](references/nextjs.md) |
| **Node.js** | Express/Fastify 服务器，不属于以上框架, 比如vite、原生html/js/css | [references/nodejs.md](references/nodejs.md) |
| **其他已有框架** | 存量项目已使用 Koa/Hapi/Nest 等框架 | 沿用项目现有框架，参考本文通用模式集成 |

> **存量项目原则**：如果项目已经使用了其他后端框架（如 Koa、Fastify、NestJS 等），**不要引入 Express**，直接基于现有框架集成 WebSocket。核心步骤相同：获取底层 `http.Server` 实例 → 监听 `upgrade` 事件 → 使用 `ws` 库的 `noServer` 模式路由连接。

> **Vite 项目说明**：Vite 的开发服务器热更新（HMR）运行在 6000 端口，不会与 WS 服务的 5000 端口冲突，无需特殊处理。

仅阅读**匹配的**参考文档后再开始实施。对于存量项目，直接参考下方通用模式。

## 通用模式

### 消息协议

所有 WebSocket 消息使用以下结构：

```typescript
interface WsMessage<T = unknown> {
  type: string;
  payload: T;
}

// 发送
ws.send(JSON.stringify({ type: 'cursor:move', payload: { x: 10, y: 20 } }));

// 接收
ws.on('message', (raw: string) => {
  const msg: WsMessage = JSON.parse(raw);
  switch (msg.type) {
    case 'data:update': /* 处理 */ break;
  }
});
```

### 服务端路径路由

通过 HTTP upgrade 请求的 `url` 分发到不同的处理器：

```typescript
import { WebSocketServer } from 'ws';
import type { IncomingMessage } from 'http';
import type { Duplex } from 'stream';

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
  } else {
    socket.destroy();
  }
}
```

### 客户端连接工具

```typescript
interface WsOptions {
  path: string;           // 例如 '/ws/data'
  onMessage: (msg: WsMessage) => void;
  onOpen?: () => void;
  onClose?: () => void;
  reconnect?: boolean;    // 默认: true
  heartbeatMs?: number;   // 默认: 30000
}

function createWsConnection(opts: WsOptions): { send: (msg: WsMessage) => void; close: () => void } {
  const { path, onMessage, onOpen, onClose, reconnect = true, heartbeatMs = 30000 } = opts;
  let ws: WebSocket;
  let heartbeatTimer: ReturnType<typeof setInterval>;
  let closed = false;

  function connect() {
    const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    ws = new WebSocket(`${protocol}//${location.host}${path}`);

    ws.onopen = () => {
      heartbeatTimer = setInterval(() => ws.send(JSON.stringify({ type: 'ping', payload: null })), heartbeatMs);
      onOpen?.();
    };

    ws.onmessage = (e) => {
      const msg: WsMessage = JSON.parse(e.data);
      if (msg.type === 'pong') return;
      onMessage(msg);
    };

    ws.onclose = () => {
      clearInterval(heartbeatTimer);
      onClose?.();
      if (reconnect && !closed) setTimeout(connect, 1000);
    };
  }

  connect();

  return {
    send: (msg) => ws.readyState === WebSocket.OPEN && ws.send(JSON.stringify(msg)),
    close: () => { closed = true; ws.close(); },
  };
}
```

### 心跳机制（服务端）

```typescript
wss.on('connection', (ws) => {
  let alive = true;
  ws.on('message', (raw: string) => {
    const msg: WsMessage = JSON.parse(raw);
    if (msg.type === 'ping') {
      ws.send(JSON.stringify({ type: 'pong', payload: null }));
      return;
    }
    // 处理其他消息
  });

  const interval = setInterval(() => {
    if (!alive) return ws.terminate();
    alive = false;
    ws.ping();
  }, 30000);

  ws.on('pong', () => { alive = true; });
  ws.on('close', () => clearInterval(interval));
});
```

### 路径命名规范

| 格式 | 示例 | 用途 |
|---|---|---|
| `/ws/data` | 实时数据流 | 主数据通道 |
| `/ws/notifications` | 推送通知 | 告警/事件通道 |
| `/ws/{feature}` | `/ws/collab`、`/ws/chat` | 功能专属通道 |

## 依赖安装

开始前先安装：

```bash
pnpm install ws
pnpm install -D @types/ws
```

## 完成检查清单

集成完成前，验证以下各项：

1. HTTP 服务器和 WS 服务器共用 5000 端口
2. 所有 WS 端点在 `/ws/*` 路径下
3. 消息遵循 `{ type, payload }` 格式
4. 已实现心跳和重连机制
5. 连接错误得到妥善处理
6. ✅ **构建脚本 (`scripts/build.sh`) 已更新**：后端代码如有新增，确认构建命令包含编译
7. ✅ **启动脚本 (`scripts/start.sh`) 已更新**：同时启动前端和后端服务
8. ✅ **`.coze` 配置已确认**：`[deploy]` 的 build/run 命令正确
