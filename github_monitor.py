#!/usr/bin/env python3
"""
GitHub 热门项目监控脚本
监控最近一周新上线且star数超过5000的开源项目
"""

import requests
import json
import time
from datetime import datetime, timedelta
from pathlib import Path
import sys

class GitHubMonitor:
    def __init__(self, min_stars=5000, days_back=7):
        """
        初始化GitHub监控器
        
        Args:
            min_stars: 最小star数
            days_back: 回溯天数
        """
        self.min_stars = min_stars
        self.days_back = days_back
        
        # 计算时间范围
        self.cutoff_date = datetime.now() - timedelta(days=days_back)
        self.cutoff_date_str = self.cutoff_date.strftime("%Y-%m-%d")
        
        # 设置路径
        self.memory_path = Path("/root/.openclaw/workspace/memory/github_monitor")
        self.memory_path.mkdir(parents=True, exist_ok=True)
        
        # 状态文件
        self.state_file = self.memory_path / "monitor_state.json"
        self.projects_file = self.memory_path / "projects.json"
        
        # 加载状态
        self.state = self.load_state()
        self.projects = self.load_projects()
        
        # GitHub API 配置
        self.api_base = "https://api.github.com"
        self.headers = {
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "GitHub-Monitor-Bot/1.0"
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
            "min_stars": self.min_stars,
            "days_back": self.days_back,
            "last_check": None,
            "total_checks": 0,
            "projects_found": 0,
            "created_at": datetime.now().isoformat()
        }
    
    def save_state(self):
        """保存监控状态"""
        self.state["last_check"] = datetime.now().isoformat()
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
    
    def search_repositories(self):
        """搜索符合条件的仓库"""
        print(f"[{datetime.now()}] 搜索GitHub仓库...")
        print(f"条件: 最近{self.days_back}天创建, star数 > {self.min_stars}")
        
        # 构建搜索查询
        query_parts = [
            f"created:>{self.cutoff_date_str}",
            f"stars:>{self.min_stars}",
            "is:public",
            "fork:false"  # 只搜索原创仓库
        ]
        
        query = " ".join(query_parts)
        url = f"{self.api_base}/search/repositories"
        params = {
            "q": query,
            "sort": "stars",
            "order": "desc",
            "per_page": 30  # 每页最多100，但先取30测试
        }
        
        try:
            response = requests.get(url, params=params, headers=self.headers, timeout=30)
            response.raise_for_status()
            
            data = response.json()
            total_count = data.get("total_count", 0)
            items = data.get("items", [])
            
            print(f"找到 {total_count} 个符合条件的仓库")
            print(f"本次获取 {len(items)} 个仓库详情")
            
            # 处理每个仓库
            new_projects = []
            for item in items:
                project_info = self.process_repository(item)
                if project_info:
                    new_projects.append(project_info)
            
            # 更新状态
            self.state["total_checks"] += 1
            self.state["projects_found"] = len(self.projects)
            
            return {
                "success": True,
                "total_count": total_count,
                "new_projects": new_projects,
                "timestamp": datetime.now().isoformat()
            }
            
        except requests.exceptions.RequestException as e:
            print(f"API请求失败: {e}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            print(f"处理失败: {e}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat()
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
            "description": repo_data.get("description"),
            "html_url": repo_data.get("html_url"),
            "created_at": repo_data.get("created_at"),
            "updated_at": repo_data.get("updated_at"),
            "pushed_at": repo_data.get("pushed_at"),
            "stargazers_count": repo_data.get("stargazers_count"),
            "watchers_count": repo_data.get("watchers_count"),
            "forks_count": repo_data.get("forks_count"),
            "open_issues_count": repo_data.get("open_issues_count"),
            "language": repo_data.get("language"),
            "license": repo_data.get("license", {}).get("name") if repo_data.get("license") else None,
            "topics": repo_data.get("topics", []),
            "archived": repo_data.get("archived", False),
            "disabled": repo_data.get("disabled", False),
            "discovered_at": datetime.now().isoformat(),
            "first_seen_stars": repo_data.get("stargazers_count")
        }
        
        # 保存到项目列表
        self.projects[repo_id] = project_info
        
        return project_info
    
    def generate_report(self, search_result):
        """生成监控报告"""
        if not search_result["success"]:
            return f"监控失败: {search_result.get('error', '未知错误')}"
        
        new_projects = search_result.get("new_projects", [])
        total_count = search_result.get("total_count", 0)
        
        report = f"""
=== GitHub 热门项目监控报告 ===
生成时间: {datetime.now().isoformat()}
监控条件: 最近{self.days_back}天创建, star数 > {self.min_stars}

📊 搜索统计:
- 符合条件的仓库总数: {total_count}
- 本次发现的新仓库: {len(new_projects)}
- 累计跟踪仓库数: {len(self.projects)}

🔄 监控状态:
- 总检查次数: {self.state.get('total_checks', 0)}
- 最后检查时间: {self.state.get('last_check', '从未检查')}
- 首次监控时间: {self.state.get('created_at', '未知')}
"""
        
        if new_projects:
            report += f"\n🎉 新发现的项目 ({len(new_projects)}个):\n"
            for i, project in enumerate(new_projects[:10], 1):  # 只显示前10个
                report += f"\n{i}. **{project['full_name']}** ⭐{project['stargazers_count']}\n"
                report += f"   描述: {project['description'] or '无描述'}\n"
                report += f"   语言: {project['language'] or '未指定'}\n"
                report += f"   创建: {project['created_at']}\n"
                report += f"   链接: {project['html_url']}\n"
            
            if len(new_projects) > 10:
                report += f"\n... 还有 {len(new_projects) - 10} 个项目未显示"
        
        else:
            report += "\n📭 本次未发现新项目"
        
        report += f"""

💾 数据存储:
- 状态文件: {self.state_file}
- 项目数据库: {self.projects_file}
- 项目数量: {len(self.projects)} 个

🔄 建议:
1. 调整监控条件可修改 min_stars 和 days_back 参数
2. 如需更频繁监控，请调整Cron任务频率
3. 重要项目可设置特别关注
"""
        
        return report
    
    def save_project_details(self, project):
        """保存项目详细报告"""
        if not project:
            return
        
        # 创建项目详情文件
        project_dir = self.memory_path / "projects"
        project_dir.mkdir(exist_ok=True)
        
        filename = f"{project['full_name'].replace('/', '_')}_{datetime.now().strftime('%Y%m%d')}.md"
        filepath = project_dir / filename
        
        content = f"""# GitHub项目报告: {project['full_name']}

## 基本信息
- **项目名称**: {project['full_name']}
- **描述**: {project['description'] or '无描述'}
- **创建时间**: {project['created_at']}
- **最后更新**: {project['updated_at']}
- **项目链接**: {project['html_url']}

## 统计信息
- ⭐ **Star数**: {project['stargazers_count']}
- 🍴 **Fork数**: {project['forks_count']}
- 👀 **Watch数**: {project['watchers_count']}
- 🐛 **Open Issues**: {project['open_issues_count']}

## 技术信息
- **主要语言**: {project['language'] or '未指定'}
- **开源协议**: {project['license'] or '未指定'}
- **主题标签**: {', '.join(project['topics']) if project['topics'] else '无'}
- **项目状态**: {'已归档' if project['archived'] else '活跃'} | {'已禁用' if project['disabled'] else '正常'}

## 发现信息
- **发现时间**: {project['discovered_at']}
- **首次发现时Star数**: {project['first_seen_stars']}
- **监控条件**: 最近{self.days_back}天创建, star数 > {self.min_stars}

## 项目分析
（此处可添加自动分析内容，如：
- 技术栈评估
- 社区活跃度分析
- 增长趋势预测
- 同类项目对比
）

---
*报告生成时间: {datetime.now().isoformat()}*
*监控系统: GitHub热门项目监控*
"""
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return filepath

