#!/usr/bin/env python3
"""
Twitter/X 账号监控脚本
自动检查指定账号的最新推文并保存到记忆
"""

import os
import sys
import json
import time
from datetime import datetime, timedelta
from pathlib import Path

# 添加 DeepReeder 路径
sys.path.insert(0, '/root/.openclaw/workspace/OpenClaw-DeepReeder')

# 激活虚拟环境
activate_script = '/root/.openclaw/workspace/OpenClaw-DeepReeder/.venv/bin/activate_this.py'
if os.path.exists(activate_script):
    with open(activate_script) as f:
        exec(f.read(), {'__file__': activate_script})

from deepreader_skill import run

class TwitterMonitor:
    def __init__(self, username, memory_path=None):
        """
        初始化监控器
        
        Args:
            username: Twitter/X 用户名（不带@）
            memory_path: 记忆保存路径
        """
        self.username = username.lstrip('@')
        self.profile_url = f"https://x.com/{self.username}"
        
        # 设置记忆路径
        if memory_path:
            self.memory_path = Path(memory_path)
        else:
            self.memory_path = Path("/root/.openclaw/workspace/memory/twitter_monitor")
        
        # 创建必要的目录
        self.memory_path.mkdir(parents=True, exist_ok=True)
        self.state_file = self.memory_path / f"{self.username}_state.json"
        
        # 加载状态
        self.state = self.load_state()
        
    def load_state(self):
        """加载监控状态"""
        if self.state_file.exists():
            try:
                with open(self.state_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                pass
        
        # 初始状态
        return {
            "username": self.username,
            "last_check": None,
            "last_tweet_id": None,
            "last_tweet_time": None,
            "total_checks": 0,
            "new_tweets_found": 0,
            "created_at": datetime.now().isoformat()
        }
    
    def save_state(self):
        """保存监控状态"""
        self.state["last_check"] = datetime.now().isoformat()
        with open(self.state_file, 'w', encoding='utf-8') as f:
            json.dump(self.state, f, ensure_ascii=False, indent=2)
    
    def check_profile(self):
        """检查账号主页，获取最新推文"""
        print(f"[{datetime.now()}] 检查 @{self.username} 的主页...")
        
        try:
            # 使用 DeepReeder 读取账号主页
            result = run(f"读取 @{self.username} 的最新推文: {self.profile_url}")
            
            # 解析结果（这里需要根据实际返回格式调整）
            # 实际实现中需要解析返回的推文列表
            
            self.state["total_checks"] += 1
            self.save_state()
            
            return {
                "success": True,
                "result": result[:500] + "..." if len(result) > 500 else result,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            print(f"检查失败: {e}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def check_specific_tweet(self, tweet_url):
        """检查特定推文"""
        print(f"[{datetime.now()}] 读取推文: {tweet_url}")
        
        try:
            result = run(f"读取推文: {tweet_url}")
            return {
                "success": True,
                "result": result,
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def generate_report(self):
        """生成监控报告"""
        report = {
            "username": self.username,
            "current_time": datetime.now().isoformat(),
            "state": self.state,
            "next_check": "建议1-3小时后再次检查"
        }
        
        return json.dumps(report, ensure_ascii=False, indent=2)

def main():
    """主函数 - 测试监控功能"""
    print("=== Twitter/X 账号监控测试 ===")
    
    # 测试账号（可以替换为您要监控的账号）
    test_usernames = ["AI_Jasonyu"]  # 示例账号
    
    for username in test_usernames:
        print(f"\n{'='*50}")
        print(f"测试监控: @{username}")
        print(f"{'='*50}")
        
        # 创建监控器
        monitor = TwitterMonitor(username)
        
        # 检查当前状态
        print(f"当前状态: {json.dumps(monitor.state, ensure_ascii=False, indent=2)}")
        
        # 执行检查
        result = monitor.check_profile()
        
        if result["success"]:
            print(f"✓ 检查成功")
            print(f"结果摘要: {result['result'][:200]}...")
        else:
            print(f"✗ 检查失败: {result['error']}")
        
        # 生成报告
        report = monitor.generate_report()
        print(f"\n监控报告:\n{report}")
        
        # 保存报告
        report_file = monitor.memory_path / f"{username}_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"报告已保存: {report_file}")

if __name__ == "__main__":
    main()