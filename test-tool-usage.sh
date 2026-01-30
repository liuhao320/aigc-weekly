#!/bin/bash

echo "🔍 检查 Agent 使用的抓取工具"
echo ""

curl -s 'http://localhost:2442/chat' \
  -X POST \
  -H 'Content-Type: application/json' \
  --data '{
    "prompt": "作为 crawler agent，请抓取以下网页并明确告诉我你使用了哪个工具：\n\nhttps://www.anthropic.com/news\n\n```yaml\nweek_id: Y26W04\nstart_date: 2026-01-25\nend_date: 2026-01-31\ntimezone: UTC+0\n```\n\n**重要**：请在抓取前明确说明你将使用哪个工具（mcp__firecrawl__scrape 还是 WebFetch），并在完成后确认实际使用的工具。"
  }' | jq -r 'select(.type == "assistant") | .message.content[] | select(.type == "text") | .text'

echo ""
echo "检查完成！"
