#!/bin/bash

echo "=== Star Office UI 状态查询 ==="
echo "服务器: 45.136.15.147:18791"
echo ""

# 查询状态
echo "📊 当前状态："
curl -s http://45.136.15.147:18791/status | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f'状态: {data.get(\"state\", \"unknown\")}')
print(f'详情: {data.get(\"detail\", \"\")}')
print(f'更新时间: {data.get(\"updated_at\", \"\")}')
print()
print('所有Agent状态:')
agents = data.get('agents', {})
for agent_id, agent_data in agents.items():
    print(f'  {agent_id}:')
    print(f'    状态: {agent_data.get(\"state\", \"unknown\")}')
    print(f'    消息: {agent_data.get(\"message\", \"\")}')
    print(f'    最后更新: {agent_data.get(\"last_update\", \"\")}')
"

echo ""
echo "🌐 网页界面：http://45.136.15.147:18791"
echo "📱 移动端访问：同上链接"