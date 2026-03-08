#!/usr/bin/env python3
"""
GitHub每日监控脚本 - 推荐配置
监控最近7天创建且star数超过1000的开源项目
"""

import requests
import json
import time
from datetime import datetime, timedelta
from pathlib import Path
import sys

class GitHubDailyMonitor:
    def __init__(self, min_stars=1000, days_back=7):
        """
        初始化每日监控器
        
        Args:
            min_stars: 最小star数（推荐1000）
            days_back: 回溯天数（推荐7）
        """
        self.min_stars = min_stars
        self.days_back = days_back
        
        # 计算时间范围
        self.cutoff_date = datetime.now() - timedelta(days=days_back)
        self.cutoff_date_str = self.cutoff_date.strftime("%Y-%m-%d")
        
        # 设置路径
        self.base_path = Path("/root/.openclaw/workspace/memory/github_monitor")
        self.base_path.mkdir(parents=True, exist_ok=True)
        
        # 文件路径
        self.state_file = self.base_path / "daily_state.json"
        self.projects_file = self.base_path / "daily_projects.json"
        self.reports_dir = self.base_path / "daily_reports"
        self.reports_dir.mkdir(exist_ok=True)
        
        # 加载状态
        self.state = self.load_state()
        self.projects = self.load_projects()
        
        # GitHub API 配置
        self.api_base = "https://api.github.com"
        self.headers = {
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "GitHub-Daily-Monitor/1.0"
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
        print(f"[{datetime.now()}] 搜索第{page}页，每页{per_page}条...")
        
        # 构建搜索查询
        query_parts = [
            f"created:>{self.cutoff_date_str}",
            f"stars:>{self.min_stars}",
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
            rate_limit_reset = response.headers.get('X-RateLimit-Reset', 'unknown')
            print(f"API限制: 剩余 {rate_limit_remaining} 次，重置时间: {rate_limit_reset}")
            
            response.raise_for_status()
            
            data = response.json()
            total_count = data.get("total_count", 0)
            items = data.get("items", [])
            
            return {
                "success": True,
                "total_count": total_count,
                "items": items,
                "page": page,
                "has_next": len(items) == per_page and page * per_page < min(total_count, 1000)  # GitHub最多返回1000条
            }
            
        except requests.exceptions.RequestException as e:
            print(f"API请求失败: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"状态码: {e.response.status_code}")
                print(f"响应: {e.response.text[:200]}")
            return {
                "success": False,
                "error": str(e)
            }
    
    def run_daily_check(self):
        """执行每日检查"""
        print("=" * 80)
        print(f"GitHub每日监控 - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 80)
        print(f"监控条件: 最近{self.days_back}天创建，star数 > {self.min_stars}")
        print(f"截止日期: {self.cutoff_date_str}")
        print(f"已跟踪项目数: {len(self.projects)}")
        
        # 更新状态
        self.state["stats"]["total_checks"] += 1
        
        # 执行搜索
        all_new_projects = []
        page = 1
        max_pages = 3  # 最多搜索3页，避免过多API调用
        
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
        
        # 生成报告
        report = self.generate_daily_report(all_new_projects, result.get("total_count", 0) if result.get("success") else 0)
        
        # 保存报告
        report_filename = f"daily_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        report_filepath = self.reports_dir / report_filename
        with open(report_filepath, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"\n📊 监控完成!")
        print(f"   发现 {len(all_new_projects)} 个新项目")
        print(f"   累计跟踪 {len(self.projects)} 个项目")
        print(f"   报告已保存: {report_filepath}")
        
        return {
            "success": True,
            "new_projects_count": len(all_new_projects),
            "total_projects_count": len(self.projects),
            "report_file": str(report_filepath),
            "new_projects": all_new_projects[:10]  # 只返回前10个详情
        }
    
    def process_repository(self, repo_data):
        """处理单个仓库数据"""
        repo_id = str(repo_data.get("id"))
        full_name = repo_data.get("full_name")
        
        # 检查是否已存在
        if repo_id in self.projects:
            # 更新star数变化
            old_stars = self.projects[repo_id].get("stargazers_count", 0)
            new_stars = repo_data.get("stargazers_count", 0)
            if new_stars > old_stars:
                self.projects[repo_id]["stargazers_count"] = new_stars
                self.projects[repo_id]["star_growth"] = new_stars - old_stars
                self.projects[repo_id]["last_updated"] = datetime.now().isoformat()
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
            "last_updated": datetime.now().isoformat(),
            "star_growth": 0
        }
        
        # 计算每日增长（如果知道发现时间）
        try:
            created_date = datetime.fromisoformat(project_info["created_at"].replace("Z", "+00:00"))
            days_since_creation = (datetime.now().astimezone() - created_date).days
            if days_since_creation > 0:
                project_info["daily_star_growth"] = project_info["stargazers_count"] / days_since_creation
            else:
                project_info["daily_star_growth"] = project_info["stargazers_count"]
        except:
            project_info["daily_star_growth"] = project_info["stargazers_count"]
        
        # 保存到项目列表
        self.projects[repo_id] = project_info
        
        return project_info
    
    def generate_daily_report(self, new_projects, total_count):
        """生成每日报告"""
        current_time = datetime.now()
        report_date = current_time.strftime("%Y年%m月%d日")
        report_time = current_time.strftime("%H:%M:%S")
        
        report = f"""# GitHub热门项目每日监控报告

**报告日期**: {report_date}  
**生成时间**: {report_time}  
**监控条件**: 最近{self.days_back}天创建，star数 > {self.min_stars}

## 📊 监控概览

| 指标 | 数值 |
|------|------|
| 符合条件的仓库总数 | {total_count} |
| 本次发现的新项目 | {len(new_projects)} |
| 累计跟踪项目数 | {len(self.projects)} |
| 总检查次数 | {self.state['stats']['total_checks']} |
| 最后检查时间 | {self.state['stats'].get('last_check', '从未检查')} |

## 🎉 新发现项目

"""
        
        if new_projects:
            # 按star数排序
            sorted_projects = sorted(new_projects, key=lambda x: x["stargazers_count"], reverse=True)
            
            for i, project in enumerate(sorted_projects[:20], 1):  # 只显示前20个
                try:
                    created_date = datetime.fromisoformat(project["created_at"].replace("Z", "+00:00"))
                    days_old = (datetime.now().astimezone() - created_date).days
                except:
                    days_old = 0
                daily_growth = project.get("daily_star_growth", 0)
                
                report += f"### {i}. [{project['full_name']}]({project['html_url']}) ⭐{project['stargazers_count']:,}\n"
                report += f"- **描述**: {project['description'] or '无描述'}\n"
                report += f"- **语言**: {project['language'] or '未指定'}\n"
                report += f"- **创建时间**: {project['created_at'][:10]} ({days_old}天前)\n"
                report += f"- **每日增长**: ⭐{daily_growth:.1f}/天\n"
                report += f"- **Fork数**: {project['forks_count']:,}\n"
                
                if project.get("topics"):
                    report += f"- **主题标签**: {', '.join(project['topics'][:5])}\n"
                
                report += "\n"
            
            if len(new_projects) > 20:
                report += f"\n... 还有 {len(new_projects) - 20} 个项目未显示\n"
        else:
            report += "本次未发现符合条件的新项目。\n"
        
        # 添加趋势分析
        report += f"""
## 📈 趋势分析

### 热门语言分布
（可根据实际数据添加语言分布统计）

### 增长最快项目
（可根据每日增长数据排序）

### 重点关注项目
1. **高增长项目**: 每日star增长超过100的项目
2. **技术趋势**: AI、Web3、开发工具等热门领域
3. **企业级项目**: 有大公司背景或企业应用潜力的项目

## 🔧 监控配置

- **Star阈值**: >{self.min_stars}
- **时间范围**: 最近{self.days_back}天
- **监控频率**: 每日一次
- **数据存储**: `/root/.openclaw/workspace/memory/github_monitor/`

## 🎯 明日关注

1. 继续监控新出现的爆款项目
2. 跟踪已发现项目的star增长情况
3. 分析技术趋势变化

---
*报告生成时间: {current_time.isoformat()}*  
*监控系统: GitHub热门项目每日监控*  
*配置: star>{self.min_stars}, {self.days_back}天内创建*
"""
        
        return report

def main():
    """主函数"""
    try:
        # 创建监控器（使用推荐配置）
        monitor = GitHubDailyMonitor(min_stars=1000, days_back=7)
        
        # 执行每日检查
        result = monitor.run_daily_check()
        
        if result["success"]:
            print("\n" + "=" * 80)
            print("✅ 每日监控任务完成!")
            print(f"   新项目: {result['new_projects_count']} 个")
            print(f"   总项目: {result['total_projects_count']} 个")
            print(f"   报告文件: {result['report_file']}")
            
            # 如果有新项目，显示前3个
            if result.get("new_projects"):
                print("\n🏆 今日发现的热门项目:")
                for i, project in enumerate(result["new_projects"][:3], 1):
                    print(f"{i}. {project['full_name']} ⭐{project['stargazers_count']:,}")
                    print(f"   描述: {project['description'][:80] if project['description'] else '无描述'}...")
                    print(f"   链接: {project['html_url']}")
                    print()
        else:
            print("\n❌ 监控任务失败")
            
    except Exception as e:
        print(f"\n❌ 监控系统错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()