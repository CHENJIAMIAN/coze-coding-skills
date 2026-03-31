---
name: wechat-official-account
description: 实现微信信公众号生成公众号草稿、查询文章数据功能。在生成草稿的时候支持上传素材，不要主动发布草稿。没有指定传入图片时候需要依赖生图大模型集成生成素材图片。
license: MIT
---

# 微信公众号集成基本信息
* 集成 ID: integration-wechat-official-account
* 显示名称: 微信公众号（企业微信版）
* 集成类型: 外部集成（官方）
  
# 集成描述

这是一个用于 Python 环境的微信公众号外部集成使用说明文档，内部适配微信公众号开放平台接口规范，提供标准化的图文消息发布、草稿管理及文章数据查询等工具能力。无需开发者手动配置应用凭证（AppID 与 AppSecret），可快速实现图文消息上传、草稿创建与发布、单篇/批量文章数据查询等核心操作，适配服务号与订阅号的主流接口场景。

**重要提示**
* 不要询问用户任何密钥或环境变量，也不需要你设置密钥或环境变量，access_token 将通过以下方式获取。
    from coze_workload_identity import Client
    access_token = client.get_integration_credential("integration-wechat-official-account")
* 为了记录API调用情况，生成的集成函数调用都需要 observe 函数装饰，observe 函数通过  from cozeloop.decorator import observe 导入
* 不要从本地读取任何文件或图片，也不要去本地写入任何文件或图片
  
# 执行流程（SOP）
**使用微信公众号集成需要严格遵循以下执行流程**
* 步骤一 生成图片 (必须)
  - 调用内置集成 **豆包生图大模型** 基于公众号的 Title 以及内容构建 Prompt 然后生成图片
* 步骤二 上传永久图片素材(必须)
  - 使用步骤 一生成的图片，通过素材上传接口获取media_id。
* 步骤三 上传图文消息图片(非必须)
  - 调用 “上传图文消息图片” 接口上传图片获取图片的 URL
* 步骤四 新增/更新草稿
  - 图文消息中的 thumb_media_id 需要传入步骤二生成的素材ID media_id
  - 图文消息如果需要图片，需要将图片链接替换为步骤三获取图片的 URL。
  - 如果步骤失败直接将错误信息抛出来，绝对不要将草稿保存在本地。
* 步骤五 发布草稿
  - 发布草稿接口需要公众号有接口权限。部分异常处理错误码信息如下
  - 48001: api 功能未授权，请确认公众号/服务号已获得该接口，可以在「公众平台官网 - 开发者中心页」中查看接口权限
  - 53503: 草稿未通过发布检查
  - 53504: 需前往公众平台官网使用草稿
  - 53505: 前往公众平台官网手动保存成功后再发表

# 使用说明
1. 除素材上传接口使用POST表单提交外，其余接口均使用GET或POST方法提交JSON格式数据；所有请求需在URL中携带access_token参数（格式：?access_token={access_token}）
2. 需针对40001（access_token无效）、45009（接口频率超限）、41001（凭证缺失）等常见错误码实现重试或告警机制, 处理各种异常情况，并记录错误详情，便于问题排查。

