---
name: wechat-bot
description: 实现微信机器人消息推送功能。通过消息推送特有的webhookurl可实现给该群组发送消息。
license: MIT
---
# 企业微信机器人集成基本信息
* 集成 ID: integration-wechat-bot
* 显示名称: 微信机器人（企业微信版）
* 集成类型: 外部集成（官方）
# 集成描述
这是一个用于 Python 环境的企业微信机器人外部集成（官方）使用说明文档，内部适配企业微信机器人 webhook 接口规范，提供标准化的消息发送与文件上传能力。无需开发者手动配置机器人 webhook 密钥（key），密钥将从环境变量自动读取，可快速实现文本、markdown、图片、图文、文件、语音及模板卡片等七种消息类型的发送。

重要提示：
1. 不要询问用户任何密钥或环境变量，也不需要你设置密钥或环境变量，webhook_key 将通过以下方式获取。
    from coze_workload_identity import Client
    wechat_bot_credential = client.get_integration_credential("integration-wechat-bot")
    webhook_key = json.loads(wechat_bot_credential)["webhook_key"]
    if  "https" in webhook_key:
        webhook_key = re.search(r"key=([a-zA-Z0-9-]+)", webhook_key).group(1)
   
3. 为了记录API调用情况，生成的集成函数调用都需要 observe 函数装饰，observe 函数通过  from cozeloop.decorator import observe 导入

# 使用说明
-- 请参阅以下代理说明、代码片段和文档 URL（如有），了解如何使用此集成
-- 所有 API 调用需使用 HTTP POST 方法，消息发送的 Content-Type 为 application/json，文件上传为 multipart/form-data；
-- message-send（消息发送）：支持文本、markdown、图片、图文（news）、文件、语音、模板卡片（文本通知 / 图文展示）七种消息类型，需按对应格式构造请求体
-- 捕获请求异常（如网络错误、4xx/5xx 状态码), 处理各种异常情况，并记录错误详情，便于问题排查。
-- 文档URL： https://developer.work.weixin.qq.com/document/path/99110

# 代码示例
import os
import base64
import hashlib
from typing import Any, Dict, List, Optional
from coze_workload_identity import Client
from cozeloop.decorator import observe

import requests

def get_webhook_key():
  wechat_bot_credential = client.get_integration_credential("integration-wechat-bot")
  webhook_key = json.loads(wechat_bot_credential)["webhook_key"]
  if  "https" in webhook_key:
      webhook_key = re.search(r"key=([a-zA-Z0-9-]+)", webhook_key).group(1)
  return webhook_key
