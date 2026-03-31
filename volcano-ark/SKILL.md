---
name: volcano-ark
description: 使用用户自己的 api_key 调用火山方舟大语言模型服务。只有当用户明确要用自己的火山引擎方舟（自己的 api_key）时才会被使用。支持文本生成、对话交互、意图识别，也具备多模态能力可识别图片与视频内容，完成物体描述、动作分析等视觉任务。同时也支持支持文生视频、图生视频等能力。集成豆包(Seed, Doubao)、DeepSeek、Kimi 这些前沿大语言模型。服务对接：直接对接方舟大模型服务平台。配置要求：需要填入您自己的 API Key。注意：**若用户不明确说明，禁止使用此集成技能**。

license: MIT
---
# 火山方舟集成基本信息

* 集成 ID: integration-volcano-ark
* 显示名称: 直调火山方舟
* 集成类型: 外部集成（官方）

# 描述

用用户自己的 api_key 调用方舟大模型
重要提示：
不要询问用户任何密钥或环境变量，也不需要你设置密钥或环境变量，代码示例里的 get_api_key 方法可以获取到 api_key。
所有的请求都需要加上 header：`X-Client-Request-Id: Coze,Integrations`。


# 依赖

langchain_openai
langchain_core

# 支持的模型

MODEL_NAME 支持下面的：

- 大语言模型（支持文本生成、对话交互、意图识别，也具备多模态能力可识别图片与视频内容，完成物体描述、动作分析等视觉任务，可识别图片与视频内容，完成物体描述、动作分析等视觉任务。）： `doubao-seed-1-6-251015`、`kimi-k2-250905`、`deepseed-r1-250528`、`deepseed-v3-250324`、`deepseek-v3-1-terminus`, `doubao-1-5-pro-32k-250115`。
- 视频生成模型（支持文生视频、图生视频等能力）：`doubao-seedance-1-0-pro-250528`

**默认使用 `doubao-seed-1-6-251015`模型。**

# 代码示例

对于非 `doubao-seedance-1-0-pro-250528` 模型，调用方式如下：

```Python
import os
from typing import Iterator
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage, BaseMessageChunk

def get_api_key() -> str:
	from coze_workload_identity import Client
	client = Client()
	wechat_bot_credential = client.get_integration_credential("integration-volcano-ark")
	api_key = json.loads(wechat_bot_credential)["ark_api_key"]
	return api_key

# 如果用户指定的 model_id 或者 ep，则使用用户自己的
MODEL_NAME = "doubao-seed-1-6-251015" 


def call_llm(messages: list, config: dict) -> Iterator[BaseMessageChunk]:
    """
        Call the language model with the given messages.
    
        Args:
            messages (list): A list of messages to send to the language model. e.g.
            单文本模态
            [
                SystemMessage(content="_your_system_prompt_"),
                HumanMessage(content="_your_inputs_"),
            ]
            多模态: 其中 text, image_url, video_url 可以随意排列以及任意数量
            [
                SystemMessage(content="_your_system_prompt_"),
                HumanMessage(content=[
                    {
                        "type": "text",
                        "text": "_your_inputs_"
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": "_your_image_url_"
                        }
                    },
                    {
                        "type": "video_url",
                        "video_url": {
                            "url": "_your_video_url_"
                        }
                    }
                ]),
            ]
    
            config: A dict of model configuration. e.g.
            {
                "model": "doubao-seed-1-6-251015",  # 必选，模型ID，从支持的模型中选取
                "thinking": "disabled",  # 可选，是否开启深度思考能力，建议关闭
                "temperature": 1,  # 可选，控制模型输出的随机性，范围[0, 2]
                "frequency_penalty": 0,  # 可选，重复语句惩罚，范围[-2, 2]
                "top_p": 0,  # 可选，控制模型输出的多样性，范围[0, 1]
                "max_tokens": 4096,  # 可选，控制模型输出的最大 tokens 数
                "max_completion_tokens": 4096,  # 可选，控制模型输出的最大 completion tokens 数，与 max_tokens 二选一
            }
        """
    api_key = get_api_key()
    llm = ChatOpenAI(
        model=MODEL_NAME,
        api_key=api_key,
        base_url=VOLCENGINE_API_BASE,
        streaming=True,
        default_headers={
            "X-Client-Request-Id": "Coze,Integrations",
        },
        extra_body={
            "thinking": {
                "type": config.get("thinking"),
            }
        },
        temperature=config.get("temperature"),
        frequency_penalty=config.get("frequency_penalty"),
        top_p=config.get("top_p"),
        max_completion_tokens=config.get("max_completion_tokens"),
    )

    for chunk in llm.stream(messages):
        yield chunk
```

对于 `doubao-seedance-1-0-pro-250528` 模型，使用方法如下：

