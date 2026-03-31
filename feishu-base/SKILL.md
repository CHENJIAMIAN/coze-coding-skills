---
name: feishu-base
description: 飞书多维表格，支持以下功能：1. 创建多维表格；2. 创建多维表格数据表；3. 列出多维表格下的全部数据表；4. 获取多维表格的元数据；5. 在多维表格数据表中新增多条记录；6. 根据 record_id 检索多维表格数据表中的记录；7. 批量更新多维表格数据表中的现有记录；8. 查询多维表格数据表中的记录；9. 搜索多维表格类型的文档；
license: MIT
---

#  飞书多维表格集成描述

这是一个用于 Python 环境的飞书多维表格外部集成（官方）使用说明文档，内部适配飞书多维表格开放平台接口规范，提供标准化的数据读写、视图管理及记录操作能力。无需开发者手动配置应用凭证（App ID 与 App Secret），可快速实现单条记录增删改、批量数据导入导出、视图筛选配置及关联表格数据查询等核心操作。

重要提示
1. 不要询问用户任何密钥或环境变量，也不需要你设置密钥或环境变量，access_token 将通过以下方式获取。
   from coze_workload_identity import Client
   client = Client()
   access_token = client.get_integration_credential(\"integration-feishu-base\")
2. 为了记录API调用情况，生成的集成函数调用都需要 observe 函数装饰，observe 函数通过 from cozeloop.decorator import observe 导入
3. **app_token 和 table_id 没有指定时候需要用户手动输入作为智能体的入参**

# 使用说明

-- 请参阅以下代码片段和文档 URL（如有），了解如何使用此集成
-- 捕获请求异常（如网络错误、4xx/5xx 状态码), 实现异常重试机制（针对429限流、503服务不可用等错误, 处理各种异常情况，并记录错误详情，便于问题排查。

# 代码示例

