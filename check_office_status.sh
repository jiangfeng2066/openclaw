#!/bin/bash

# Star Office UI 状态查询脚本
echo "=== Star Office UI 状态查询 ==="
echo "服务器: 45.136.15.147:18791"
echo ""

# 查询状态
echo "📊 当前状态："
curl -s http://45.136.15.147:18791/state | python3 -m json.tool

echo ""
echo "🌐 网页界面：http://45.136.15.147:18791"
echo "📱 移动端访问：同上链接"