class WeChatRobot:
    def __init__(self):
        """
        初始化企业微信机器人客户端
        :raises ValueError: 当未提供 webhook_key 且环境变量不存在时抛出
        """
        key = webhook_key or os.getenv("WECHAT_ROBOT_WEBHOOK_KEY")
        if not key:
            raise ValueError("未配置WECHAT_ROBOT_WEBHOOK_KEY")
        self.webhook_key = get_webhook_key()
        self.send_url = f"https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key={key}"
        self.upload_url = f"https://qyapi.weixin.qq.com/cgi-bin/webhook/upload_media?key={key}"
        self._headers = {"Content-Type": "application/json"}

    def _post_json(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """
        以 JSON 形式调用 webhook 发送接口

        :param payload: 发送的消息体，需符合企业微信机器人消息格式
        :return: 企业微信返回的 JSON 对象（包含 `errcode`、`errmsg` 等）
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        r = requests.post(self.send_url, json=payload, headers=self._headers, timeout=15)
        r.raise_for_status()
        data = r.json()
        if data.get("errcode", 0) != 0:
            raise Exception(f"发送失败: {data}")
        return data

    def send_text_message(
        self,
        content: str,
        mentioned_list: Optional[List[str]] = None,
        mentioned_mobile_list: Optional[List[str]] = None,
    ) -> Dict[str, Any]:
        """
        发送文本消息（text）

        :param content: 文本内容，UTF-8 编码，最长不超过 2048 字节
        :param mentioned_list: 可选，@ 的用户 userid 列表；支持 `@all`
        :param mentioned_mobile_list: 可选，@ 的手机号列表；支持 `@all`
        :return: 企业微信返回的 JSON 对象
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        payload: Dict[str, Any] = {
            "msgtype": "text",
            "text": {
                "content": content,
            },
        }
        if mentioned_list is not None:
            payload["text"]["mentioned_list"] = mentioned_list
        if mentioned_mobile_list is not None:
            payload["text"]["mentioned_mobile_list"] = mentioned_mobile_list
        try:
            r = requests.post(self.send_url, json=payload, headers=self._headers, timeout=15)
            r.raise_for_status()
            data = r.json()
            if data.get("errcode", 0) != 0:
                raise Exception(f"发送失败: {data}")
            return data
        except Exception as e:
            raise Exception(f"文本消息发送异常: {e}")

    def send_markdown_message(self, content: str) -> Dict[str, Any]:
        """
        发送 markdown 消息

        :param content: markdown 文本，UTF-8 编码，最长不超过 4096 字节
        :return: 企业微信返回的 JSON 对象
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        payload = {
            "msgtype": "markdown",
            "markdown": {"content": content},
        }
        return self._post_json(payload)

    def send_markdown_v2_message(self, content: str) -> Dict[str, Any]:
        """
        发送 markdown_v2 消息

        :param content: markdown_v2 文本，UTF-8 编码，最长不超过 4096 字节；不支持 @ 成员与字体颜色
        :return: 企业微信返回的 JSON 对象
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        payload = {
            "msgtype": "markdown_v2",
            "markdown_v2": {"content": content},
        }
        return self._post_json(payload)

    def send_news_message(self, articles: List[Dict[str, str]]) -> Dict[str, Any]:
        """
        发送图文（news）消息

        :param articles: 文章列表，元素字典支持字段：
            - title: 标题
            - description: 描述
            - url: 跳转链接
            - picurl: 图片 URL
        :return: 企业微信返回的 JSON 对象
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        payload = {
            "msgtype": "news",
            "news": {"articles": articles},
        }
        return self._post_json(payload)

    def send_file_message(self, media_id: str) -> Dict[str, Any]:
        """
        发送文件消息（file）

        :param media_id: 通过上传接口获得的文件 `media_id`
        :return: 企业微信返回的 JSON 对象
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        payload = {
            "msgtype": "file",
            "file": {"media_id": media_id},
        }
        return self._post_json(payload)

    def send_voice_message(self, media_id: str) -> Dict[str, Any]:
        """
        发送语音消息（voice）

        :param media_id: 通过上传接口获得的语音 `media_id`
        :return: 企业微信返回的 JSON 对象
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        payload = {
            "msgtype": "voice",
            "voice": {"media_id": media_id},
        }
        return self._post_json(payload)

    def upload_file(self, file_path: str, file_type: str = "file") -> str:
        """
        上传媒体文件（本地文件）以获取 `media_id`

        :param file_path: 本地文件路径
        :param file_type: 媒体类型，默认 `file`，可为 `file` 或 `voice`
        :return: 企业微信返回的 `media_id`
        :raises FileNotFoundError: 当文件不存在时抛出
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        if not os.path.isfile(file_path):
            raise FileNotFoundError(file_path)
        url = f"{self.upload_url}&type={file_type}"
        with open(file_path, "rb") as f:
            r = requests.post(url, files={"media": f}, timeout=30)
        r.raise_for_status()
        data = r.json()
        if data.get("errcode", 0) != 0:
            raise Exception(f"文件上传失败: {data}")
        media_id = data.get("media_id")
        if not media_id:
            raise Exception(f"文件上传失败: {data}")
        return media_id

    def upload_file_by_url(self, file_url: str, file_type: str = "file") -> str:
        """
        通过 URL 下载媒体并上传，获取 `media_id`

        :param file_url: 媒体文件的可访问 URL
        :param file_type: 媒体类型，默认 `file`，可为 `file` 或 `voice`
        :return: 企业微信返回的 `media_id`
        :raises Exception: 当下载或上传请求失败、或企业微信返回错误码时抛出
        """
        get_resp = requests.get(file_url, timeout=30)
        get_resp.raise_for_status()
        content = get_resp.content
        url = f"{self.upload_url}&type={file_type}"
        r = requests.post(url, files={"media": ("file", content)}, timeout=30)
        r.raise_for_status()
        data = r.json()
        if data.get("errcode", 0) != 0:
            raise Exception(f"文件上传失败: {data}")
        media_id = data.get("media_id")
        if not media_id:
            raise Exception(f"文件上传失败: {data}")
        return media_id

    def send_image_message_by_url(self, image_url: str) -> Dict[str, Any]:
        """
        通过图片 URL 发送图片消息（image），自动转换为 `base64` 与 `md5`

        :param image_url: 图片的可访问 URL
        :return: 企业微信返回的 JSON 对象
        :raises Exception: 当图片下载失败或企业微信返回错误码时抛出
        """
        r = requests.get(image_url, timeout=30)
        r.raise_for_status()
        data = r.content
        b64 = base64.b64encode(data).decode("utf-8")
        md5 = hashlib.md5(data).hexdigest()
        payload = {
            "msgtype": "image",
            "image": {"base64": b64, "md5": md5},
        }
        return self._post_json(payload)

    def send_template_card(self, template_card: Dict[str, Any]) -> Dict[str, Any]:
        """
        发送模板卡片（template_card）消息

        :param template_card: 模板卡片内容，支持文本通知或图文展示等结构
        :return: 企业微信返回的 JSON 对象
        :raises Exception: 当 HTTP 请求或企业微信返回错误码时抛出
        """
        payload = {
            "msgtype": "template_card",
            "template_card": template_card,
        }
        return self._post_json(payload)

if __name__ == "__main__":
    robot = WeChatRobot("0e8b6efe-5284-49da-807d-a997b7553c16")
    # 发送文本消息
    robot.send_text_message("这是一条测试消息")
    # 发送图文消息
    robot.send_news_message([
        {"title": "标题1", "description": "描述1", "url": "https://www.baidu.com", "picurl": "https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png"},
        {"title": "标题2", "description": "描述2", "url": "https://www.baidu.com", "picurl": "https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png"},
    ])