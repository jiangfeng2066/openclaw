#!/bin/bash

# EvoMap 简单脚本 - 无颜色代码版本

echo "=== EvoMap 简单脚本 ==="
echo ""

# 生成随机 hex
random_hex() {
    tr -dc 'a-f0-9' < /dev/urandom | head -c "$1"
}

# 生成消息 ID
generate_message_id() {
    echo "msg_$(date +%s)_$(random_hex 4)"
}

# 生成发送者 ID
generate_sender_id() {
    echo "node_$(random_hex 8)"
}

case "$1" in
    "hello")
        echo "正在注册 EvoMap 节点..."
        echo ""
        
        SENDER_ID=$(generate_sender_id)
        MESSAGE_ID=$(generate_message_id)
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        
        echo "生成的节点 ID: $SENDER_ID"
        echo "保存供后续使用..."
        echo "export E2A_SENDER_ID=\"$SENDER_ID\"" > /tmp/evomap_sender_id.env
        echo ""
        
        # 构建请求
        REQUEST_JSON=$(cat <<EOF
{
  "protocol": "gep-a2a",
  "protocol_version": "1.0.0",
  "message_type": "hello",
  "message_id": "$MESSAGE_ID",
  "sender_id": "$SENDER_ID",
  "timestamp": "$TIMESTAMP",
  "payload": {
    "capabilities": {},
    "gene_count": 0,
    "capsule_count": 0,
    "env_fingerprint": {
      "platform": "$(uname -s | tr '[:upper:]' '[:lower:]')",
      "arch": "$(uname -m)"
    }
  }
}
EOF
)
        
        echo "发送注册请求..."
        RESPONSE=$(curl -s -X POST https://evomap.ai/a2a/hello \
          -H "Content-Type: application/json" \
          -d "$REQUEST_JSON")
        
        echo ""
        echo "响应:"
        echo "$RESPONSE" | head -c 1000
        echo ""
        echo ""
        
        # 提取认领代码
        if echo "$RESPONSE" | grep -q '"claim_code"'; then
            CLAIM_CODE=$(echo "$RESPONSE" | grep -o '"claim_code":"[^"]*"' | cut -d'"' -f4)
            CLAIM_URL=$(echo "$RESPONSE" | grep -o '"claim_url":"[^"]*"' | cut -d'"' -f4)
            
            if [ -n "$CLAIM_CODE" ]; then
                echo "✅ 认领代码: $CLAIM_CODE"
                echo "🔗 认领 URL: $CLAIM_URL"
                echo ""
                echo "重要: 请将此认领 URL 提供给用户以绑定账户"
            fi
        fi
        ;;
        
    "fetch")
        echo "正在获取 EvoMap 资产..."
        echo ""
        
        # 读取 sender_id
        if [ -f /tmp/evomap_sender_id.env ]; then
            source /tmp/evomap_sender_id.env
        fi
        
        if [ -z "$E2A_SENDER_ID" ]; then
            echo "错误: 未找到节点 ID，请先运行: $0 hello"
            exit 1
        fi
        
        MESSAGE_ID=$(generate_message_id)
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        
        echo "使用节点 ID: $E2A_SENDER_ID"
        echo ""
        
        # 构建请求
        REQUEST_JSON=$(cat <<EOF
{
  "protocol": "gep-a2a",
  "protocol_version": "1.0.0",
  "message_type": "fetch",
  "message_id": "$MESSAGE_ID",
  "sender_id": "$E2A_SENDER_ID",
  "timestamp": "$TIMESTAMP",
  "payload": {
    "asset_type": "Capsule",
    "include_tasks": true
  }
}
EOF
)
        
        echo "发送获取请求..."
        RESPONSE=$(curl -s -X POST https://evomap.ai/a2a/fetch \
          -H "Content-Type: application/json" \
          -d "$REQUEST_JSON" \
          --max-time 30)
        
        echo ""
        echo "响应 (前1000字符):"
        echo "$RESPONSE" | head -c 1000
        if [ ${#RESPONSE} -gt 1000 ]; then
            echo "..."
        fi
        ;;
        
    "test")
        echo "测试 EvoMap 连接..."
        echo ""
        
        # 测试连接
        echo "测试 Hub 连接..."
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://evomap.ai/a2a/stats" --connect-timeout 5)
        
        if [ "$STATUS" = "200" ]; then
            echo "✅ Hub 连接正常 (HTTP $STATUS)"
        else
            echo "❌ Hub 连接失败 (HTTP $STATUS)"
        fi
        
        # 生成测试数据
        SENDER_ID=$(generate_sender_id)
        echo ""
        echo "测试数据生成:"
        echo "  示例节点 ID: $SENDER_ID"
        echo "  示例消息 ID: $(generate_message_id)"
        echo "  当前时间戳: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        ;;
        
    *)
        echo "用法: $0 [命令]"
        echo ""
        echo "命令:"
        echo "  hello   注册新节点 (获取认领代码)"
        echo "  fetch   获取资产和任务"
        echo "  test    测试连接"
        echo ""
        echo "示例:"
        echo "  $0 test"
        echo "  $0 hello"
        echo "  $0 fetch"
        echo ""
        echo "节点 ID 会自动保存在: /tmp/evomap_sender_id.env"
        ;;
esac