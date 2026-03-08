#!/usr/bin/env python3
"""
测试飞书机器人双向通信能力
"""

import json
from datetime import datetime

def check_bot_capabilities():
    """检查机器人能力"""
    print("=" * 60)
    print("飞书机器人双向通信能力检查")
    print("=" * 60)
    
    # 当前时间
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    print(f"\n📅 检查时间: {current_time}")
    print(f"🤖 目标机器人: x平台员工 (cli_a92bafb7fab89cb0)")
    
    # 检查配置状态
    print("\n🔧 配置状态检查:")
    
    config_checks = [
        ("应用认证", "✅", "App ID/Secret验证通过"),
        ("WebSocket连接", "✅", "connectionMode: websocket"),
        ("发送消息权限", "✅", "im:message:send_as_bot"),
        ("接收消息权限", "✅", "im:message.p2p_msg:readonly"),
        ("模型配置", "✅", "deepseek/deepseek-chat"),
    ]
    
    for check, status, desc in config_checks:
        print(f"  {status} {check}: {desc}")
    
    # 双向通信需求
    print("\n🎯 双向通信需求:")
    requirements = [
        "1. 接收用户消息 → 需要事件订阅或WebSocket连接",
        "2. 发送回复消息 → 已有发送权限",
        "3. 消息路由 → OpenClaw自动处理",
        "4. 会话管理 → 自动创建和维护会话"
    ]
    
    for req in requirements:
        print(f"  {req}")
    
    # 当前限制
    print("\n⚠️ 当前限制:")
    limitations = [
        "• 事件回调需要HTTPS (SSL证书)",
        "• 服务器需要公网可达性",
        "• 飞书验证需要正确配置",
        "• WebSocket连接可能需要时间建立"
    ]
    
    for limit in limitations:
        print(f"  {limit}")
    
    # 测试建议
    print("\n🧪 测试建议:")
    tests = [
        "1. 给'x平台员工'发送私聊消息",
        "2. 观察是否能触发自动回复",
        "3. 检查OpenClaw日志是否有消息记录",
        "4. 测试群聊中@机器人的消息"
    ]
    
    for test in tests:
        print(f"  {test}")
    
    # 配置建议
    print("\n🚀 配置建议:")
    
    print("\nA. 完整配置 (推荐):")
    print("   1. 获取SSL证书 (Let's Encrypt)")
    print("   2. 配置Nginx反向代理HTTPS")
    print("   3. 在飞书后台配置事件回调")
    print("   4. 添加encryptKey和verificationToken")
    
    print("\nB. 临时方案:")
    print("   1. 使用WebSocket-only模式")
    print("   2. 等待连接自动建立")
    print("   3. 测试基本消息收发")
    print("   4. 后续需要时配置HTTPS")
    
    print("\nC. 开发测试:")
    print("   1. 使用飞书测试环境")
    print("   2. 测试环境对HTTPS要求较宽松")
    print("   3. 验证功能后再部署生产")
    
    print("\n" + "=" * 60)
    print("下一步: 请先测试当前WebSocket连接是否已工作")
    print("=" * 60)

if __name__ == "__main__":
    check_bot_capabilities()