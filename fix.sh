#!/bin/bash
set -e

echo "🧹 Step 1: 删除 submodule 相关..."
git rm -rf themes/PaperMod || true
rm -rf .git/modules/themes/PaperMod || true
rm -f .gitmodules || true
git commit -m "fix: remove PaperMod submodule" || true
git push origin main

echo "🗑️ Step 2: 删除本地旧目录..."
rm -rf themes/PaperMod

echo "📥 Step 3: 克隆主题源码..."
git clone https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod

echo "➕ Step 4: 添加到仓库..."
git add themes/PaperMod
git commit -m "chore: add PaperMod theme as local files"
git push origin main

echo "✅ 完成！PaperMod 已经作为普通文件夹提交。"
