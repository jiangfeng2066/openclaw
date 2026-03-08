#!/usr/bin/env python3
"""
EvoMap 资产详细查看工具
显示所有资产的完整信息
"""

import json
import sys
import os
from datetime import datetime

def get_sender_id():
    """获取保存的 sender_id"""
    env_file = "/tmp/evomap_sender_id.env"
    if not os.path.exists(env_file):
        print("❌ 未找到节点 ID，请先运行: ./evomap_simple.sh hello")
        sys.exit(1)
    
    with open(env_file, 'r') as f:
        for line in f:
            if line.startswith("export E2A_SENDER_ID="):
                return line.split('"')[1]
    
    print("❌ 无法解析 sender_id")
    sys.exit(1)

def fetch_assets(sender_id):
    """从 EvoMap 获取资产"""
    import subprocess
    import uuid
    import time
    
    # 生成请求数据
    message_id = f"msg_{int(time.time())}_{uuid.uuid4().hex[:4]}"
    timestamp = datetime.utcnow().isoformat() + "Z"
    
    request_data = {
        "protocol": "gep-a2a",
        "protocol_version": "1.0.0",
        "message_type": "fetch",
        "message_id": message_id,
        "sender_id": sender_id,
        "timestamp": timestamp,
        "payload": {
            "asset_type": "Capsule",
            "include_tasks": False
        }
    }
    
    # 发送请求
    try:
        import requests
        response = requests.post(
            "https://evomap.ai/a2a/fetch",
            json=request_data,
            timeout=15
        )
        response.raise_for_status()
        return response.json()
    except ImportError:
        # 回退到 curl
        import tempfile
        import shutil
        
        # 创建临时文件
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            json.dump(request_data, f)
            temp_file = f.name
        
        try:
            # 使用 curl
            curl_cmd = [
                "curl", "-s", "-X", "POST",
                "https://evomap.ai/a2a/fetch",
                "-H", "Content-Type: application/json",
                "-d", f"@{temp_file}",
                "--max-time", "15"
            ]
            
            result = subprocess.run(curl_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"❌ curl 错误: {result.stderr}")
                sys.exit(1)
            
            return json.loads(result.stdout)
        finally:
            os.unlink(temp_file)
    except Exception as e:
        print(f"❌ 请求失败: {e}")
        sys.exit(1)

def display_assets(assets_data):
    """显示资产信息"""
    payload = assets_data.get('payload', {})
    results = payload.get('results', [])
    
    if not results:
        print("ℹ️  未找到资产")
        return
    
    print(f"📊 找到 {len(results)} 个资产")
    print("=" * 100)
    
    for i, asset in enumerate(results, 1):
        print(f"\n{'='*50}")
        print(f"资产 #{i}")
        print(f"{'='*50}")
        
        # 基本信息
        asset_id = asset.get('asset_id', 'N/A')
        asset_type = asset.get('asset_type', 'N/A')
        status = asset.get('status', 'N/A')
        confidence = asset.get('confidence', 0)
        gdi_score = asset.get('gdi_score', 0)
        source_node = asset.get('source_node_id', 'N/A')
        trigger_text = asset.get('trigger_text', 'N/A')
        
        # 嵌套的 payload
        inner_payload = asset.get('payload', {})
        summary = inner_payload.get('summary', '无描述')
        triggers = inner_payload.get('trigger', [])
        outcome = inner_payload.get('outcome', {})
        
        print(f"📦 类型: {asset_type}")
        print(f"🏷️  状态: {status}")
        print(f"📈 置信度: {confidence:.2f}")
        print(f"⭐ GDI分数: {gdi_score:.1f}")
        print(f"👤 来源节点: {source_node}")
        print(f"🎯 触发文本: {trigger_text}")
        
        if triggers:
            print(f"🔧 触发条件: {', '.join(triggers)}")
        
        if outcome:
            outcome_status = outcome.get('status', 'N/A')
            outcome_score = outcome.get('score', 0)
            print(f"✅ 结果: {outcome_status} (分数: {outcome_score:.2f})")
        
        print(f"\n📝 描述:")
        print(f"  {summary}")
        
        print(f"\n🔑 资产ID (前40字符):")
        print(f"  {asset_id[:40]}...")
        
        # 显示相关资产
        related_id = asset.get('related_asset_id')
        if related_id:
            print(f"\n🔗 相关资产: {related_id[:40]}...")
        
        bundle_id = asset.get('bundle_id')
        if bundle_id:
            print(f"📎 捆绑包ID: {bundle_id}")

def main():
    """主函数"""
    print("🔍 EvoMap 资产详细查看")
    print("=" * 50)
    
    # 获取 sender_id
    sender_id = get_sender_id()
    print(f"节点ID: {sender_id}")
    print("正在获取资产...")
    
    # 获取资产数据
    assets_data = fetch_assets(sender_id)
    
    # 显示资产
    display_assets(assets_data)
    
    print("\n" + "=" * 100)
    print("✅ 查看完成")
    
    # 保存选项
    save_file = f"evomap_assets_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    print(f"\n💾 保存到文件: {save_file}")
    with open(save_file, 'w') as f:
        json.dump(assets_data, f, indent=2, ensure_ascii=False)
    print(f"文件大小: {os.path.getsize(save_file)} 字节")

if __name__ == "__main__":
    main()