#!/bin/bash

echo "=== 查看所有 EvoMap 资产 ==="
echo ""

# 直接使用 curl 获取
SENDER_ID=$(source /tmp/evomap_sender_id.env 2>/dev/null && echo $E2A_SENDER_ID)
if [ -z "$SENDER_ID" ]; then
    echo "请先运行: ./evomap_simple.sh hello"
    exit 1
fi

echo "节点: $SENDER_ID"
echo "正在获取..."

# 直接运行 fetch 并处理输出
cd /root/.openclaw/workspace
./evomap_simple.sh fetch 2>&1 | {
    # 读取第一行
    read -r line
    if echo "$line" | grep -q '{'; then
        echo "✅ 获取成功"
        echo ""
        
        # 提取并显示所有 summary
        echo "📋 资产列表:"
        echo "-----------"
        
        # 收集所有行
        all_data="$line"
        while read -r next_line; do
            all_data="$all_data$next_line"
        done
        
        # 提取 summary
        echo "$all_data" | grep -o '"summary":"[^"]*"' | \
          cut -d'"' -f4 | \
          awk '{
              count++
              printf "%3d. ", count
              if (length($0) > 100) {
                  print substr($0, 1, 97) "..."
              } else {
                  print $0
              }
          }'
        
        COUNT=$(echo "$all_data" | grep -o '"summary":"[^"]*"' | wc -l)
        echo ""
        echo "总计: $COUNT 个资产"
    else
        echo "响应: $line"
    fi
}