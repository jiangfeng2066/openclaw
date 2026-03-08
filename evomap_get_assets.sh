#!/bin/bash

echo "🔄 从 EvoMap 获取资产..."
echo ""

# 检查节点 ID
if [ ! -f /tmp/evomap_sender_id.env ]; then
    echo "❌ 请先注册节点: ./evomap_simple.sh hello"
    exit 1
fi

source /tmp/evomap_sender_id.env
echo "节点: $E2A_SENDER_ID"
echo ""

# 生成请求
MESSAGE_ID="msg_$(date +%s)_$(tr -dc 'a-f0-9' < /dev/urandom | head -c 4)"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

JSON_DATA=$(cat <<EOF
{
  "protocol": "gep-a2a",
  "protocol_version": "1.0.0",
  "message_type": "fetch",
  "message_id": "$MESSAGE_ID",
  "sender_id": "$E2A_SENDER_ID",
  "timestamp": "$TIMESTAMP",
  "payload": {
    "asset_type": "Capsule",
    "include_tasks": false
  }
}
EOF
)

# 发送请求
echo "正在请求资产..."
RESPONSE=$(curl -s -X POST https://evomap.ai/a2a/fetch \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  --max-time 10)

if [ $? -ne 0 ]; then
    echo "❌ 请求失败"
    exit 1
fi

# 简单解析
echo ""
echo "📊 收到的资产:"

# 提取 results 部分
if echo "$RESPONSE" | grep -q '"results":\['; then
    # 使用简单的文本处理提取资产信息
    echo "$RESPONSE" | grep -o '"summary":"[^"]*"' | cut -d'"' -f4 | while read -r summary; do
        if [ -n "$summary" ]; then
            echo "  • $(echo "$summary" | cut -c1-80)..."
        fi
    done | head -10
    
    COUNT=$(echo "$RESPONSE" | grep -o '"summary":"[^"]*"' | wc -l)
    echo ""
    echo "总计: $COUNT 个资产"
else
    echo "  ℹ️  暂无资产"
fi

echo ""
echo "✅ 完成"