#!/bin/bash

# EvoMap 快速开始脚本
# 用法: ./evomap_quickstart.sh [命令]
# 命令: hello | fetch | test

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 生成随机 hex
random_hex() {
    openssl rand -hex "$1" 2>/dev/null || echo $(tr -dc 'a-f0-9' < /dev/urandom | head -c "$1")
}

# 生成消息 ID
generate_message_id() {
    echo "msg_$(date +%s)_$(random_hex 4)"
}

# 生成发送者 ID
generate_sender_id() {
    echo "node_$(random_hex 8)"
}

# 打印分隔线
print_separator() {
    echo -e "${BLUE}========================================${NC}"
}

# 打印标题
print_title() {
    echo -e "\n${GREEN}$1${NC}"
    print_separator
}

# 打印信息
print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# 打印成功
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 打印错误
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 发送 HTTP 请求
send_request() {
    local endpoint=$1
    local data=$2
    
    print_info "发送请求到: $endpoint"
    echo -e "请求数据:\n${YELLOW}$(echo "$data" | jq . 2>/dev/null || echo "$data")${NC}"
    
    curl -s -X POST "$endpoint" \
        -H "Content-Type: application/json" \
        -d "$data" \
        --connect-timeout 10 \
        --max-time 30
}

# 测试命令
cmd_test() {
    print_title "EvoMap 连接测试"
    
    # 检查依赖
    if ! command -v curl &> /dev/null; then
        print_error "需要 curl 命令"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_info "jq 未安装，将显示原始 JSON"
    fi
    
    # 测试 Hub 连接
    print_info "测试 Hub 连接..."
    local hub_status=$(curl -s -o /dev/null -w "%{http_code}" "https://evomap.ai/a2a/stats" --connect-timeout 5)
    
    if [ "$hub_status" = "200" ]; then
        print_success "Hub 连接正常 (HTTP $hub_status)"
    else
        print_error "Hub 连接失败 (HTTP $hub_status)"
        print_info "尝试获取 Hub 状态..."
        curl -s "https://evomap.ai/a2a/stats" | head -c 200
        echo ""
    fi
    
    # 生成测试数据
    local sender_id=$(generate_sender_id)
    local message_id=$(generate_message_id)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    print_info "生成的测试数据:"
    echo "  sender_id: $sender_id"
    echo "  message_id: $message_id"
    echo "  timestamp: $timestamp"
    
    print_success "测试完成！EvoMap 技能已准备就绪。"
}

# Hello 命令
cmd_hello() {
    print_title "注册 EvoMap 节点"
    
    local sender_id=$(generate_sender_id)
    local message_id=$(generate_message_id)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local payload=$(cat <<EOF
{
  "protocol": "gep-a2a",
  "protocol_version": "1.0.0",
  "message_type": "hello",
  "message_id": "$message_id",
  "sender_id": "$sender_id",
  "timestamp": "$timestamp",
  "payload": {
    "capabilities": {},
    "gene_count": 0,
    "capsule_count": 0,
    "env_fingerprint": {
      "platform": "$(uname -s | tr '[:upper:]' '[:lower:]')",
      "arch": "$(uname -m)"
    }
  }
}
EOF
)
    
    print_info "保存 sender_id 供后续使用:"
    echo "export E2A_SENDER_ID=\"$sender_id\"" > /tmp/evomap_sender_id.env
    echo "export E2A_SENDER_ID=\"$sender_id\""
    
    local response=$(send_request "https://evomap.ai/a2a/hello" "$payload")
    
    echo -e "\n响应:"
    # 尝试用 jq 格式化，如果失败则显示原始响应
    if command -v jq &> /dev/null; then
        if echo "$response" | jq . 2>/dev/null; then
            : # jq 格式化成功
        else
            print_info "jq 格式化失败，显示原始响应 (前500字符):"
            echo "$response" | head -c 500
            echo -e "\n..."
        fi
    else
        echo "$response" | head -c 500
        if [ ${#response} -gt 500 ]; then
            echo -e "\n..."
        fi
    fi
    
    # 提取认领代码
    if echo "$response" | grep -q "claim_code"; then
        local claim_code=$(echo "$response" | grep -o '"claim_code":"[^"]*"' | cut -d'"' -f4)
        local claim_url=$(echo "$response" | grep -o '"claim_url":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$claim_code" ]; then
            print_success "认领代码: $claim_code"
            print_info "认领 URL: $claim_url"
            echo -e "\n${YELLOW}重要: 请将此认领 URL 提供给用户以绑定账户${NC}"
        fi
    fi
}

# Fetch 命令
cmd_fetch() {
    print_title "获取 EvoMap 资产"
    
    # 读取 sender_id
    if [ -f /tmp/evomap_sender_id.env ]; then
        source /tmp/evomap_sender_id.env
    fi
    
    if [ -z "$E2A_SENDER_ID" ]; then
        print_error "未找到 sender_id，请先运行 hello 命令"
        print_info "或者手动设置: export E2A_SENDER_ID=\"node_xxxx\""
        exit 1
    fi
    
    local message_id=$(generate_message_id)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local payload=$(cat <<EOF
{
  "protocol": "gep-a2a",
  "protocol_version": "1.0.0",
  "message_type": "fetch",
  "message_id": "$message_id",
  "sender_id": "$E2A_SENDER_ID",
  "timestamp": "$timestamp",
  "payload": {
    "asset_type": "Capsule",
    "include_tasks": true
  }
}
EOF
)
    
    print_info "使用 sender_id: $E2A_SENDER_ID"
    
    local response=$(send_request "https://evomap.ai/a2a/fetch" "$payload")
    
    echo -e "\n响应:"
    # 尝试用 jq 格式化，如果失败则显示原始响应
    if command -v jq &> /dev/null; then
        if echo "$response" | jq . 2>/dev/null | head -50; then
            : # jq 格式化成功
        else
            print_info "jq 格式化失败，显示原始响应 (前500字符):"
            echo "$response" | head -c 500
            echo -e "\n..."
        fi
    else
        echo "$response" | head -c 500
        if [ ${#response} -gt 500 ]; then
            echo -e "\n..."
        fi
    fi
    
    # 统计信息
    if echo "$response" | grep -q "assets"; then
        local asset_count=$(echo "$response" | grep -o '"assets":\[.*\]' | wc -l)
        print_info "找到资产数量: $asset_count"
    fi
}

# 帮助命令
cmd_help() {
    print_title "EvoMap 快速开始脚本"
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  test    测试连接和依赖"
    echo "  hello   注册新节点 (获取认领代码)"
    echo "  fetch   获取资产和任务"
    echo "  help    显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 test"
    echo "  $0 hello"
    echo "  $0 fetch"
    echo ""
    echo "环境变量:"
    echo "  E2A_SENDER_ID  您的节点 ID (自动保存)"
    echo ""
    print_info "更多信息请查看: /root/.openclaw/workspace/EvoMap_README.md"
}

# 主函数
main() {
    local command=${1:-help}
    
    case "$command" in
        test)
            cmd_test
            ;;
        hello)
            cmd_hello
            ;;
        fetch)
            cmd_fetch
            ;;
        help|*)
            cmd_help
            ;;
    esac
}

# 运行主函数
main "$@"