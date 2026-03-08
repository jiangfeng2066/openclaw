#!/bin/bash

echo "📋 EvoMap 完整资产列表"
echo "========================"
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

echo "正在获取资产列表..."
echo ""

# 发送请求并保存完整响应
RESPONSE_FILE="/tmp/evomap_full_response_$(date +%s).json"
curl -s -X POST https://evomap.ai/a2a/fetch \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  --max-time 15 > "$RESPONSE_FILE"

if [ $? -ne 0 ] || [ ! -s "$RESPONSE_FILE" ]; then
    echo "❌ 请求失败"
    rm -f "$RESPONSE_FILE"
    exit 1
fi

echo "✅ 响应已保存到: $RESPONSE_FILE"
echo ""

# 方法1: 使用 Python 解析 JSON (如果可用)
if command -v python3 &> /dev/null; then
    echo "📊 使用 Python 解析资产列表:"
    echo ""
    
    python3 << 'EOF'
import json
import sys

try:
    with open('$RESPONSE_FILE', 'r') as f:
        data = json.load(f)
    
    payload = data.get('payload', {})
    results = payload.get('results', [])
    
    print(f"找到 {len(results)} 个资产:")
    print("=" * 80)
    
    for i, asset in enumerate(results, 1):
        asset_id = asset.get('asset_id', 'N/A')[:20] + "..."
        asset_type = asset.get('asset_type', 'N/A')
        status = asset.get('status', 'N/A')
        confidence = asset.get('confidence', 0)
        gdi_score = asset.get('gdi_score', 0)
        
        # 从嵌套的 payload 中提取 summary
        inner_payload = asset.get('payload', {})
        summary = inner_payload.get('summary', '无描述')
        
        triggers = asset.get('trigger_text', '无触发条件')
        
        print(f"{i:3d}. {summary[:100]}...")
        print(f"     类型: {asset_type} | 状态: {status} | 置信度: {confidence:.2f} | GDI: {gdi_score:.1f}")
        print(f"     触发: {triggers[:80]}...")
        print(f"     资产ID: {asset_id}")
        print()
        
except Exception as e:
    print(f"解析错误: {e}")
    sys.exit(1)
EOF

elif command -v jq &> /dev/null; then
    echo "📊 使用 jq 解析资产列表:"
    echo ""
    
    # 使用 jq 提取资产信息
    jq -r '.payload.results[] | "\(.asset_type) | \(.status) | 置信度: \(.confidence) | GDI: \(.gdi_score)\n描述: \(.payload.summary // "无描述")\n触发: \(.trigger_text // "无触发条件")\n资产ID: \(.asset_id[:20])...\n"' "$RESPONSE_FILE" | \
    awk 'BEGIN {count=0} {if (NR % 4 == 1) {count++; printf "%3d. %s\n", count, $0} else {print "     " $0}}'
    
    COUNT=$(jq '.payload.results | length' "$RESPONSE_FILE" 2>/dev/null || echo "0")
    echo ""
    echo "总计: $COUNT 个资产"
    
else
    echo "📊 使用文本处理显示资产列表:"
    echo ""
    
    # 简单的文本处理
    grep -o '"summary":"[^"]*"' "$RESPONSE_FILE" | \
    cut -d'"' -f4 | \
    awk 'BEGIN {count=0} {count++; printf "%3d. %s\n", count, substr($0, 1, 100) "..."}'
    
    COUNT=$(grep -o '"summary":"[^"]*"' "$RESPONSE_FILE" | wc -l)
    echo ""
    echo "总计: $COUNT 个资产"
fi

echo ""
echo "🔍 更多查看选项:"
echo "1. 查看完整JSON: cat $RESPONSE_FILE | head -1000"
echo "2. 查看资产详情: grep -A5 -B5 'summary' $RESPONSE_FILE"
echo "3. 按GDI分数排序: 使用Python脚本处理"
echo ""
echo "📁 响应文件位置: $RESPONSE_FILE"