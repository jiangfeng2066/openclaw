#!/bin/bash

echo "🔍 EvoMap 资产查看选项"
echo "========================"
echo ""

echo "1. 📋 查看完整资产列表 (带编号)"
echo "   ./evomap_list_all.sh"
echo ""

echo "2. 🎯 查看资产摘要 (简洁版)"
echo "   ./evomap_get_assets.sh"
echo ""

echo "3. 📊 按GDI分数排序查看"
echo "   ./evomap_sort_by_gdi.sh"
echo ""

echo "4. 🔧 查看特定类型资产"
echo "   ./evomap_filter_by_type.sh [类型]"
echo "   类型可选: Capsule, Gene, EvolutionEvent"
echo ""

echo "5. 📄 保存原始响应到文件"
echo "   ./evomap_save_response.sh [文件名]"
echo ""

echo "6. 🚀 一次性查看所有命令"
echo "   ./evomap_all_commands.sh"
echo ""

echo "选择选项 (1-6) 或输入命令编号: "
read -r choice

case $choice in
    1)
        chmod +x /root/.openclaw/workspace/evomap_list_all.sh
        /root/.openclaw/workspace/evomap_list_all.sh
        ;;
    2)
        /root/.openclaw/workspace/evomap_get_assets.sh
        ;;
    3)
        echo "创建排序脚本..."
        cat > /root/.openclaw/workspace/evomap_sort_by_gdi.sh << 'EOF'
#!/bin/bash
echo "按GDI分数排序需要Python支持"
echo "请先运行: ./evomap_list_all.sh"
EOF
        chmod +x /root/.openclaw/workspace/evomap_sort_by_gdi.sh
        /root/.openclaw/workspace/evomap_sort_by_gdi.sh
        ;;
    4)
        echo "创建过滤脚本..."
        cat > /root/.openclaw/workspace/evomap_filter_by_type.sh << 'EOF'
#!/bin/bash
if [ -z "$1" ]; then
    echo "用法: $0 [类型]"
    echo "类型: Capsule, Gene, EvolutionEvent"
    exit 1
fi
echo "过滤 $1 类型资产..."
echo "请先运行: ./evomap_list_all.sh | grep '$1'"
EOF
        chmod +x /root/.openclaw/workspace/evomap_filter_by_type.sh
        /root/.openclaw/workspace/evomap_filter_by_type.sh "$2"
        ;;
    5)
        echo "创建保存脚本..."
        cat > /root/.openclaw/workspace/evomap_save_response.sh << 'EOF'
#!/bin/bash
FILE=${1:-"evomap_response_$(date +%Y%m%d_%H%M%S).json"}
echo "保存响应到: $FILE"
./evomap_simple.sh fetch > "$FILE"
echo "✅ 已保存到: $FILE"
echo "文件大小: $(wc -c < "$FILE") 字节"
EOF
        chmod +x /root/.openclaw/workspace/evomap_save_response.sh
        /root/.openclaw/workspace/evomap_save_response.sh "$2"
        ;;
    6)
        echo "创建所有命令脚本..."
        cat > /root/.openclaw/workspace/evomap_all_commands.sh << 'EOF'
#!/bin/bash
echo "=== 所有 EvoMap 命令 ==="
echo ""
echo "1. 注册节点: ./evomap_simple.sh hello"
echo "2. 获取资产: ./evomap_simple.sh fetch"
echo "3. 测试连接: ./evomap_simple.sh test"
echo "4. 查看列表: ./evomap_list_all.sh"
echo "5. 资产摘要: ./evomap_get_assets.sh"
echo "6. 保存响应: ./evomap_save_response.sh [文件名]"
echo "7. 状态检查: ./evomap_check.sh"
echo ""
echo "快速开始:"
echo "  cd /root/.openclaw/workspace"
echo "  ./evomap_list_all.sh"
EOF
        chmod +x /root/.openclaw/workspace/evomap_all_commands.sh
        /root/.openclaw/workspace/evomap_all_commands.sh
        ;;
    *)
        echo "使用默认选项: 查看完整资产列表"
        chmod +x /root/.openclaw/workspace/evomap_list_all.sh
        /root/.openclaw/workspace/evomap_list_all.sh
        ;;
esac