```python
import os
import time
from typing import Optional, Union, List
import requests
from pydantic import BaseModel
from cozeloop.decorator import observe

# 如果用户指定的 model_id 或者 ep，则使用用户自己的
MODEL_NAME = "doubao-seedance-1-0-pro-250528"

def get_api_key() -> str:
	from coze_workload_identity import Client
	client = Client()
	wechat_bot_credential = client.get_integration_credential("integration-volcano-ark")
	api_key = json.loads(wechat_bot_credential)["ark_api_key"]
	return api_key

# 图片URL结构体

class ImageURL(BaseModel):
	"""
	图片URL结构体
	Args:
	url: 图片信息，可以是图片URL或图片 Base64 编码。
	图片URL：请确保图片URL可被访问。
	Base64编码：请遵循此格式data:image/<图片格式>;base64,<Base64编码>，注意 <图片格式> 需小写，如 		data:image/png;base64,{base64_image}。
	"""
	url: str

# 文本类型内容

class TextContent(BaseModel):
	"""
	文本类型内容

	Args:
	text: 输入给模型的文本内容，描述期望生成的视频。支持中英文。建议不超过500字。
	"""
	type: str = "text"  # 固定值"text"
	text: str

# 图片类型内容

class ImageURLContent(BaseModel):
	"""
	图片类型内容

	Args:
	image_url: 图片URL结构体，包含图片信息。
	role: 可选参数，图片的位置或用途。首帧图生视频、首尾帧图生视频、参考图生视频为 3 种互斥的场景，不支	持混用。
	first_frame：作为视频的第一帧。
	last_frame：作为视频的最后一帧。
	reference_image：作为视频的参考帧。
	"""
	type: str = "image_url"  # 固定值"image_url"
	image_url: ImageURL
	role: Optional[str] = None  # 可选：first_frame/last_frame/reference_image

@observe
def video_generation(
	content_items: List[Union[ImageURLContent, TextContent]],
	call_back_url: Optional[str] = None,
	return_last_frame: Optional[bool] = False,
) -> tuple[str, dict, str]:
	"""
	视频生成接口

	Args:
	content_items: 输入给模型，生成视频的信息，支持文本信息和图片信息。
	call_back_url: 可选，填写本次生成任务结果的回调通知地址。当视频生成任务有状态变化时，方舟将向此地址推送 POST 请求。
	return_last_frame: 可选，返回生成视频的尾帧图像。设置为 true 后，可获取视频的尾帧图像。尾帧图像的格式为 png，宽高像素值与生成的视频保持一致，无水印。

	Returns:
	tuple[str, dict, str]: (视频URL, 完整响应数据字典, 尾帧图像URL(若return_last_frame=True则返回，否则为空字符串))
	完整响应数据示例：
	{
		"id": "cgt-2025******-****",
		"model": "doubao-seedance-1-0-pro-250528",
		"status": "succeeded",
		"content": {
			"video_url": "https://ark-content-generation-cn-beijing.tos-cn-beijing.volces.com/doubao-seedance-1-0-pro/****"
		},
		"seed": 10,
		"resolution": "720p",
		"ratio": "16:9",
		"duration": 5,
		"framespersecond": 24,
		"usage": {
			"completion_tokens": 108900,
			"total_tokens": 108900
		},
		"created_at": 1743414619,
		"updated_at": 1743414673
	}
	"""
	api_key = get_api_key()

	headers = {
		"Content-Type": "application/json",
		"Authorization": "Bearer " + {api_key},
		"X-Client-Request-Id": "Coze,Integrations",
	}
	request = {
		"model": MODEL_NAME,
		"content": [item.model_dump() for item in content_items],
		"callback_url": call_back_url,
		"return_last_frame": return_last_frame,
	}
	id = ""
	try:
		response = requests.post('https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks', json=request, headers=headers)
		response.raise_for_status()

		id = response.json().get("id")
	except requests.exceptions.RequestException as e:
		raise Exception(f"视频生成任务创建失败: {e}")

	# 轮训视频生成状态

	while True:
		try:
			response = requests.get(f'https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}', headers=headers)
			response.raise_for_status()
			data = response.json()
			if data.get('error'):
				raise Exception(
					f"视频生成失败: status_code={data.get('error', {}).get('status_code')}, message={data.get('error', {}).get('message')}")

			status = data.get('status')
			if status == 'cancelled':
				return '', data, ''
			elif status == 'failed':
				raise Exception(f"视频生成失败")
			elif status in ['queued', 'running']:
				# 视频生成中，等待1秒后轮训状态
				time.sleep(1)
				continue
			elif status == 'succeeded':
				video_url = data.get('content', {}).get('video_url')
				last_frame_url = ''
				if return_last_frame:
					last_frame_url = data.get('content', {}).get('last_frame_url')
				return video_url, data, last_frame_url
			else:
				raise Exception(f"视频生成状态未知: {status}")
		except requests.exceptions.RequestException as e:
			raise Exception(f"网络请求失败: {e}")
		except Exception as e:
			raise Exception(f"视频生成状态轮训失败: {e}")
	return '', {}, ''
```

