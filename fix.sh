#!/bin/bash
set -e

echo "��� Step 1: 清理 public 子模块..."
git submodule deinit -f public || true
git rm -rf public || true
rm -f .gitmodules || true
rm -rf .git/modules/public || true

echo "��� Step 2: 提交清理结果..."
git add -A
git commit -m "chore: remove broken public submodule" || true

echo "⚙️ Step 3: 写入 GitHub Actions 配置..."
mkdir -p .github/workflows
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy Hugo site to Pages

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: false
          fetch-depth: 0

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: 'latest'
          extended: true

      - name: Build
        run: hugo --minify

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
EOF

echo "��� Step 4: 提交 workflow 配置..."
git add .github/workflows/deploy.yml
git commit -m "fix: add hugo deploy workflow" || true

echo "⬆️ Step 5: 推送到 main 分支..."
git push origin main

echo "✅ 完成！推送后 GitHub Actions 会自动构建并部署到 Pages。"
