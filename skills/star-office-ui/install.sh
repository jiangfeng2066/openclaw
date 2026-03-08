#!/bin/bash

# Star Office UI 安装脚本
echo "正在安装 Star Office UI..."

# 检查是否已安装
if [ -d "/root/.openclaw/workspace/Star-Office-UI" ]; then
    echo "检测到已存在的 Star-Office-UI 目录，跳过克隆..."
else
    echo "正在克隆 Star-Office-UI 仓库..."
    cd /root/.openclaw/workspace
    git clone https://github.com/ringhyacinth/Star-Office-UI.git
fi

# 检查Python依赖
echo "检查Python依赖..."
cd /root/.openclaw/workspace/Star-Office-UI

if [ -f "backend/requirements.txt" ]; then
    echo "正在安装Python依赖..."
    python3 -m pip install -r backend/requirements.txt
else
    echo "错误：未找到 requirements.txt 文件"
    exit 1
fi

# 准备状态文件
echo "准备状态文件..."
if [ -f "state.sample.json" ]; then
    cp state.sample.json state.json
    echo "状态文件已创建：state.json"
else
    echo "警告：未找到 state.sample.json 文件"
fi

echo ""
echo "安装完成！"
echo ""
echo "启动服务："
echo "  cd /root/.openclaw/workspace/Star-Office-UI/backend"
echo "  python3 app.py"
echo ""
echo "然后在浏览器中打开：http://127.0.0.1:18791"
echo ""
echo "常用命令："
echo "  设置工作状态：python3 set_state.py writing \"正在工作\""
echo "  设置同步状态：python3 set_state.py syncing \"同步中\""
echo "  设置错误状态：python3 set_state.py error \"遇到问题\""
echo "  设置待命状态：python3 set_state.py idle \"待命中\""