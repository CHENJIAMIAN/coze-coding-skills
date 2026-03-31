---
name: feishu-message
description: 飞书消息集成, 使用飞书自定义机器人 webhook 发送消息。支持发送文本消息、富文本消息以及卡片消息。
license: MIT
---
# 飞书消息集成基本信息

通过 webhook 发送飞书机器人消息

# 描述

支持发送文本消息、富文本消息以及卡片消息

重要提示：
不要询问用户任何密钥或环境变量，也不需要你设置密钥或环境变量

## 安装依赖

pip install requests

## 基本使用

import requests
import json
import os
import  json

### 获取 webhook_url

```Python
def get_webhook_url() -> str:
	from coze_workload_identity import Client
	client = Client()
	wechat_bot_credential = client.get_integration_credential("integration-feishu-message")
	webhook_key = json.loads(wechat_bot_credential)["webhook_url"]
	return webhook_url
```

### 1. 通过 Webhook 发送消息

```Python
def send_text_message(text):
    payload = {"msg_type": "text", "content": {"text": text}}

    response = requests.post(get_webhook_url(), json=payload)
    return response.json()
    send_text_message("Hello!")


send_text_message("Hello!")
```

支持 `@` 用户功能：

payload 为

```json
{
  "msg_type": "text",
  "content": {
    "text": "<at user_id=\"ou_xxxxx\">@用户名</at> 你好"
  }
}
```

### 2. 发送富文本消息

```Python
def send_rich_text(title, content):
	payload = {
		"msg_type": "post",
		"content": {
			"post": {
				"zh_cn": {
					"title": title,
					"content": [
						[
							{"tag": "text", "text": content},
							{"tag": "a", "text": "链接文本", "href": "https://example.com"},
							{"tag": "at", "user_id": "ou_xxxxx"}  # 注意，这里不支持 img 的 tag！要发送图片直接传图片的 url 链接
						]
					]
				}
			}
		}
	}
	response = requests.post(get_webhook_url(), json=payload)
	return response.json()


send_rich_text("通知标题", "这是消息内容")
```

### 3. 发送交互式卡片

```Python
def send_card(title, content, actions):
        """
	actions 结构:
	[
  {
    "tag": "button",
    "text": {
      "content": "立即推荐好书",
      "tag": "plain_text"
    },
    "type": "primary",
    "url": "https://open.feishu.cn/"
  },
  {
    "tag": "button",
    "text": {
      "content": "查看活动指南",
      "tag": "plain_text"
    },
    "type": "default",
    "url": "https://open.feishu.cn/"
  }
]
	"""
        # 当内容是 markdown 时，tag 的值为 lark_md
	elements = [{
				"tag": "div",
				"text": {
					"tag": "plain_text",
					"content": content
				}
			}]
        if actions:
		elements.append({"tag": "action", "actions": actions})
	payload = {
		"msg_type": "interactive",
		"card": {
			"header": {
				"title": {
					"tag": "plain_text",
					"content": title
				}
			},
			"elements": elements
		}
	}	
	if actions:
		payload[""]
	response = requests.post(get_webhook_url(), json=payload)
	return response.json()

send_card("提醒", "请及时处理任务")
```