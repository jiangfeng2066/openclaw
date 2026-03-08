#!/bin/bash

# EvoMap Fetch 美化显示脚本

echo "=== EvoMap 资产获取 ==="
echo ""

# 读取 sender_id
if [ -f /tmp/evomap_sender_id.env ]; then
    source /tmp/evomap_sender_id.env
    echo "使用节点 ID: $E2A_SENDER_ID"
else
    echo "错误: 未找到节点 ID，请先运行注册命令"
    echo "运行: ./evomap_simple.sh hello"
    exit 1
fi

echo ""

# 生成随机 hex
random_hex() {
    tr -dc 'a-f0-9' < /dev/urandom | head -c "$1"
}

# 生成消息 ID
generate_message_id() {
    echo "msg_$(date +%s)_$(random_hex 4)"
}

MESSAGE_ID=$(generate_message_id)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

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

echo "正在获取资产和任务..."
echo ""

# 发送请求
RESPONSE=$(curl -s -X POST https://evomap.ai/a2a/fetch \
  -H "Content-Type: application/json" \
  -d "$REQUEST_JSON")

# 检查响应是否有效
if [ -z "$RESPONSE" ]; then
    echo "错误: 未收到响应"
    exit 1
fi

# 提取 payload 部分
PAYLOAD=$(echo "$RESPONSE" | grep -o '"payload":{.*}' | sed 's/"payload"://')

if [ -z "$PAYLOAD" ]; then
    echo "错误: 无法解析响应"
    echo "原始响应:"
    echo "$RESPONSE" | head -c 500
    exit 1
fi

# 检查是否有 results
if echo "$PAYLOAD" | grep -q '"results":\[{'; then
    echo "✅ 成功获取到资产!"
    echo ""
    
    # 提取 results 数组
    RESULTS=$(echo "$PAYLOAD" | sed 's/.*"results":\[//' | sed 's/\].*//')
    
    # 分割每个资产
    IFS='},{' read -ra ASSETS <<< "$RESULTS"
    
    COUNT=0
    for ASSET in "${ASSETS[@]}"; do
        # 清理资产字符串
        CLEAN_ASSET="{$ASSET}"
        CLEAN_ASSET=$(echo "$CLEAN_ASSET" | sed 's/^,//' | sed 's/,$//')
        
        # 提取关键信息
        ASSET_ID=$(echo "$CLEAN_ASSET" | grep -o '"asset_id":"[^"]*"' | cut -d'"' -f4 | head -c 20)
        ASSET_TYPE=$(echo "$CLEAN_ASSET" | grep -o '"asset_type":"[^"]*"' | cut -d'"' -f4)
        STATUS=$(echo "$CLEAN_ASSET" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        CONFIDENCE=$(echo "$CLEAN_ASSET" | grep -o '"confidence":[0-9.]*' | cut -d':' -f2)
        GDI_SCORE=$(echo "$CLEAN_ASSET" | grep -o '"gdi_score":[0-9.]*' | cut -d':' -f2)
        TRIGGER_TEXT=$(echo "$CLEAN_ASSET" | grep -o '"trigger_text":"[^"]*"' | cut -d'"' -f4)
        
        # 从 payload 中提取 summary
        SUMMARY=$(echo "$CLEAN_ASSET" | grep -o '"summary":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$ASSET_ID" ] && [ -n "$SUMMARY" ]; then
            COUNT=$((COUNT + 1))
            echo "🔹 资产 #$COUNT"
            echo "   类型: $ASSET_TYPE"
            echo "   状态: $STATUS"
            echo "   资产ID: ${ASSET_ID}..."
            if [ -n "$CONFIDENCE" ]; then
                echo "   置信度: $CONFIDENCE"
            fi
            if [ -n "$GDI_SCORE" ]; then
                echo "   GDI分数: $GDI_SCORE"
            fi
            if [ -n "$TRIGGER_TEXT" ]; then
                echo "   触发条件: $TRIGGER_TEXT"
            fi
            echo "   描述: $SUMMARY"
            echo ""
        fi
    done
    
    if [ $COUNT -eq 0 ]; then
        echo "⚠️  未找到资产详情"
    else
        echo "总计: $COUNT 个资产"
    fi
else
    echo "ℹ️  未找到资产结果"
fi

echo ""

# 检查是否有任务
if echo "$PAYLOAD" | grep -q '"tasks":\[{'; then
    echo "📋 可用任务:"
    echo ""
    
    # 提取 tasks 数组
    TASKS=$(echo "$PAYLOAD" | sed 's/.*"tasks":\[//' | sed 's/\].*//')
    
    # 分割每个任务
    IFS='},{' read -ra TASK_ARRAY <<< "$TASKS"
    
    TASK_COUNT=0
    for TASK in "${TASK_ARRAY[@]}"; do
        # 清理任务字符串
        CLEAN_TASK="{$TASK}"
        CLEAN_TASK=$(echo "$CLEAN_TASK" | sed 's/^,//' | sed 's/,$//')
        
        # 提取关键信息
        TASK_ID=$(echo "$CLEAN_TASK" | grep -o '"task_id":"[^"]*"' | cut -d'"' -f4)
        TITLE=$(echo "$CLEAN_TASK" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
        STATUS=$(echo "$CLEAN_TASK" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$TASK_ID" ] && [ -n "$TITLE" ]; then
            TASK_COUNT=$((TASK_COUNT + 1))
            echo "🎯 任务 #$TASK_COUNT"
            echo "   ID: $TASK_ID"
            echo "   标题: $TITLE"
            echo "   状态: $STATUS"
            echo ""
        fi
    done
    
    if [ $TASK_COUNT -eq 0 ]; then
        echo "暂无可用任务"
    else
        echo "总计: $TASK_COUNT 个任务"
    fi
else
    echo "ℹ️  未找到任务"
fi

echo ""
echo "=== 完成 ==="