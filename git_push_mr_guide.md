# Git Push 和 MR 提交指南

## 标准操作流程

### 1. 检查当前状态
```bash
git status
git branch
git remote -v
```

### 2. 添加和提交改动
```bash
git add .
git commit -m "提交描述"
```

### 3. Push 到远程仓库
```bash
git push origin <branch-name>
```

### 4. 创建 Merge Request (GitLab) 或 Pull Request (GitHub)
- GitHub: 访问仓库页面 → Pull requests → New pull request
- GitLab: 访问仓库页面 → Merge requests → New merge request

## 需要从用户获取的信息
1. 仓库URL (git remote add origin <url>)
2. 当前分支名称
3. 目标分支名称
4. MR/PR标题和描述
5. 提交信息

## 常见命令参考
```bash
# 添加远程仓库
git remote add origin <repository-url>

# 设置上游分支
git push -u origin <branch-name>

# 查看提交历史
git log --oneline

# 查看差异
git diff
```