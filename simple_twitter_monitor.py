#!/usr/bin/env python3
"""
简单 Twitter/X 账号监控脚本
每天自动检查指定账号的最新推文
"""

import os
import sys
import json
import time
from datetime import datetime
from pathlib import Path

def monitor_twitter_account(username):
    """
    监控单个 Twitter/X 账号
    
    Args:
        username: Twitter/X 用户名（不带@）
    
    Returns:
        dict: 监控结果
    """
    print(f"[{datetime.now()}] 开始监控 @{username}")
    
    # 设置路径
    memory_path = Path("/root/.openclaw/workspace/memory/twitter_monitor")
    memory_path.mkdir(parents=True, exist_ok=True)
    
    # 状态文件
    state_file = memory_path / f"{username}_state.json"
    
    # 加载或创建状态
    if state_file.exists():
        try:
            with open(state_file, 'r', encoding='utf-8') as f:
                state = json.load(f)
        except:
            state = {}
    else:
        state = {}
    
    # 更新状态
    state["last_check"] = datetime.now().isoformat()
    state["username"] = username
    state.setdefault("check_count", 0)
    state["check_count"] += 1
    
    # 执行监控（这里使用系统命令调用DeepReeder）
    profile_url = f"https://x.com/{username}"
    
    try:
        # 切换到 DeepReeder 目录并执行
        deepreader_dir = "/root/.openclaw/workspace/OpenClaw-DeepReeder"
        cmd = f"cd {deepreader_dir} && . .venv/bin/activate && python3 -c \"from deepreader_skill import run; result = run('检查 @{username} 最新动态: {profile_url}'); print('SUCCESS:' + result[:500])\""
        
        import subprocess
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        if result.returncode == 0:
            output = result.stdout
            if "SUCCESS:" in output:
                # 提取成功信息
                success_msg = output.split("SUCCESS:")[1].strip()
                state["last_success"] = datetime.now().isoformat()
                state.setdefault("success_count", 0)
                state["success_count"] += 1
                
                result_info = {
                    "success": True,
                    "message": "监控成功",
                    "output_preview": success_msg[:200] + "..." if len(success_msg) > 200 else success_msg,
                    "check_time": datetime.now().isoformat()
                }
            else:
                result_info = {
                    "success": False,
                    "message": "执行成功但未找到预期输出",
                    "error": output[-500:] if len(output) > 500 else output,
                    "check_time": datetime.now().isoformat()
                }
        else:
            result_info = {
                "success": False,
                "message": "执行失败",
                "error": result.stderr[-500:] if len(result.stderr) > 500 else result.stderr,
                "check_time": datetime.now().isoformat()
            }
            
    except Exception as e:
        result_info = {
            "success": False,
            "message": "监控异常",
            "error": str(e),
            "check_time": datetime.now().isoformat()
        }
    
    # 保存状态
    state["last_result"] = result_info
    with open(state_file, 'w', encoding='utf-8') as f:
        json.dump(state, f, ensure_ascii=False, indent=2)
    
    print(f"[{datetime.now()}] 监控完成: {'成功' if result_info['success'] else '失败'}")
    
    return result_info

def generate_report(username):
    """生成监控报告"""
    memory_path = Path("/root/.openclaw/workspace/memory/twitter_monitor")
    state_file = memory_path / f"{username}_state.json"
    
    if not state_file.exists():
        return "暂无监控数据"
    
    with open(state_file, 'r', encoding='utf-8') as f:
        state = json.load(f)
    
    report = f"""
=== Twitter/X 账号监控报告 ===
账号: @{username}
生成时间: {datetime.now().isoformat()}

📊 监控统计:
- 总检查次数: {state.get('check_count', 0)}
- 成功次数: {state.get('success_count', 0)}
- 最后成功: {state.get('last_success', '从未成功')}
- 最后检查: {state.get('last_check', '从未检查')}

📝 最近一次检查:
- 状态: {'✅ 成功' if state.get('last_result', {}).get('success') else '❌ 失败'}
- 时间: {state.get('last_result', {}).get('check_time', '无记录')}
- 信息: {state.get('last_result', {}).get('message', '无信息')}

💾 数据存储:
- 状态文件: {state_file}
- 记忆目录: /root/.openclaw/workspace/memory/inbox/
- 推文文件: 以日期和用户名命名的 .md 文件

🔄 建议:
1. 定期检查记忆目录中的新文件
2. 如需调整监控频率，请修改Cron配置
3. 如遇持续失败，请检查网络连接和账号状态
"""
    
    return report

def main():
    """主函数"""
    print("=" * 60)
    print("Twitter/X 账号监控系统")
    print("=" * 60)
    
    # 要监控的账号列表（可以在这里添加多个账号）
    accounts_to_monitor = ["AI_Jasonyu"]  # 示例账号
    
    all_results = []
    
    for account in accounts_to_monitor:
        print(f"\n📱 监控账号: @{account}")
        result = monitor_twitter_account(account)
        all_results.append({"account": account, "result": result})
        
        # 生成报告
        report = generate_report(account)
        print(report)
        
        # 保存报告
        report_file = Path("/root/.openclaw/workspace/memory/twitter_monitor") / f"{account}_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"📄 报告已保存: {report_file}")
        
        # 短暂等待，避免过于频繁的请求
        time.sleep(2)
    
    # 汇总结果
    print("\n" + "=" * 60)
    print("监控汇总:")
    print("=" * 60)
    
    success_count = sum(1 for r in all_results if r["result"].get("success"))
    total_count = len(all_results)
    
    print(f"✅ 成功: {success_count}/{total_count}")
    print(f"❌ 失败: {total_count - success_count}/{total_count}")
    
    for r in all_results:
        status = "✅" if r["result"].get("success") else "❌"
        print(f"{status} @{r['account']}: {r['result'].get('message', '无信息')}")

if __name__ == "__main__":
    main()