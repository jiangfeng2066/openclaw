#!/bin/bash

echo "💾 保存 EvoMap 资产到本地"
echo "========================"

# 创建资产目录
ASSET_DIR="$HOME/evomap_local_assets"
mkdir -p "$ASSET_DIR"

echo "资产将保存到: $ASSET_DIR"
echo ""

# 获取当前时间戳
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$ASSET_DIR/evomap_assets_$TIMESTAMP.json"

echo "🔄 正在获取资产..."
cd /root/.openclaw/workspace

# 获取资产并保存
if ./evomap_simple.sh fetch > "$OUTPUT_FILE"; then
    FILE_SIZE=$(wc -c < "$OUTPUT_FILE")
    ASSET_COUNT=$(grep -c '"summary":"' "$OUTPUT_FILE" 2>/dev/null || echo "0")
    
    echo ""
    echo "✅ 保存成功!"
    echo "   文件: $(basename "$OUTPUT_FILE")"
    echo "   大小: $FILE_SIZE 字节"
    echo "   资产数量: $ASSET_COUNT"
    echo "   路径: $OUTPUT_FILE"
    
    # 创建资产索引
    INDEX_FILE="$ASSET_DIR/INDEX.md"
    echo "# EvoMap 资产索引" > "$INDEX_FILE"
    echo "最后更新: $(date)" >> "$INDEX_FILE"
    echo "文件: $(basename "$OUTPUT_FILE")" >> "$INDEX_FILE"
    echo "资产数量: $ASSET_COUNT" >> "$INDEX_FILE"
    echo "" >> "$INDEX_FILE"
    echo "## 资产列表" >> "$INDEX_FILE"
    
    # 提取资产摘要到索引
    grep -o '"summary":"[^"]*"' "$OUTPUT_FILE" 2>/dev/null | \
      cut -d'"' -f4 | \
      awk '{print "1. " $0}' >> "$INDEX_FILE"
    
    echo ""
    echo "📋 资产索引已创建: $INDEX_FILE"
    
    # 显示前5个资产
    echo ""
    echo "📄 前5个资产:"
    grep -o '"summary":"[^"]*"' "$OUTPUT_FILE" 2>/dev/null | \
      head -5 | \
      cut -d'"' -f4 | \
      awk '{print "  • " substr($0, 1, 80) "..."}'
    
else
    echo "❌ 获取失败"
    exit 1
fi

echo ""
echo "🔍 查看命令:"
echo "  cat $OUTPUT_FILE | head -500          # 查看文件内容"
echo "  grep -c '\"summary\":' $OUTPUT_FILE   # 统计资产数量"
echo "  ls -la $ASSET_DIR/*.json              # 列出所有资产文件"
echo ""
echo "💡 提示: 资产以JSON格式保存，可以使用任何JSON工具查看"