def main():
    """主函数"""
    print("=" * 70)
    print("GitHub 热门项目监控系统")
    print("=" * 70)
    
    # 创建监控器
    monitor = GitHubMonitor(min_stars=5000, days_back=7)
    
    # 显示当前状态
    print(f"监控条件: 最近{monitor.days_back}天创建, star数 > {monitor.min_stars}")
    print(f"截止日期: {monitor.cutoff_date_str}")
    print(f"已跟踪项目: {len(monitor.projects)} 个")
    print(f"最后检查: {monitor.state.get('last_check', '从未检查')}")
    
    # 执行搜索
    print("\n" + "=" * 70)
    print("开始搜索符合条件的GitHub仓库...")
    
    search_result = monitor.search_repositories()
    
    if search_result["success"]:
        print(f"✅ 搜索成功!")
        print(f"   找到 {search_result.get('total_count', 0)} 个符合条件的仓库")
        print(f"   发现 {len(search_result.get('new_projects', []))} 个新项目")
    else:
        print(f"❌ 搜索失败: {search_result.get('error')}")
    
    # 生成报告
    report = monitor.generate_report(search_result)
    print("\n" + "=" * 70)
    print("监控报告:")
    print("=" * 70)
    print(report)
    
    # 保存状态和数据
    monitor.save_state()
    monitor.save_projects()
    
    # 保存新项目的详细报告
    new_projects = search_result.get("new_projects", [])
    if new_projects:
        print(f"\n💾 保存新项目详细报告...")
        for project in new_projects[:5]:  # 只保存前5个的详细报告
            filepath = monitor.save_project_details(project)
            if filepath:
                print(f"   已保存: {filepath.name}")
    
    # 保存总报告
    report_file = monitor.memory_path / f"monitor_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    print(f"\n📄 总报告已保存: {report_file}")
    
    print("\n" + "=" * 70)
    print("监控完成!")
    print("=" * 70)

if __name__ == "__main__":
    main()