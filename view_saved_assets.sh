#!/bin/bash

echo "🔍 查看已保存的 EvoMap 资产"
echo "=========================="

ASSET_DIR="$HOME/evomap_local_assets"

if [ ! -d "$ASSET_DIR" ]; then
    echo "❌ 资产目录不存在"
    echo "请先运行: ./save_assets_simple.sh"
    exit 1
fi

echo "资产目录: $ASSET_DIR"
echo ""

# 列出所有资产文件
echo "📁 资产文件列表:"
ls -la "$ASSET_DIR"/*.json 2>/dev/null | awk '{print "  • " $9 " (" $5 " bytes)"}'

echo ""

# 选择文件查看
LATEST_FILE=$(ls -t "$ASSET_DIR"/*.json 2>/dev/null | head -1)

if [ -n "$LATEST_FILE" ]; then
    echo "📊 最新文件: $(basename "$LATEST_FILE")"
    FILE_SIZE=$(wc -c < "$LATEST_FILE")
    ASSET_COUNT=$(grep -c '"summary":"' "$LATEST_FILE" 2>/dev/null || echo "0")
    
    echo "   大小: $FILE_SIZE 字节"
    echo "   资产数量: $ASSET_COUNT"
    echo ""
    
    echo "选择查看方式:"
    echo "1. 查看资产列表"
    echo "2. 查看文件内容（前500字符）"
    echo "3. 统计资产类型"
    echo "4. 搜索特定资产"
    echo ""
    read -p "请输入选项 (1-4): " choice
    
    case $choice in
        1)
            echo ""
            echo "📋 资产列表:"
            grep -o '"summary":"[^"]*"' "$LATEST_FILE" 2>/dev/null | \
              cut -d'"' -f4 | \
              awk '{printf "%3d. %s\n", NR, substr($0, 1, 80) "..."}'
            ;;
        2)
            echo ""
            echo "📄 文件内容（前500字符）:"
            head -c 500 "$LATEST_FILE"
            echo -e "\n..."
            ;;
        3)
            echo ""
            echo "📊 资产类型统计:"
            echo "  Capsules: $(grep -c '"asset_type":"Capsule"' "$LATEST_FILE" 2>/dev/null || echo "0")"
            echo "  Genes: $(grep -c '"asset_type":"Gene"' "$LATEST_FILE" 2>/dev/null || echo "0")"
            echo "  Events: $(grep -c '"asset_type":"EvolutionEvent"' "$LATEST_FILE" 2>/dev/null || echo "0")"
            ;;
        4)
            echo ""
            read -p "请输入搜索关键词: " keyword
            echo "搜索: $keyword"
            grep -i "$keyword" "$LATEST_FILE" | grep -o '"summary":"[^"]*"' | \
              cut -d'"' -f4 | \
              head -10 | \
              awk '{print "  • " $0}'
            ;;
        *)
            echo "显示前10个资产:"
            grep -o '"summary":"[^"]*"' "$LATEST_FILE" 2>/dev/null | \
              head -10 | \
              cut -d'"' -f4 | \
              awk '{print "  • " substr($0, 1, 80) "..."}'
            ;;
    esac
else
    echo "ℹ️ 未找到资产文件"
    echo "请先运行: ./save_assets_simple.sh"
fi

echo ""
echo "💾 资产存储位置:"
echo "  $ASSET_DIR/"
echo ""
echo "📝 文件格式: JSON (可以使用 jq、python、文本编辑器查看)"