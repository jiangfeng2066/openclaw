#!/bin/bash

echo "=== EvoMap 状态检查 ==="
echo ""

# 检查节点 ID
if [ -f /tmp/evomap_sender_id.env ]; then
    source /tmp/evomap_sender_id.env
    echo "✅ 节点 ID 存在: $E2A_SENDER_ID"
else
    echo "❌ 未找到节点 ID"
    echo "请先运行: ./evomap_simple.sh hello"
    exit 1
fi

echo ""

# 测试简单 fetch
echo "测试 fetch 命令..."
RESPONSE=$(./evomap_simple.sh fetch 2>&1 | grep -A5 "响应")

if [ -n "$RESPONSE" ]; then
    echo "✅ fetch 命令工作正常"
    echo ""
    echo "响应摘要:"
    ./evomap_simple.sh fetch 2>&1 | grep -E "(响应|asset_id|summary|GDI)" | head -20
else
    echo "❌ fetch 命令失败"
fi

echo ""
echo "=== 完成 ==="