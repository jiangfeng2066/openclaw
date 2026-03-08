#!/bin/bash

echo "🔍 查看所有 EvoMap 资产"
echo "========================"
echo ""

echo "选择查看方式:"
echo "1. 简单列表 (快速)"
echo "2. 详细列表 (Python)"
echo "3. 保存到文件"
echo "4. 按页查看"
echo ""
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📋 简单资产列表:"
        echo "----------------"
        ./evomap_get_assets.sh
        ;;
    2)
        echo ""
        echo "📊 详细资产列表 (需要Python):"
        echo "---------------------------"
        if command -v python3 &> /dev/null; then
            python3 ./evomap_detailed_view.py
        else
            echo "❌ 需要 Python3，使用选项1或3"
            ./evomap_get_assets.sh
        fi
        ;;
    3)
        echo ""
        echo "💾 保存资产到文件:"
        echo "-----------------"
        FILENAME="evomap_all_assets_$(date +%Y%m%d_%H%M%S).json"
        ./evomap_simple.sh fetch > "$FILENAME"
        echo "✅ 已保存到: $FILENAME"
        echo "📏 文件大小: $(wc -c < "$FILENAME") 字节"
        echo "📄 行数: $(wc -l < "$FILENAME")"
        echo ""
        echo "查看前5个资产:"
        grep -o '"summary":"[^"]*"' "$FILENAME" | head -5 | cut -d'"' -f4 | awk '{print "  • " $0}'
        ;;
    4)
        echo ""
        echo "📄 按页查看资产:"
        echo "---------------"
        # 获取资产并分页显示
        TEMP_FILE="/tmp/evomap_assets_$$.txt"
        ./evomap_simple.sh fetch | grep -o '"summary":"[^"]*"' | cut -d'"' -f4 > "$TEMP_FILE"
        
        TOTAL=$(wc -l < "$TEMP_FILE")
        PAGE_SIZE=10
        PAGE=1
        TOTAL_PAGES=$(( (TOTAL + PAGE_SIZE - 1) / PAGE_SIZE ))
        
        while true; do
            echo ""
            echo "📖 第 $PAGE/$TOTAL_PAGES 页 (共 $TOTAL 个资产)"
            echo "----------------------------------------"
            
            START=$(( (PAGE - 1) * PAGE_SIZE + 1 ))
            END=$(( PAGE * PAGE_SIZE ))
            
            sed -n "${START},${END}p" "$TEMP_FILE" | awk '{printf "%3d. %s\n", NR+START-1, substr($0, 1, 80) "..."}'
            
            echo ""
            echo "导航: n=下一页, p=上一页, q=退出"
            read -p "操作: " nav
            
            case $nav in
                n|N)
                    if [ $PAGE -lt $TOTAL_PAGES ]; then
                        PAGE=$((PAGE + 1))
                    else
                        echo "已经是最后一页"
                    fi
                    ;;
                p|P)
                    if [ $PAGE -gt 1 ]; then
                        PAGE=$((PAGE - 1))
                    else
                        echo "已经是第一页"
                    fi
                    ;;
                q|Q)
                    break
                    ;;
                *)
                    echo "无效输入"
                    ;;
            esac
        done
        
        rm -f "$TEMP_FILE"
        ;;
    *)
        echo ""
        echo "使用默认方式: 简单列表"
        ./evomap_get_assets.sh
        ;;
esac

echo ""
echo "✅ 查看完成"