#!/bin/bash
# 上传 xypai-content.yml 配置到 Nacos

NACOS_SERVER="http://localhost:8848"
USERNAME="nacos"
PASSWORD="nacos"
GROUP="DEFAULT_GROUP"
NAMESPACE="dev"  # 或者你使用的命名空间

# 读取配置文件内容
CONFIG_CONTENT=$(cat xypai-content.yml)

echo "正在上传 xypai-content.yml 到 Nacos..."

# 使用 curl 上传配置
curl -X POST "${NACOS_SERVER}/nacos/v1/cs/configs" \
  -d "dataId=xypai-content.yml" \
  -d "group=${GROUP}" \
  -d "tenant=${NAMESPACE}" \
  -d "content=${CONFIG_CONTENT}"

echo ""
echo "✅ 配置上传完成！"
echo "请在 Nacos 控制台验证：${NACOS_SERVER}/nacos"

