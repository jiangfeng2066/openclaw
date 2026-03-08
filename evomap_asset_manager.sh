#!/bin/bash

# EvoMap 资产管理脚本
ASSETS_DIR="/root/evomap_assets"
CAPSULES_DIR="$ASSETS_DIR/capsules"
GENES_DIR="$ASSETS_DIR/genes"
EVENTS_DIR="$ASSETS_DIR/events"
METADATA_FILE="$ASSETS_DIR/metadata.json"

echo "📦 EvoMap 资产管理系统"
echo "========================"

init_directories() {
    echo "初始化目录结构..."
    mkdir -p "$CAPSULES_DIR" "$GENES_DIR" "$EVENTS_DIR"
    
    # 创建初始元数据
    if [ ! -f "$METADATA_FILE" ]; then
        cat > "$METADATA_FILE" << EOF
{
  "last_update": "$(date -Iseconds)",
  "total_assets": 0,
  "asset_types": {
    "capsules": 0,
    "genes": 0,
    "events": 0
  },
  "sources": []
}
EOF
    fi
    echo "✅ 目录已初始化: $ASSETS_DIR"
}

fetch_and_save() {
    echo ""
    echo "🔄 从 EvoMap 获取并保存资产..."
    
    # 获取 sender_id
    if [ ! -f /tmp/evomap_sender_id.env ]; then
        echo "❌ 请先注册节点"
        return 1
    fi
    
    source /tmp/evomap_sender_id.env
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    RESPONSE_FILE="$ASSETS_DIR/raw/response_$TIMESTAMP.json"
    
    mkdir -p "$ASSETS_DIR/raw"
    
    # 获取资产
    echo "正在获取资产..."
    ./evomap_simple.sh fetch > "$RESPONSE_FILE"
    
    if [ ! -s "$RESPONSE_FILE" ]; then
        echo "❌ 获取失败"
        return 1
    fi
    
    echo "✅ 原始响应保存到: $RESPONSE_FILE"
    
    # 提取并保存单个资产
    extract_assets "$RESPONSE_FILE"
}

extract_assets() {
    local response_file="$1"
    echo ""
    echo "📄 提取资产文件..."
    
    # 使用 Python 提取（如果可用）
    if command -v python3 &> /dev/null; then
        python3 << EOF
import json
import os
import hashlib

with open('$response_file', 'r') as f:
    data = json.load(f)

results = data.get('payload', {}).get('results', [])
print(f"找到 {len(results)} 个资产")

for i, asset in enumerate(results):
    asset_type = asset.get('asset_type', 'unknown').lower()
    asset_id = asset.get('asset_id', '').replace('sha256:', '')[:16]
    summary = asset.get('payload', {}).get('summary', 'no_summary')
    
    # 创建文件名
    safe_summary = ''.join(c if c.isalnum() else '_' for c in summary[:50])
    filename = f"{asset_type}_{asset_id}_{safe_summary}.json"
    
    # 确定保存目录
    if asset_type == 'capsule':
        save_dir = '$CAPSULES_DIR'
    elif asset_type == 'gene':
        save_dir = '$GENES_DIR'
    elif asset_type == 'evolutionevent':
        save_dir = '$EVENTS_DIR'
    else:
        save_dir = '$ASSETS_DIR/other'
        os.makedirs(save_dir, exist_ok=True)
    
    # 保存资产
    filepath = os.path.join(save_dir, filename)
    with open(filepath, 'w') as f:
        json.dump(asset, f, indent=2, ensure_ascii=False)
    
    print(f"  ✅ 保存: {filename}")

print(f"\\n资产已保存到:")
print(f"  Capsules: $CAPSULES_DIR")
print(f"  Genes: $GENES_DIR")
print(f"  Events: $EVENTS_DIR")
EOF
    else
        # 简单版本：只保存原始响应
        echo "ℹ️ 需要 Python3 来提取单个资产"
        echo "原始响应已保存到: $response_file"
    fi
    
    update_metadata "$response_file"
}

update_metadata() {
    local response_file="$1"
    echo ""
    echo "📊 更新元数据..."
    
    # 简单计数
    capsule_count=$(find "$CAPSULES_DIR" -name "*.json" 2>/dev/null | wc -l)
    gene_count=$(find "$GENES_DIR" -name "*.json" 2>/dev/null | wc -l)
    event_count=$(find "$EVENTS_DIR" -name "*.json" 2>/dev/null | wc -l)
    total=$((capsule_count + gene_count + event_count))
    
    # 更新元数据文件
    cat > "$METADATA_FILE" << EOF
{
  "last_update": "$(date -Iseconds)",
  "total_assets": $total,
  "asset_types": {
    "capsules": $capsule_count,
    "genes": $gene_count,
    "events": $event_count
  },
  "last_fetch": "$(date -Iseconds)",
  "fetch_file": "$(basename "$response_file")",
  "storage_path": "$ASSETS_DIR"
}
EOF
    
    echo "✅ 元数据已更新"
    echo "   总计资产: $total"
    echo "   Capsules: $capsule_count"
    echo "   Genes: $gene_count"
    echo "   Events: $event_count"
}

list_assets() {
    echo ""
    echo "📋 本地资产列表"
    echo "================"
    
    if [ -f "$METADATA_FILE" ]; then
        echo "📊 统计信息:"
        grep -E "(last_update|total_assets)" "$METADATA_FILE"
        echo ""
    fi
    
    echo "Capsules 目录 ($CAPSULES_DIR):"
    ls -1 "$CAPSULES_DIR"/*.json 2>/dev/null | head -5 | xargs -I{} basename {} | awk '{print "  • " $0}'
    echo ""
    
    echo "最近获取的资产摘要:"
    find "$CAPSULES_DIR" -name "*.json" -exec sh -c 'grep -h "summary" "$1" | head -1 | cut -d: -f2-' _ {} \; 2>/dev/null | head -3 | awk '{print "  • " substr($0, 1, 80) "..."}'
}

clean_old_assets() {
    echo ""
    echo "🧹 清理旧资产..."
    
    # 保留最近7天的原始响应
    find "$ASSETS_DIR/raw" -name "*.json" -mtime +7 -delete 2>/dev/null
    
    echo "✅ 已清理7天前的原始响应"
}

show_help() {
    echo ""
    echo "使用方法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  init     初始化目录结构"
    echo "  fetch    获取并保存资产"
    echo "  list     列出本地资产"
    echo "  clean    清理旧资产"
    echo "  help     显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 init      # 首次使用"
    echo "  $0 fetch     # 获取资产"
    echo "  $0 list      # 查看资产"
    echo ""
    echo "资产存储位置: $ASSETS_DIR"
}

# 主逻辑
case "${1:-help}" in
    init)
        init_directories
        ;;
    fetch)
        init_directories
        fetch_and_save
        ;;
    list)
        init_directories
        list_assets
        ;;
    clean)
        init_directories
        clean_old_assets
        ;;
    help|*)
        show_help
        ;;
esac

echo ""
echo "🏁 完成"