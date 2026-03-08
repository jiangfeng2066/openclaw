#!/usr/bin/env python3
"""
GitHub每日监控脚本 - 最终配置
监控条件：最近7天创建，star>1000，fork>100
运行时间：每天北京时间20:00（12:00 UTC）
输出：发送到飞书，包含GitHub链接
"""

import requests
import json
import time
from datetime import datetime, timedelta
from pathlib import Path
import sys

class GitHubDailyMonitor:
    def __init__(self, min_stars=1000, min_forks=100, days_back=7):
        """
        初始化监控器
        
        Args:
            min_stars: 最小star数
            min_forks: 最小fork数
            days_back: 回溯天数
        """
        self.min_stars = min_stars
        self.min_forks = min_forks
        self.days_back = days_back
        
        # 计算时间范围
        self.cutoff_date = datetime.now() - timedelta(days=days_back)
        self.cutoff_date_str = self.cutoff_date.strftime("%Y-%m-%d")
        
        # 设置路径
        self.base_path = Path("/root/.openclaw/workspace/memory/github_monitor")
        self.base_path.mkdir(parents=True, exist_ok=True)
        
        # 文件路径
        self.state_file = self.base_path / "monitor_state_final.json"
        self.projects_file = self.base_path / "projects_final.json"
        
        # 加载状态
        self.state = self.load_state()
        self.projects = self.load_projects()
        
        # GitHub API 配置
        self.api_base = "https://api.github.com"
        self.headers = {
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "GitHub-Daily-Monitor-Final/1.0"
        }
        
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
            "config": {
                "min_stars": self.min_stars,
                "min_forks": self.min_forks,
                "days_back": self.days_back
            },
            "stats": {
                "total_checks": 0,
                "total_projects_found": 0,
                "last_check": None,
                "last_new_projects": 0
            },
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }
    
    def save_state(self):
        """保存监控状态"""
        self.state["stats"]["last_check"] = datetime.now().isoformat()
        self.state["updated_at"] = datetime.now().isoformat()
        with open(self.state_file, 'w', encoding='utf-8') as f:
            json.dump(self.state, f, ensure_ascii=False, indent=2)
    
    def load_projects(self):
        """加载已发现的项目"""
        if self.projects_file.exists():
            try:
                with open(self.projects_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                pass
        
        return {}
    
    def save_projects(self):
        """保存项目数据"""
        with open(self.projects_file, 'w', encoding='utf-8') as f:
            json.dump(self.projects, f, ensure_ascii=False, indent=2)
    
    def search_repositories(self, page=1, per_page=30):
        """搜索符合条件的仓库"""
        print(f"[{datetime.now()}] 搜索第{page}页...")
        
        # 构建搜索查询
        query_parts = [
            f"created:>{self.cutoff_date_str}",
            f"stars:>{self.min_stars}",
            f"forks:>{self.min_forks}",
            "is:public",
            "fork:false"
        ]
        
        query = " ".join(query_parts)
        url = f"{self.api_base}/search/repositories"
        params = {
            "q": query,
            "sort": "stars",
            "order": "desc",
            "page": page,
            "per_page": per_page
        }
        
        try:
            response = requests.get(url, params=params, headers=self.headers, timeout=30)
            
            # 检查API限制
            rate_limit_remaining = response.headers.get('X-RateLimit-Remaining', 'unknown')
            print(f"API限制: 剩余 {rate_limit_remaining} 次请求")
            
            response.raise_for_status()
            
            data = response.json()
            total_count = data.get("total_count", 0)
            items = data.get("items", [])
            
            return {
                "success": True,
                "total_count": total_count,
                "items": items,
                "page": page,
                "has_next": len(items) == per_page and page * per_page < min(total_count, 1000)
            }
            
        except requests.exceptions.RequestException as e:
            print(f"API请求失败: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    def run_daily_check(self):
        """执行每日检查"""
        print("=" * 80)
        print(f"GitHub每日监控 - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 80)
        print(f"监控条件: 最近{self.days_back}天创建，star>{self.min_stars}，fork>{self.min_forks}")
        print(f"截止日期: {self.cutoff_date_str}")
        print(f"已跟踪项目数: {len(self.projects)}")
        
        # 更新状态
        self.state["stats"]["total_checks"] += 1
        
        # 执行搜索
        all_new_projects = []
        page = 1
        max_pages = 2  # 最多搜索2页，避免过多API调用
        
        while page <= max_pages:
            print(f"\n📄 搜索第 {page} 页...")
            result = self.search_repositories(page=page)
            
            if not result["success"]:
                print(f"搜索失败: {result.get('error')}")
                break
            
            # 处理本页结果
            new_projects_in_page = []
            for item in result["items"]:
                project_info = self.process_repository(item)
                if project_info:
                    new_projects_in_page.append(project_info)
            
            print(f"本页发现 {len(new_projects_in_page)} 个新项目")
            all_new_projects.extend(new_projects_in_page)
            
            # 检查是否继续
            if not result.get("has_next", False) or len(result["items"]) == 0:
                break
            
            page += 1
            time.sleep(1)  # 避免过快请求
        
        # 更新统计
        self.state["stats"]["total_projects_found"] = len(self.projects)
        self.state["stats"]["last_new_projects"] = len(all_new_projects)
        
        # 保存数据
        self.save_state()
        self.save_projects()
        
        # 生成飞书消息
        feishu_message = self.generate_feishu_message(all_new_projects, result.get("total_count", 0) if result.get("success") else 0)
        
        print(f"\n📊 监控完成!")
        print(f"   发现 {len(all_new_projects)} 个新项目")
        print(f"   累计跟踪 {len(self.projects)} 个项目")
        
        return {
            "success": True,
            "new_projects_count": len(all_new_projects),
            "total_projects_count": len(self.projects),
            "feishu_message": feishu_message,
            "new_projects": all_new_projects
        }
    
    def process_repository(self, repo_data):
        """处理单个仓库数据"""
        repo_id = str(repo_data.get("id"))
        full_name = repo_data.get("full_name")
        
        # 检查是否已存在
        if repo_id in self.projects:
            return None
        
        # 提取关键信息
        project_info = {
            "id": repo_id,
            "name": repo_data.get("name"),
            "full_name": full_name,
            "owner": repo_data.get("owner", {}).get("login"),
            "description": repo_data.get("description", ""),
            "html_url": repo_data.get("html_url"),
            "created_at": repo_data.get("created_at"),
            "updated_at": repo_data.get("updated_at"),
            "pushed_at": repo_data.get("pushed_at"),
            "stargazers_count": repo_data.get("stargazers_count", 0),
            "watchers_count": repo_data.get("watchers_count", 0),
            "forks_count": repo_data.get("forks_count", 0),
            "open_issues_count": repo_data.get("open_issues_count", 0),
            "language": repo_data.get("language"),
            "license": repo_data.get("license", {}).get("name") if repo_data.get("license") else None,
            "topics": repo_data.get("topics", []),
            "archived": repo_data.get("archived", False),
            "disabled": repo_data.get("disabled", False),
            "discovered_at": datetime.now().isoformat(),
            "first_seen_stars": repo_data.get("stargazers_count", 0),
            "last_updated": datetime.now().isoformat()
        }
        
        # 保存到项目列表
        self.projects[repo_id] = project_info
        
        return project_info
    
    def generate_feishu_message(self, new_projects, total_count):
        """生成飞书消息"""
        current_time = datetime.now()
        beijing_time = current_time.strftime("%Y年%m月%d日 %H:%M")
        
        # 消息头部
        message = f"🚀 **GitHub热门项目每日监控报告**\n\n"
        message += f"**报告时间**: {beijing_time} (北京时间)\n"
        message += f"**监控条件**: 最近{self.days_back}天创建，star>{self.min_stars}，fork>{self.min_forks}\n\n"
        
        # 统计信息
        message += f"📊 **监控统计**\n"
        message += f"- 符合条件的仓库总数: {total_count}\n"
        message += f"- 本次发现的新项目: {len(new_projects)}\n"
        message += f"- 累计跟踪项目数: {len(self.projects)}\n"
        message += f"- 总检查次数: {self.state['stats']['total_checks']}\n\n"
        
        if new_projects:
            # 按star数排序
            sorted_projects = sorted(new_projects, key=lambda x: x["stargazers_count"], reverse=True)
            
            message += f"🎉 **新发现项目** ({len(new_projects)}个)\n\n"
            
            for i, project in enumerate(sorted_projects[:15], 1):  # 只显示前15个
                # 计算项目年龄
                try:
                    created_date = datetime.fromisoformat(project["created_at"].replace("Z", "+00:00"))
                    days_old = (datetime.now().astimezone() - created_date).days
                    age_text = f"{days_old}天前创建"
                except:
                    age_text = "创建时间未知"
                
                # 构建项目行
                project_line = f"{i}. **[{project['full_name']}]({project['html_url']})**\n"
                project_line += f"   ⭐ **{project['stargazers_count']:,}** | 🍴 **{project['forks_count']:,}** | {age_text}\n"
                
                if project['description']:
                    desc = project['description']
                    if len(desc) > 100:
                        desc = desc[:100] + "..."
                    project_line += f"   📝 {desc}\n"
                
                if project['language']:
                    project_line += f"   💻 主要语言: {project['language']}\n"
                
                message += project_line + "\n"
            
            if len(new_projects) > 15:
                message += f"📋 还有 {len(new_projects) - 15} 个项目未显示\n\n"
        else:
            message += "📭 **本次未发现符合条件的新项目**\n\n"
        
        # 添加监控配置信息
        message += "🔧 **监控配置**\n"
        message += f"- Star阈值: >{self.min_stars}\n"
        message += f"- Fork阈值: >{self.min_forks}\n"
        message += f"- 时间范围: 最近{self.days_back}天\n"
        message += f"- 运行时间: 每天北京时间20:00\n\n"
        
        message += "📈 **趋势说明**\n"
        message += "同时满足star>1000和fork>100的项目通常具有：\n"
        message += "1. 高质量代码和文档\n"
        message += "2. 活跃的社区贡献\n"
        message += "3. 实际应用价值\n"
        message += "4. 良好的维护状态\n\n"
        
        message += "💡 **使用建议**\n"
        message += "1. 点击项目链接查看详情\n"
        message += "2. 关注增长快速的项目\n"
        message += "3. 根据技术栈筛选感兴趣的项目\n"
        
        return message

def main():
    """主函数"""
    try:
        # 创建监控器（使用最终配置）
        monitor = GitHubDailyMonitor(
            min_stars=1000,
            min_forks=100,
            days_back=7
        )
        
        # 执行每日检查
        result = monitor.run_daily_check()
        
        if result["success"]:
            print("\n" + "=" * 80)
            print("✅ 每日监控任务完成!")
            print(f"   新项目: {result['new_projects_count']} 个")
            print(f"   总项目: {result['total_projects_count']} 个")
            
            # 显示飞书消息预览
            print("\n📱 飞书消息预览:")
            print("-" * 40)
            preview = result['feishu_message'][:500] + "..." if len(result['feishu_message']) > 500 else result['feishu_message']
            print(preview)
            print("-" * 40)
            
            return result
            
        else:
            print("\n❌ 监控任务失败")
            return None
            
    except Exception as e:
        print(f"\n❌ 监控系统错误: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == "__main__":
    main()