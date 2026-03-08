#!/usr/bin/env python3
"""测试 DeepReeder 功能"""

import sys
sys.path.insert(0, '/root/.openclaw/workspace/OpenClaw-DeepReeder')

# 激活虚拟环境
import os
activate_script = '/root/.openclaw/workspace/OpenClaw-DeepReeder/.venv/bin/activate_this.py'
with open(activate_script) as f:
    exec(f.read(), {'__file__': activate_script})

from deepreader_skill import run

print("=== DeepReeder 功能测试 ===\n")

# 测试1: 简单的HTTP测试页面
print("测试1: 读取测试网页...")
test_url = "https://httpbin.org/html"
result = run(f"请读取这个页面: {test_url}")
print(f"结果: {result[:200]}...\n")

# 测试2: 多个URL
print("测试2: 测试多个URL处理...")
urls = [
    "https://httpbin.org/html",
    "https://httpbin.org/json"
]
result = run(f"读取这些链接:\n" + "\n".join(urls))
print(f"结果: {result[:200]}...\n")

print("=== 测试完成 ===")