# 代码示例
```python
import os
import time
from typing import Any, Dict, List, Optional

import base64
import requests
import json
from coze_workload_identity import Client
from cozeloop.decorator import observe

client = Client()
# 获取微信公众号access_token
def get_access_token():
    return client.get_integration_credential("integration-wechat-official-account") 

class WeChatOfficial:
    def __init__(self):
        self.access_token = get_access_token()
    def _is_base64(self, s: str) -> bool:
        t = s.strip().replace("\n", "")
        try:
            base64.b64decode(t, validate=True)
            return True
        except Exception:
            return False

    def _prepare_media_files(self, image: Any):
        files = None
        f_to_close = None
        if isinstance(image, bytes):
            files = {"media": ("image.jpg", image)}
        elif isinstance(image, str):
            if image.startswith("http://") or image.startswith("https://"):
                resp = requests.get(image, timeout=30)
                resp.raise_for_status()
                files = {"media": ("image.jpg", resp.content)}
            elif image.startswith("data:"):
                b64 = image.split(",", 1)[1] if "," in image else ""
                data = base64.b64decode(b64)
                files = {"media": ("image.jpg", data)}
            elif self._is_base64(image):
                data = base64.b64decode(image.strip().replace("\n", ""), validate=True)
                files = {"media": ("image.jpg", data)}
            else:
                if not os.path.isfile(image):
                    raise FileNotFoundError(image)
                f_to_close = open(image, "rb")
                files = {"media": f_to_close}
        elif hasattr(image, "read"):
            name = getattr(image, "name", "image")
            files = {"media": (os.path.basename(name), image)}
        else:
            raise ValueError("不支持的图片参数类型")
        return files, f_to_close

    def generate_image_by_prompt(self, prompt: str) -> str:
        """
        生成图片
        :param prompt: 图片描述
        :return: 图片url
        """
        base_url = os.getenv("COZE_INTEGRATION_BASE_URL")
        api_key = client.get_access_token()
        headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + api_key
        }
        request = {
            "model": "doubao-seedream-4-0-250828",
            "prompt": prompt,
        }
        response = None
        try:
            response = requests.post(f'{base_url}/api/v3/images/generations', json=request, headers=headers, timeout=30)
            response.raise_for_status()
            data = response.json()
            if "error" in data:
                raise Exception(f"图片生成失败: status_code={response.status_code}, message={data['error']['message']}")
            img_list = []
            for item in data["data"]:
                if "url" in item:
                    img_list.append(item["url"])
                elif "error" in item:
                    raise Exception(f"图片生成失败: status_code={response.status_code}, message={item['error']['message']}")
            if len(img_list) == 0:
                raise Exception(f"图片生成失败: status_code={response.status_code}, message=无图片url")
            return img_list[0]
        except requests.exceptions.RequestException as e:
            raise Exception(f"网络请求失败: {e}")
        except Exception as e:
            raise Exception(f"图片生成失败: {e}")
        finally:
            try:
                if response is not None:
                    response.close()
            except Exception:
                pass
    @observe
    def upload_permanent_image(self, image: Any) -> Dict[str, Any]:
        """上传永久图片
        :param image: 图片参数，支持bytes, str, file-like object
        :return: 图片media_id, url
        """
        token = self.access_token
        url = f"https://api.weixin.qq.com/cgi-bin/material/add_material?access_token={token}&type=image"
        files, f_to_close = self._prepare_media_files(image)
        try:
            r = requests.post(url, files=files, timeout=30)
            r.raise_for_status()
            data = r.json()
        except Exception as e:
            raise Exception(f"上传永久图片异常: {e}")
        finally:
            if f_to_close:
                try:
                    f_to_close.close()
                except Exception:
                    pass
        if data.get("errcode", 0) != 0:
            raise Exception(f"上传永久图片失败: {data}")
        return {"media_id": data.get("media_id"), "url": data.get("url")}

    def upload_news_image(self, image: Any) -> str:
        """上传图文消息图片
        :param image: 图片参数，支持bytes, str, file-like object
        :return: 图片url
        """
        token = self.access_token
        url = f"https://api.weixin.qq.com/cgi-bin/media/uploadimg?access_token={token}"
        files, f_to_close = self._prepare_media_files(image)
        try:
            r = requests.post(url, files=files, timeout=30)
            r.raise_for_status()
            data = r.json()
        except Exception as e:
            raise Exception(f"上传图文消息图片异常: {e}")
        finally:
            if f_to_close:
                try:
                    f_to_close.close()
                except Exception:
                    pass
        if data.get("errcode", 0) != 0:
            raise Exception(f"上传图文消息图片失败: {data}")
        u = data.get("url")
        if not u:
            raise Exception(f"上传图文消息图片失败: {data}")
        return u

    def add_draft(self, articles: List[Dict[str, Any]]) -> str:
        """新增草稿
        参数说明（articles 为图文素材对象列表，以下字段均属于单个素材对象）：
        - article_type: 可选，文章类型，支持：图文消息（"news"，默认）、图片消息（"newspic"）
        - title: 必填，标题
        - author: 可选，作者，最长不超过16个字符，请直接传字符串，不要使用 Unicode 转义格式
        - digest: 可选，图文消息摘要，仅单图文有摘要；如未填写，默认抓取正文前54个字
        - content: 必填，图文消息正文内容，支持 HTML 标签，少于2万字符、整体小于1M；将移除 JS；其中图片 URL 必须来源于「上传图文消息内的图片获取URL」接口，外部图片 URL 会被过滤；图片消息（newspic）仅支持纯文本和部分特殊功能标签如商品，商品个数不超过50个
        - content_source_url: 可选，阅读原文链接
        - thumb_media_id: 可选，但当 article_type 为 "news" 时必填；图文消息封面图片素材 ID（永久 MediaID）
        - need_open_comment: 可选，是否打开评论，0 不打开（默认），1 打开
        - only_fans_can_comment: 可选，是否仅粉丝可评论，0 所有人（默认），1 仅粉丝
        - pic_crop_235_1: 可选，图文消息封面裁剪为 2.35:1 的裁剪坐标，格式为 "X1_Y1_X2_Y2"，以原图左上角（0,0）、右下角（1,1）为坐标系，精度不超过小数点后6位
        - pic_crop_1_1: 可选，图文消息封面裁剪为 1:1 的裁剪坐标，格式同上
        - image_info: 可选，图片消息里的图片相关信息（article_type 为 "newspic" 时使用）
            - image_list: 图片列表，最多20张
                - image_media_id: 必填，图片消息里的图片素材 ID（必须是永久 MediaID）
        - cover_info: 可选，图片消息的封面信息
            - crop_percent_list: 封面裁剪信息
                - ratio: 可选，裁剪比例，支持 "1_1"、"16_9"、"2.35_1"
                - x1,y1,x2,y2: 可选，裁剪坐标（同上坐标系定义）
        - product_info: 可选，商品信息（图片消息支持商品卡片，商品数量不超过50）

        返回：草稿 media_id；草稿被群发或发布后，将从草稿箱中移除；接口需在服务器端调用。
        """
        if not articles:
            raise ValueError("articles不能为空")
        token = self.access_token
        url = f"https://api.weixin.qq.com/cgi-bin/draft/add?access_token={token}"
        try:
            # 必须使用 utf-8 编码
            json_data = json.dumps({"articles": articles}, ensure_ascii=False).encode("utf-8")
            r = requests.post(url, data=json_data, timeout=15)
            r.raise_for_status()
            data = r.json()
        except Exception as e:
            raise Exception(f"新增草稿异常: {e}")
        if data.get("errcode", 0) != 0:
            raise Exception(f"新增草稿失败: {data}")
        media_id = data.get("media_id")
        if not media_id:
            raise Exception(f"新增草稿失败: {data}")
        return media_id

    def update_draft(self, media_id: str, index: int, article: Dict[str, Any]) -> Dict[str, Any]:
        """更新草稿
        :param media_id: 草稿 media_id
        :param index: 文章索引，从0开始
        :param article: 文章对象，参考add_draft参数说明
        :return: 更新结果
        """
        token = self.access_token
        url = f"https://api.weixin.qq.com/cgi-bin/draft/update?access_token={token}"
        try:
            payload = {"media_id": media_id, "index": index, "articles": article}
            # 必须使用 utf-8 编码
            json_data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
            r = requests.post(url, data=json_data, timeout=15)
            r.raise_for_status()
            data = r.json()
        except Exception as e:
            raise Exception(f"更新草稿异常: {e}")
        if data.get("errcode", 0) != 0:
            raise Exception(f"更新草稿失败: {data}")
        return data

    def publish_draft(self, media_id: str) -> str:
        """发布草稿
        :param media_id: 草稿 media_id
        :return: 发布ID
        """
        token = self.access_token
        url = f"https://api.weixin.qq.com/cgi-bin/freepublish/submit?access_token={token}"
        try:
            r = requests.post(url, json={"media_id": media_id}, timeout=15)
            r.raise_for_status()
            data = r.json()
        except Exception as e:
            raise Exception(f"发布草稿异常: {e}")
        if data.get("errcode", 0) != 0:
            raise Exception(f"发布草稿失败: {data}")
        publish_id = data.get("publish_id")
        if not publish_id:
            raise Exception(f"发布草稿失败: {data}")
        return publish_id

    def get_publish_status(self, publish_id: str) -> Dict[str, Any]:
        """查询发布状态
        :param publish_id: 发布ID
        :return: 发布状态对象
        """
        token = self.access_token
        url = f"https://api.weixin.qq.com/cgi-bin/freepublish/get?access_token={token}"
        try:
            r = requests.post(url, json={"publish_id": publish_id}, timeout=10)
            r.raise_for_status()
            data = r.json()
        except Exception as e:
            raise Exception(f"查询发布状态异常: {e}")
        if data.get("errcode", 0) != 0:
            raise Exception(f"查询发布状态失败: {data}")
        return data

    def publish_and_wait(self, media_id: str, timeout_sec: int = 120, interval_sec: int = 3) -> Dict[str, Any]:
        """提交发布并轮询发布状态，直至成功/失败或超时"""
        publish_id = self.publish_draft(media_id)
        deadline = time.time() + timeout_sec
        last: Dict[str, Any] = {}
        while time.time() < deadline:
            last = self.get_publish_status(publish_id)
            status = last.get("publish_status")
            if status == 0:
                return last
            if status in (2, 3):
                return last
            time.sleep(interval_sec)
        return last



def build_article(
    title: str,
    content: str,
    thumb_media_id: str,
    digest: Optional[str] = None,
    author: Optional[str] = None,
    content_source_url: Optional[str] = None,
    article_type: str = "news",
    need_open_comment: Optional[int] = None,
    only_fans_can_comment: Optional[int] = None,
    pic_crop_235_1: Optional[str] = None,
    pic_crop_1_1: Optional[str] = None,
    image_info: Optional[Dict[str, Any]] = None,
    cover_info: Optional[Dict[str, Any]] = None,
    product_info: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """构造新增草稿的图文素材对象（与新增草稿参数一致）"""
    a: Dict[str, Any] = {
        "title": title,
        "content": content,
        "thumb_media_id": thumb_media_id,
        "article_type": article_type or "news",
    }
    if digest is not None:
        a["digest"] = digest
    if author is not None:
        a["author"] = author
    if content_source_url is not None:
        a["content_source_url"] = content_source_url
    if need_open_comment is not None:
        a["need_open_comment"] = need_open_comment
    if only_fans_can_comment is not None:
        a["only_fans_can_comment"] = only_fans_can_comment
    if pic_crop_235_1 is not None:
        a["pic_crop_235_1"] = pic_crop_235_1
    if pic_crop_1_1 is not None:
        a["pic_crop_1_1"] = pic_crop_1_1
    if image_info is not None:
        a["image_info"] = image_info
    if cover_info is not None:
        a["cover_info"] = cover_info
    if product_info is not None:
        a["product_info"] = product_info
    return a


if __name__ == "__main__":
    client = WeChatOfficial()
    img_url = client.generate_image_by_prompt("一只可爱的苏格兰折耳猫，戴着一顶小小的巫师帽，坐在一堆古老的魔法书上，背景是温馨的书房，壁炉里有火在燃烧，细节丰富，电影感光线")
    print({"img_url": img_url})
    perm = client.upload_permanent_image(img_url)
    print({"permanent": perm})
    news_img_url = client.upload_news_image(img_url)
    print({"news_img_url": news_img_url})
    content_html = f"<p>示例图文</p><p><img src=\"{news_img_url}\"/></p>"
    article = build_article(title="示例标题", content=content_html, thumb_media_id=perm["media_id"], digest="摘要")
    media_id = client.add_draft([article])
    print({"draft_media_id": media_id})
    updated = client.update_draft(media_id, 0, build_article(title="更新后的标题", content=content_html, thumb_media_id=perm["media_id"], digest="更新摘要"))
    print({"update_result": updated})
    pub = client.publish_draft(media_id)
    print({"publish_result": pub})