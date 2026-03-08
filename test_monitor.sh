#!/bin/bash
# Twitter/X 监控测试脚本

echo "=== Twitter/X 账号监控测试 ==="
echo "测试时间: $(date)"
echo ""

# 进入 DeepReeder 目录并激活虚拟环境
cd /root/.openclaw/workspace/OpenClaw-DeepReeder
source .venv/bin/activate

# 测试账号
USERNAME="AI_Jasonyu"
PROFILE_URL="https://x.com/$USERNAME"

echo "测试监控账号: @$USERNAME"
echo "账号URL: $PROFILE_URL"
echo ""

# 测试读取账号主页
echo "1. 测试读取账号主页..."
python3 -c "
from deepreader_skill import run
import datetime

print('开始时间:', datetime.datetime.now())
try:
    result = run('检查 @$USERNAME 的最新推文: $PROFILE_URL')
    print('✓ 读取成功')
    print('结果长度:', len(result), '字符')
    print('结果前200字符:', result[:200] + '...' if len(result) > 200 else result)
except Exception as e:
    print('✗ 读取失败:', e)
"

echo ""
echo "2. 测试读取特定推文..."
TWEET_URL="https://x.com/AI_Jasonyu/status/2025949471591506323"
python3 -c "
from deepreader_skill import run
import datetime

print('开始时间:', datetime.datetime.now())
try:
    result = run('读取推文: $TWEET_URL')
    print('✓ 读取成功')
    # 提取关键信息
    if 'Saved to:' in result:
        import re
        match = re.search(r'Saved to: (.*?)$', result, re.MULTILINE)
        if match:
            print('保存位置:', match.group(1))
except Exception as e:
    print('✗ 读取失败:', e)
"

echo ""
echo "=== 测试完成 ==="
echo "完成时间: $(date)"