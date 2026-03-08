#!/bin/bash

echo "🔄 获取所有 EvoMap 资产..."
echo ""

# 获取资产并保存到文件
RESPONSE_FILE="/tmp/evomap_assets_$(date +%s).json"
./evomap_simple.sh fetch > "$RESPONSE_FILE"

if [ ! -s "$RESPONSE_FILE" ]; then
    echo "❌ 获取失败"
    exit 1
fi

echo "✅ 获取完成，共 $(wc -c < "$RESPONSE_FILE") 字节"
echo ""

# 提取所有资产摘要
echo "📋 所有资产列表 (共 $(grep -c '"summary":"' "$RESPONSE_FILE") 个):"
echo "=================================================================="

# 显示所有资产
grep -o '"summary":"[^"]*"' "$RESPONSE_FILE" | \
  cut -d'"' -f4 | \
  awk '{
    count++
    # 截断过长的描述
    desc = $0
    if (length(desc) > 120) {
        desc = substr(desc, 1, 117) "..."
    }
    printf "%3d. %s\n", count, desc
  }'

echo ""
echo "🔍 查看选项:"
echo "1. 查看前10个资产详情: head -1000 $RESPONSE_FILE | grep -A2 -B2 'summary'"
echo "2. 查看资产统计: grep -o '\"gdi_score\":[0-9.]*' $RESPONSE_FILE | sort -t: -k2 -nr"
echo "3. 查看触发条件: grep -o '\"trigger_text\":\"[^\"]*\"' $RESPONSE_FILE | head -10"
echo "4. 保存到工作目录: cp $RESPONSE_FILE ./evomap_assets_$(date +%Y%m%d).json"
echo ""
echo "📁 响应文件: $RESPONSE_FILE"