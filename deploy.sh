#!/bin/bash
# 文件名: deploy.sh
# 用途：Hugo博客全自动双仓库部署脚本

set -e  # 任何命令失败立即终止脚本

# ============== 用户配置区 ==============
SOURCE_REPO="source"  # 源码仓库别名
PAGES_REPO="pages"    # GitHub Pages仓库别名
SOURCE_URL="https://github.com/piggycabbage/myblog.git"
PAGES_URL="https://github.com/piggycabbage/piggycabbage.github.io.git"
# =======================================

# 彩色输出函数
color_echo() {
    echo -e "\033[1;32m$1\033[0m"
}

# 步骤1：生成静态文件
color_echo "🚀 开始生成静态文件..."
hugo --minify --cleanDestinationDir --gc --enableGitInfo

# 步骤2：部署到GitHub Pages
color_echo "📤 正在提交到GitHub Pages..."
cd public

# 智能初始化Pages仓库
if [ ! -d ".git" ]; then
    git init
    git remote add $PAGES_REPO $PAGES_URL
    git checkout -b main
fi

# 提交变更
git add .
git commit -m "Auto Update: $(date +'%Y-%m-%d %H:%M:%S')" --allow-empty
git push $PAGES_REPO main --force

# 步骤3：提交源码到主仓库
color_echo "📦 正在提交源码变更..."
cd ..
git add .
git commit -m "Content Update: $(date +'%Y-%m-%d %H:%M:%S')" --allow-empty
git push $SOURCE_REPO main

# 步骤4：打版本标签
color_echo "🔖 创建部署标签..."
TAG_NAME="deploy-$(date +%Y%m%d-%H%M%S)"
git tag $TAG_NAME
git push $SOURCE_REPO $TAG_NAME

color_echo "✅ 部署完成！访问地址：https://piggycabbage.github.io/"