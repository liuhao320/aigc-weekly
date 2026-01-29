#!/bin/bash

# AIGC Weekly 一键安装脚本
# 使用方法：bash setup.sh

set -e

echo "🚀 AIGC Weekly 一键安装脚本"
echo "================================"
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 未检测到 Node.js，请先安装 Node.js 22+"
    exit 1
fi

# 检查 pnpm
if ! command -v pnpm &> /dev/null; then
    echo "📦 正在安装 pnpm..."
    npm install -g pnpm
fi

echo "✅ 环境检查通过"
echo ""

# 安装依赖
echo "📦 安装依赖..."
pnpm install
echo ""

# 配置环境变量
echo "⚙️  配置环境变量..."

# 根目录 .env
if [ ! -f .env ]; then
    echo "PAYLOAD_SECRET=$(openssl rand -hex 32)" > .env
    echo "NEXT_PUBLIC_BASE_URL=http://localhost:3000" >> .env
    echo "✅ 已创建 .env"
else
    echo "⚠️  .env 已存在，跳过"
fi

# worker/.env.local
if [ ! -f worker/.env.local ]; then
    cat > worker/.env.local <<'EOF'
# 模型配置
ANTHROPIC_BASE_URL=https://ark.cn-beijing.volces.com/api/coding
ANTHROPIC_AUTH_TOKEN=your-volces-api-key-here
ANTHROPIC_DEFAULT_OPUS_MODEL=ark-code-latest
ANTHROPIC_DEFAULT_SONNET_MODEL=ark-code-latest
ANTHROPIC_DEFAULT_HAIKU_MODEL=ark-code-latest

# Claude 功能控制
DISABLE_NON_ESSENTIAL_MODEL_CALLS=1
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1

# Firecrawl API Key（可选）
FIRECRAWL_API_KEY=your-firecrawl-key-here
EOF
    echo "✅ 已创建 worker/.env.local"
    echo ""
    echo "⚠️  重要：请编辑 worker/.env.local 填入你的 API Keys："
    echo "   - ANTHROPIC_AUTH_TOKEN: 火山引擎 API Key"
    echo "   - FIRECRAWL_API_KEY: Firecrawl API Key（可选）"
    echo ""
else
    echo "⚠️  worker/.env.local 已存在，跳过"
fi
echo ""

# 生成类型
echo "🔧 生成类型文件..."
pnpm generate:types
echo ""

echo "✅ 安装完成！"
echo ""
echo "================================"
echo "🎉 现在你可以："
echo ""
echo "1️⃣  编辑 worker/.env.local 填入你的 API Keys"
echo ""
echo "2️⃣  启动 Agent 服务："
echo "   pnpm dev:agent"
echo ""
echo "3️⃣  在新终端窗口生成周刊："
echo "   pnpm weekly"
echo ""
echo "4️⃣  或启动网页查看："
echo "   pnpm dev"
echo "   访问 http://localhost:3000"
echo ""
echo "================================"
