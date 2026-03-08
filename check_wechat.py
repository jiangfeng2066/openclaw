#!/usr/bin/env python3
"""
检查微信公众号文章访问情况
"""

import requests
from urllib.parse import urlparse, parse_qs

def check_wechat_article(url):
    """检查微信文章访问状态"""
    print(f"检查微信文章: {url}")
    print("=" * 60)
    
    try:
        # 设置请求头，模拟浏览器
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
        }
        
        # 发送请求
        response = requests.get(url, headers=headers, allow_redirects=False, timeout=10)
        
        print(f"状态码: {response.status_code}")
        print(f"响应头:")
        for key, value in response.headers.items():
            if key.lower() in ['location', 'content-type', 'set-cookie']:
                print(f"  {key}: {value}")
        
        # 检查重定向
        if response.status_code == 302:
            location = response.headers.get('Location', '')
            print(f"\n重定向到: {location}")
            
            # 解析重定向URL
            parsed = urlparse(location)
            if 'wappoc_appmsgcaptcha' in location:
                print("⚠️ 需要微信验证码（反爬虫机制）")
                
                # 解析token
                query_params = parse_qs(parsed.query)
                if 'poc_token' in query_params:
                    print(f"验证token: {query_params['poc_token'][0]}")
                if 'target_url' in query_params:
                    print(f"目标URL: {query_params['target_url'][0]}")
        
        elif response.status_code == 200:
            # 检查内容类型
            content_type = response.headers.get('Content-Type', '')
            if 'text/html' in content_type:
                # 尝试提取标题
                content = response.text[:5000]
                if '<title>' in content:
                    title_start = content.find('<title>') + 7
                    title_end = content.find('</title>', title_start)
                    if title_end > title_start:
                        title = content[title_start:title_end]
                        print(f"\n文章标题: {title}")
                
                # 检查是否有验证相关文本
                if '验证' in content or 'captcha' in content.lower():
                    print("⚠️ 页面包含验证信息")
            
            print(f"\n内容类型: {content_type}")
            print(f"内容长度: {len(response.text)} 字符")
        
        else:
            print(f"\n其他状态码: {response.status_code}")
            
    except requests.exceptions.Timeout:
        print("⏰ 请求超时")
    except requests.exceptions.ConnectionError:
        print("🔌 连接错误")
    except Exception as e:
        print(f"❌ 错误: {e}")
    
    print("\n" + "=" * 60)
    print("结论: 微信文章通常需要登录或验证才能访问")
    print("建议: 手动提供文章内容或使用微信开放平台API")

if __name__ == "__main__":
    url = "https://mp.weixin.qq.com/s/4hxckRf-fSZSr2mtPbDmog"
    check_wechat_article(url)