```python

import requests
from functools import wraps
from cozeloop.decorator import observe
from coze_workload_identity import Client

client = Client()

def get_access_token() -> str:
    """
    获取飞书多维表格（Bitable）的租户访问令牌。
    """
    access_token = client.get_integration_credential(\"integration-feishu-base\")
    return access_token

def require_token(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        self.access_token = get_access_token()
        if not self.access_token:
            raise ValueError(\"FEISHU_TENANT_ACCESS_TOKEN is not set\")
        return func(self, *args, **kwargs)
    return wrapper

class FeishuBitable:
    """
    飞书多维表格（Bitable）HTTP 客户端。
    所有方法返回值均为 Feishu OpenAPI 标准响应："{\"code\": int, \"msg\": str, \"data\": any}"
    基础 URL 默认 "https://open.larkoffice.com/open-apis"。
    """
    def __init__(self, base_url: str = \"https://open.larkoffice.com/open-apis\", timeout: int = 30):
        self.base_url = base_url.rstrip(\"/\")
        self.timeout = timeout
        self.access_token = get_access_token()

    def _headers(self) -> dict:
        return {
            \"Authorization\": f\"Bearer {self.access_token}\" if self.access_token else \"\",
            \"Content-Type\": \"application/json; charset=utf-8\",
        }

    @observe
    def _request(self, method: str, path: str, params: dict | None = None, json: dict | None = None) -> dict:
        try:
            url = f\"{self.base_url}{path}\"
            resp = requests.request(method, url, headers=self._headers(), params=params, json=json, timeout=self.timeout)
            resp_data = resp.json()
        except requests.exceptions.RequestException as e:
            raise Exception(f\"FeishuBitable API request error: {e}\")
        if resp_data.get(\"code\") != 0:
            raise Exception(f\"FeishuBitable API error: {resp_data}\")
        return resp_data

    @require_token
    def create_base(self, name: str | None = None, folder_token: str | None = None, time_zone: str | None = None) -> dict:
        """
        创建多维表格 Base

        接口：POST `/bitable/v1/apps`
        入参（JSON）：
        - `name`: Base 名称，最长 255 字符，可选
        - `folder_token`: 归属文件夹 Token，可选，需具备该目录的编辑权限
        - `time_zone`: 文档时区，如 `Asia/Macau`，可选

        出参（data）：
        - Base 基础信息，包含 `app_token`、`name`、创建时间等
        限制：复制中的 Base 无法操作；写接口不支持并发。
        """
        body: dict = {}
        if name is not None:
            body[\"name\"] = name
        if folder_token is not None:
            body[\"folder_token\"] = folder_token
        if time_zone is not None:
            body[\"time_zone\"] = time_zone
        return self._request(\"POST\", \"/bitable/v1/apps\", json=body)

    @require_token
    def get_base_info(self, app_token: str) -> dict:
        """
        获取 Base 信息

        接口：GET `/bitable/v1/apps/:app_token`
        入参（路径）：
        - `app_token`: Base 的唯一标识

        出参（data）：
        - Base 元信息：`app_token`、`name`、概览数据等
        """
        return self._request(\"GET\", f\"/bitable/v1/apps/{app_token}\")

    @require_token
    def list_tables(self, app_token: str, page_token: str | None = None, page_size: int | None = None) -> dict:
        """
        列出 Base 下所有数据表

        接口：GET `/bitable/v1/apps/:app_token/tables`
        入参（路径）：
        - `app_token`
        入参（查询）：
        - `page_token`: 分页标记，可选
        - `page_size`: 分页大小，默认 20，最大 100，可选

        出参（data）：
        - 数据表列表，包含 `table_id`、`revision`（版本号）、`name`（名称）
        - 可能包含分页信息，如 `page_token`、`has_more`
        """
        params: dict = {}
        if page_token is not None:
            params[\"page_token\"] = page_token
        if page_size is not None:
            params[\"page_size\"] = page_size
        return self._request(\"GET\", f\"/bitable/v1/apps/{app_token}/tables\", params=params)

    @require_token
    def create_table(self, app_token: str, table_name: str, fields: list | None = None) -> dict:
        """
        创建数据表

        接口：POST `/bitable/v1/apps/:app_token/tables`
        入参（路径）：
        - `app_token`
        入参（JSON）：
        - `table_name`: 表名称（必填）
        - `fields[]`: 初始字段定义列表（可选），每项包含：
          - `field_name`（名称）、`type`（类型：1 文本、2 数字、3 单选、4 多选、5 日期 等）
          - 可选 `property`、`description`、`ui_type`

        出参（data）：
        - 新建表对象，包含 `table_id`、`name`、初始字段列表
        """
        body: dict = {\"table_name\": table_name}
        if fields is not None:
            body[\"fields\"] = fields
        return self._request(\"POST\", f\"/bitable/v1/apps/{app_token}/tables\", json=body)

    @require_token
    def delete_tables(self, app_token: str, table_ids: list[str] | str) -> dict:
        """
        批量删除数据表

        接口：POST `/bitable/v1/apps/:app_token/tables/batch_delete`
        入参（路径）：
        - `app_token`
        入参（JSON）：
        - `table_ids[]`: 待删除的表 ID 列表（最多 50）

        出参（data）：
        - 执行结果；当仅剩最后一张数据表时返回错误（`The last table cannot be deleted`）
        限制：写接口不支持并发；复制中的 Base 无法操作。
        """
        ids = table_ids if isinstance(table_ids, list) else [table_ids]
        body = {\"table_ids\": ids}
        return self._request(\"POST\", f\"/bitable/v1/apps/{app_token}/tables/batch_delete\", json=body)

    @require_token
    def list_fields(
        self,
        app_token: str,
        table_id: str,
        view_id: str | None = None,
        text_field_as_array: bool | None = None,
        page_token: str | None = None,
        page_size: int | None = None,
    ) -> dict:
        """
        列出数据表字段

        接口：GET `/bitable/v1/apps/:app_token/tables/:table_id/fields`
        入参（路径）：
        - `app_token`、`table_id`
        入参（查询）：
        - `view_id`: 视图 ID（当使用 filter/sort 时忽略），可选
        - `text_field_as_array`: `description` 是否以数组返回，默认 false，可选
        - `page_token`: 分页标记，可选
        - `page_size`: 分页大小，默认 20，最大 100，可选

        出参（data）：
        - 字段列表 `fields[]`，每项包含：
          - `field_id`、`field_name`、`type`、`property`、`description`、`ui_type`
        """
        params: dict = {}
        if view_id is not None:
            params[\"view_id\"] = view_id
        if text_field_as_array is not None:
            params[\"text_field_as_array\"] = text_field_as_array
        if page_token is not None:
            params[\"page_token\"] = page_token
        if page_size is not None:
            params[\"page_size\"] = page_size
        return self._request(\"GET\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/fields\", params=params)

    @require_token
    def add_field(self, app_token: str, table_id: str, field: dict, client_token: str | None = None) -> dict:
        """
        新增字段

        接口：POST `/bitable/v1/apps/:app_token/tables/:table_id/fields`
        入参（路径）：
        - `app_token`、`table_id`
        入参（查询）：
        - `client_token`: 幂等操作标识（UUIDv4），可选
        入参（JSON）：
        - `field_name`（必填）、`type`（必填）
        - 可选 `property`、`description`、`ui_type`

        出参（data）：
        - 新增的字段对象，含 `field_id`、`type`、`property` 等
        注意：不支持新增类型 `19 查找引用`。
        """
        params = {}
        if client_token is not None:
            params[\"client_token\"] = client_token
        return self._request(\"POST\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/fields\", params=params, json=field)

    @require_token
    def update_field(self, app_token: str, table_id: str, field_id: str, field: dict) -> dict:
        """
        更新字段（全量覆盖）

        接口：PUT `/bitable/v1/apps/:app_token/tables/:table_id/fields/:field_id`
        入参（路径）：
        - `app_token`、`table_id`、`field_id`
        入参（JSON）：
        - 与新增字段结构一致；为全量更新，`property` 等会被完全覆盖

        出参（data）：
        - 更新后的字段对象
        """
        return self._request(\"PUT\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/fields/{field_id}\", json=field)

    @require_token
    def delete_field(self, app_token: str, table_id: str, field_id: str) -> dict:
        """
        删除字段

        接口：DELETE `/bitable/v1/apps/:app_token/tables/:table_id/fields/:field_id`
        入参（路径）：
        - `app_token`、`table_id`、`field_id`
        出参（data）：
        - 执行结果
        """
        return self._request(\"DELETE\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/fields/{field_id}\")

    @require_token
    def add_records(
        self,
        app_token: str,
        table_id: str,
        records: list,
        user_id_type: str | None = None,
        client_token: str | None = None,
        ignore_consistency_check: bool | None = None,
    ) -> dict:
        """
        批量新增记录

        接口：POST `/bitable/v1/apps/:app_token/tables/:table_id/records/batch_create`
        入参（路径）：
        - `app_token`、`table_id`
        入参（查询）：
        - `user_id_type`: 用户 ID 类型（`open_id`/`union_id`/`user_id`），默认 `open_id`
        - `client_token`: 幂等操作标识（UUIDv4），可选
        - `ignore_consistency_check`: 是否忽略读写一致性检查，默认 false，可选
        入参（JSON）：
        - `records[]`: 记录列表，单次最多 1,000 条；每条形如：
          - `{ \"fields\": { \"字段名\": 值, ... } }`

        出参（data）：
        - 创建成功的记录集合，包含 `record_id`、`fields` 等
        限制：来自外部数据源同步的表不支持增删改；同表写接口不支持并发。
        """
        params: dict = {}
        if user_id_type is not None:
            params[\"user_id_type\"] = user_id_type
        if client_token is not None:
            params[\"client_token\"] = client_token
        if ignore_consistency_check is not None:
            params[\"ignore_consistency_check\"] = ignore_consistency_check
        body = {\"records\": records}
        return self._request(\"POST\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/records/batch_create\", params=params, json=body)

    @require_token
    def update_records(
        self,
        app_token: str,
        table_id: str,
        records: list,
        user_id_type: str | None = None,
        ignore_consistency_check: bool | None = None,
    ) -> dict:
        """
        批量更新记录

        接口：POST `/bitable/v1/apps/:app_token/tables/:table_id/records/batch_update`
        入参（路径）：
        - `app_token`、`table_id`
        入参（查询）：
        - `user_id_type`: 用户 ID 类型，可选
        - `ignore_consistency_check`: 是否忽略读写一致性检查，可选
        入参（JSON）：
        - `records[]`: 更新列表，单次最多 1,000 条；每条包含：
          - `record_id`: 记录 ID（必填）
          - `fields`: 需更新的字段键值对

        出参（data）：
        - 更新后的记录集合
        限制：来自外部数据源同步的表不支持增删改；同表写接口不支持并发。
        """
        params: dict = {}
        if user_id_type is not None:
            params[\"user_id_type\"] = user_id_type
        if ignore_consistency_check is not None:
            params[\"ignore_consistency_check\"] = ignore_consistency_check
        body = {\"records\": records}
        return self._request(\"POST\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/records/batch_update\", params=params, json=body)

    @require_token
    def list_records(
        self,
        app_token: str,
        table_id: str,
        record_ids: list[str] | str,
        user_id_type: str | None = None,
        with_shared_url: bool | None = None,
        automatic_fields: bool | None = None,
    ) -> dict:
        """
        批量获取记录

        接口：POST `/bitable/v1/apps/:app_token/tables/:table_id/records/batch_get`
        入参（路径）：
        - `app_token`、`table_id`
        入参（JSON）：
        - `record_ids[]`: 记录 ID 列表，最多 100 条（必填）
        - `user_id_type`: 用户 ID 类型，可选（`open_id`/`union_id`/`user_id`）
        - `with_shared_url`: 是否返回记录分享链接，默认 false，可选
        - `automatic_fields`: 是否返回自动计算字段，默认 false，可选

        出参 ：
        - {
            \"code\": 0,
            \"msg\": \"success\",
            \"data\": {
                \"records\": [
                {
                    \"fields\": {

                    },
                    \"last_modified_time\": 1702455191000,
                    \"record_id\": \"recyOaMB2F\",
                    \"shared_url\": \"https://example.feishu.cn/record/KBcNrNtpWePAlscCvdmb6ZcSc5b\"
                }
                ]
            }
         }
        """
        ids = record_ids if isinstance(record_ids, list) else [record_ids]
        body: dict = {\"record_ids\": ids}
        if user_id_type is not None:
            body[\"user_id_type\"] = user_id_type
        if with_shared_url is not None:
            body[\"with_shared_url\"] = with_shared_url
        if automatic_fields is not None:
            body[\"automatic_fields\"] = automatic_fields
        return self._request(\"POST\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/records/batch_get\", json=body)

    @require_token
    def batch_get_records(
        self,
        app_token: str,
        table_id: str,
        record_ids: list[str] | str,
        user_id_type: str | None = None,
        with_shared_url: bool | None = None,
        automatic_fields: bool | None = None,
    ) -> dict:
        return self.list_records(app_token, table_id, record_ids, user_id_type, with_shared_url, automatic_fields)

    @require_token
    def delete_records(self, app_token: str, table_id: str, record_ids: list[str] | str) -> dict:
        """
        批量删除记录

        接口：POST `/bitable/v1/apps/:app_token/tables/:table_id/records/batch_delete`
        入参（路径）：
        - `app_token`、`table_id`
        入参（JSON）：
        - `record_ids[]`: 要删除的记录 ID 列表

        出参（data）：
        - 执行结果；当存在失败项时，返回对应错误码与原因
        限制：来自外部数据源同步的表不支持增删改；同表写接口不支持并发。
        """
        ids = record_ids if isinstance(record_ids, list) else [record_ids]
        body = {\"record_ids\": ids}
        return self._request(\"POST\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/records/batch_delete\", json=body)

    @require_token
    def search_record(
        self,
        app_token: str,
        table_id: str,
        view_id: str | None = None,
        field_names: list[str] | None = None,
        sort: list | None = None,
        filter: dict | str | None = None,
        page_token: str | None = None,
        page_size: int | None = None,
        user_id_type: str | None = None,
    ) -> dict:
        """
        条件查询记录

        HTTP 方法：POST
        路径：`/bitable/v1/apps/:app_token/tables/:table_id/records/search`
        频率限制：20 次/秒

        入参（路径参数）：
        - `app_token`: 多维表格 App 的唯一标识
        - `table_id`: 数据表的唯一标识

        入参（查询参数）：
        - `user_id_type`: 用户 ID 类型，默认 `open_id`；取值 `open_id` / `union_id` / `user_id`
        - `page_token`: 分页标记；首次不填表示从头开始遍历
        - `page_size`: 分页大小，默认 20，最大 500

        入参（请求体 JSON）：
        - `view_id`: 视图 ID，可选；当 `filter` 或 `sort` 不为空时忽略
        - `field_names`: `string[]`，指定返回记录中包含的字段，可选
        - `sort`: `sort[]` 排序条件，可选
            - field_name: 字段名称
            - desc: 是否降序排序，默认 false
        - `filter`: 条件筛选, 可选
             - `conditions`: 条件数组（最多 20 条），每项包含：
               - `field_name`: 字段名称或 `field_id`
               - `operator`: 运算符，随字段类型而异, 可选值有 is, isNot, contains, doesNotContain, isEmpty, isNotEmpty, isGreater, isGreaterEqual, isLess, isLessEqual, like, in
               - `value`: 值，随字段类型取值
             - `conjunction`: 逻辑连接符，`and` 或 `or`
        出参（data）：
        - `items[]`: 记录列表（含 `record_id`、`fields`、`last_modified_time` 等）
        - `page_token`: 下一页标记
        - `has_more`: 是否还有更多记录

        注意事项：
        - 若多维表格开启了高级权限，需确保调用身份具备管理权限，否则可能调用成功但返回数据为空。
        """
        params: dict = {}
        if user_id_type is not None:
            params[\"user_id_type\"] = user_id_type
        if page_token is not None:
            params[\"page_token\"] = page_token
        if page_size is not None:
            params[\"page_size\"] = page_size
        body: dict = {}
        if view_id is not None:
            body[\"view_id\"] = view_id
        if field_names is not None:
            body[\"field_names\"] = field_names
        if sort is not None:
            body[\"sort\"] = sort
        if filter is not None:
            body[\"filter\"] = filter
        return self._request(\"POST\", f\"/bitable/v1/apps/{app_token}/tables/{table_id}/records/search\", params=params, json=body)

    @require_token
    def search_base(self, query: str | None = None, count: int | None = None, offset: str | None = None) -> dict:
        """
        查找多维表格

        接口：POST `/suite/docs-api/search/object`
        入参（JSON）：
        - `search_key`: 指定搜索的关键字。
        - `count`: 指定搜索返回的文件数量。取值范围为 [0,50]。
        - `offset`: 指定搜索的偏移量，该参数最小为 0，即不偏移。该参数的值与返回的文件数量之和不得大于或等于 200（即 offset + count < 200）

        出参（data）：
        - 匹配的文档列表 `files[]`，每项含 `token`、`type`、`name` 等；当 `type=bitable` 时表示 Base
        """
        body: dict = {}
        if query is not None:
            body[\"search_key\"] = query
        if count is not None:
            body[\"count\"] = count
        if offset is not None:
            body[\"offset\"] = offset
        body[\"docs_types\"] = [\"bitable\"]
        return self._request(\"POST\", \"/suite/docs-api/search/object\", json=body)


if __name__ == \"__main__\":
    client = FeishuBitable()
    record_ids = client.search_record(
        app_token=\"WQdQbJnm0aJswrsOfrYciaV0n1e\",
        table_id=\"tblenvHv3nU9sCfr\",
    )[\"data\"][\"items\"]
    record_ids = [record[\"record_id\"] for record in record_ids]
    # print(record_ids)
    for record in client.list_records(
        app_token=\"WQdQbJnm0aJswrsOfrYciaV0n1e\",
        table_id=\"tblenvHv3nU9sCfr\",
        record_ids=record_ids,
    )[\"data\"][\"records\"]:
        print(record[\"record_id\"], record[\"fields\"])
    fields = client.list_fields(
        app_token=\"WQdQbJnm0aJswrsOfrYciaV0n1e\",
        table_id=\"tblenvHv3nU9sCfr\",
    )[\"data\"][\"items\"]
    print(fields)
    # 根据 fields 结构插入新记录
    client.add_records(
        app_token=\"WQdQbJnm0aJswrsOfrYciaV0n1e\",
        table_id=\"tblenvHv3nU9sCfr\",
        records=[
            {
                \"fields\": {
                    \"文本\": \"新记录\"
                }
            }
        ],
    )
```
