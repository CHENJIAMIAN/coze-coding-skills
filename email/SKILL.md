---
name: email
description: 邮件(邮箱)集成，通过 IMAP/SMTP 协议连接到邮件服务器，实现邮件接收、发送、起草以及邮箱管理功能。支持qq, 163, aliyun(阿里),outlook, 263 等邮件厂商。 
license: MIT
---

# 邮件（IMAP/SMTP）集成基本信息

# 集成描述
这是一个用于 Python 环境的邮件外部集成（官方）使用说明文档，内部适配主流邮件服务商的 IMAP/SMTP 协议规范，提供标准化的邮件发送、接收、附件处理及邮件状态管理能力。无需开发者手动配置邮件服务器地址、端口、账号密码等核心凭证，所有关键信息将从环境变量自动读取，可快速实现纯文本邮件、HTML 格式邮件、带附件邮件的发送，以及指定条件邮件的接收、邮件标记、附件提取等核心操作。

重要提示：
1. 不要询问用户任何密钥或环境变量，也不需要你设置密钥或环境变量，将通过以下方式获取邮件配置。
   import json
   from coze_workload_identity import Client
   client = Client()
  email_credential = client.get_integration_credential("integration-email-imap-smtp")
  # 解析凭证信息，获取核心配置
  email_config = json.loads(email_credential)
  # IMAP 配置
  imap_server = email_config["imap_server"]  # 如"imap.163.com"
  imap_port = email_config["imap_port"]      # 如993（SSL端口）
  # SMTP 配置
  smtp_server = email_config["smtp_server"]  # 如"smtp.163.com"
  smtp_port = email_config["smtp_port"]      # 如465（SSL端口）
  # 登录信息
  email_account = email_config["account"]     # 登录邮箱账号，如"user@163.com"
  email_auth_code = email_config["auth_code"] # 邮箱授权码（非登录密码，需在邮箱设置中开启获取）
2. 为了记录API调用情况，生成的集成函数调用都需要 observe 函数装饰，observe 函数通过  from cozeloop.decorator import observe 导入
3. 连接说明：IMAP 用于邮件接收操作，SMTP 用于邮件发送操作，默认采用 SSL 加密方式建立连接，确保数据传输安全，无需额外配置加密参数。

# 使用说明
-- 请参阅以下代理说明、代码片段和文档 URL（如有），了解如何使用此集成
-- 使用 SMTP 发送邮件后，需要调用 quit 函数避免服务器因 “会话异常” 丢弃邮件
-- 捕获连接异常、登录异常、发送/接收异常, 处理各种异常情况，并记录错误详情，便于问题排查。

# 代码示例: 发送邮件
import json
import smtplib
import ssl
import time
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr, formatdate, make_msgid
from coze_workload_identity import Client
from cozeloop.decorator import observe

client = Client()
def get_email_config():
    """获取邮件配置信息"""
    email_credential = client.get_integration_credential("integration-email-imap-smtp")
    return json.loads(email_credential)

#发送 HTML 格式的邮件，包含图片
@observe
# 发送 HTML 格式的邮件，包含图片
def send_email_with_image(subject: str, content: str, image_urls: list, to_addrs: list, cc_addrs: list = None, bcc_addrs: list = None) -> dict:
    """
    发送包含图片的邮件
    
    Args:
        subject: 邮件主题
        content: 邮件正文（HTML格式，包含图片引用）
        image_url: 图片URL，用于在HTML中引用图片
        to_addrs: 收件人列表，如["recipient1@xxx.com"]
        cc_addrs: 抄送列表，可选
        bcc_addrs: 密送列表，可选
        
    Returns:
        发送结果字典，包含状态和消息
    """
    try:
        config = get_email_config()
        html_content = f"<h3>{content}</h3><br>"
        for idx, image_url in enumerate(image_urls):
            html_content += f"<p>图片 {idx+1}:</p><img src=\"{image_url}\" alt=\"生成的图片 {idx+1}\" style=\"max-width: 800px;\"><br><br>"
        msg = MIMEText(html_content, "html", "utf-8")
        msg["From"] = formataddr(("图片生成助手", config["account"]))
        msg["To"] = ", ".join(to_addrs) if to_addrs else ""
        msg["Subject"] = Header(subject, "utf-8")
        msg["Date"] = formatdate(localtime=True)
        msg["Message-ID"] = make_msgid()
        all_recipients = to_addrs.copy()
        if not all_recipients:
            return {"status": "error", "message": "收件人为空"}
        ctx = ssl.create_default_context()
        ctx.minimum_version = ssl.TLSVersion.TLSv1_2
        attempts = 3
        last_err = None
        for i in range(attempts):
            try:
                with smtplib.SMTP_SSL(config["smtp_server"], config["smtp_port"], context=ctx, timeout=30) as server:
                    server.ehlo()
                    server.login(config["account"], config["auth_code"])
                    server.sendmail(config["account"], all_recipients, msg.as_string())
                    server.quit()
                return {"status": "success", "message": f"邮件成功发送给 {len(to_addrs)} 位收件人", "recipient_count": len(to_addrs)}
            except (smtplib.SMTPServerDisconnected, smtplib.SMTPConnectError, smtplib.SMTPDataError, smtplib.SMTPHeloError, ssl.SSLError, OSError) as e:
                last_err = e
                time.sleep(1 * (i + 1))
        if last_err:
            return {"status": "error", "message": "发送失败", "detail": {"type": last_err.__class__.__name__, "args": [a.hex() if isinstance(a, bytes) else str(a) for a in getattr(last_err, "args", [])]}}
        return {"status": "error", "message": "发送失败: 未知错误"}
    except smtplib.SMTPAuthenticationError as e:
        return {"status": "error", "message": f"认证失败: {str(e)}"}
    except smtplib.SMTPRecipientsRefused as e:
        return {"status": "error", "message": "收件人被拒绝", "detail": {k: str(v) for k, v in getattr(e, "recipients", {}).items()}}
    except smtplib.SMTPSenderRefused as e:
        return {"status": "error", "message": f"发件人被拒绝: {e.smtp_code} {e.smtp_error}"}
    except smtplib.SMTPDataError as e:
        return {"status": "error", "message": f"数据被拒绝: {e.smtp_code} {e.smtp_error}"}
    except smtplib.SMTPConnectError as e:
        return {"status": "error", "message": f"连接失败: {str(e)}"}
    except Exception as e:
        return {"status": "error", "message": f"发送失败: {str(e)}"}

# 调用示例
if __name__ == "__main__":
    send_result = send_email_with_image(
        subject="Python邮件集成测试（纯文本）",
        content="这是通过IMAP/SMTP集成发送的纯文本测试邮件，无需手动配置服务器信息。",
        image_urls=["https://test.cc"],
        to_addrs=["recipient@xxx.com"],
        cc_addrs=["cc_recipient@xxx.com"]
    )