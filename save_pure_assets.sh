#!/bin/bash

echo "💾 保存纯 JSON 格式的 EvoMap 资产"
echo "================================"

# 创建资产目录
ASSET_DIR="$HOME/evomap_pure_assets"
mkdir -p "$ASSET_DIR"

echo "资产将保存到: $ASSET_DIR"
echo ""

# 获取 sender_id
if [ ! -f /tmp/evomap_sender_id.env ]; then
    echo "❌ 请先注册节点: ./evomap_simple.sh hello"
    exit 1
fi

source /tmp/evomap_sender_id.env
echo "使用节点: $E2A_SENDER_ID"
echo ""

# 生成请求
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MESSAGE_ID="msg_${TIMESTAMP}_$(tr -dc 'a-f0-9' < /dev/urandom | head -c 4)"
JSON_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

REQUEST_JSON=$(cat <<EOF
{
  "protocol": "gep-a2a",
  "protocol_version": "1.0.0",
  "message_type": "fetch",
  "message_id": "$MESSAGE_ID",
  "sender_id": "$E2A_SENDER_ID",
  "timestamp": "$JSON_TIMESTAMP",
  "payload": {
    "asset_type": "Capsule",
    "include_tasks": false
  }
}
EOF
)

OUTPUT_FILE="$ASSET_DIR/evomap_pure_${TIMESTAMP}.json"

echo "🔄 正在获取纯 JSON 资产..."
echo "请求发送时间: $(date)"

# 直接使用 curl 获取纯 JSON
curl -s -X POST "https://evomap.ai/a2a/fetch" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_JSON" \
  --max-time 20 > "$OUTPUT_FILE"

if [ $? -ne 0 ]; then
    echo "❌ 请求失败"
    exit 1
fi

FILE_SIZE=$(wc -c < "$OUTPUT_FILE")
echo "✅ 保存成功!"
echo "   文件: $(basename "$OUTPUT_FILE")"
echo "   大小: $FILE_SIZE 字节"
echo "   路径: $OUTPUT_FILE"

# 检查文件内容
echo ""
echo "📄 文件内容检查:"
if [ "$FILE_SIZE" -lt 100 ]; then
    echo "⚠️  文件过小，可能是空响应"
    cat "$OUTPUT_FILE"
else
    # 尝试解析 JSON
    if command -v jq &> /dev/null; then
        ASSET_COUNT=$(jq '.payload.results | length' "$OUTPUT_FILE" 2>/dev/null || echo "0")
        echo "   JSON 解析: 有效"
        echo "   资产数量: $ASSET_COUNT"
        
        # 显示前3个资产
        echo ""
        echo "📋 前3个资产:"
        jq -r '.payload.results[0:3][] | .payload.summary' "$OUTPUT_FILE" 2>/dev/null | \
          awk '{print "  • " substr($0, 1, 80) "..."}'
    else
        # 简单文本分析
        ASSET_COUNT=$(grep -c '"summary":"' "$OUTPUT_FILE" 2>/dev/null || echo "0")
        echo "   资产数量 (文本统计): $ASSET_COUNT"
        
        echo ""
        echo "📋 资产示例:"
        grep -o '"summary":"[^"]*"' "$OUTPUT_FILE" 2>/dev/null | \
          head -3 | \
          cut -d'"' -f4 | \
          awk '{print "  • " substr($0, 1, 80) "..."}'
    fi
fi

echo ""
echo "🔍 查看命令:"
echo "  cat $OUTPUT_FILE | head -200              # 查看文件开头"
echo "  file $OUTPUT_FILE                         # 检查文件类型"
echo "  ls -lh $ASSET_DIR/                        # 列出所有文件"
echo ""
echo "📝 文件格式: 纯 JSON，可以直接用以下工具处理:"
echo "  • jq '.payload.results[] | .payload.summary' $OUTPUT_FILE"
echo "  • python3 -m json.tool $OUTPUT_FILE | head -100"
echo "  • 任何文本编辑器或 IDE"