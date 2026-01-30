#!/bin/bash

echo "🔍 检查 Agent 使用的抓取工具（调试模式）"
echo ""

# 先测试 Agent 是否运行
echo "1. 测试 Agent 连接..."
if ! curl -s --max-time 2 http://localhost:2442/ > /dev/null 2>&1; then
    echo "❌ Agent 服务未运行！请先启动: npx pnpm dev:agent"
    exit 1
fi
echo "✅ Agent 服务正在运行"
echo ""

# 发送请求并保存完整响应
echo "2. 发送抓取请求..."
RESPONSE=$(curl -s --max-time 120 'http://localhost:2442/chat' \
  -X POST \
  -H 'Content-Type: application/json' \
  --data '{
    "prompt": "作为 crawler agent，请抓取 https://www.anthropic.com/news 并明确告诉我你使用了哪个工具（mcp__firecrawl__scrape 还是 WebFetch）？\n\n```yaml\nweek_id: Y26W04\nstart_date: 2026-01-25\nend_date: 2026-01-31\ntimezone: UTC+0\n```"
  }')

echo ""
echo "3. 完整响应（前 2000 字符）:"
echo "$RESPONSE" | head -c 2000
echo ""
echo ""

# 尝试提取工具使用信息
echo "4. 查找工具使用记录:"
echo "$RESPONSE" | grep -i "firecrawl\|webfetch\|tool_use" | head -10

echo ""
echo "检查完成！"
