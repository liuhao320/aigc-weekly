#!/bin/bash

echo "📰 测试抓取昨天（2026-01-28）的 AI 新闻"
echo ""

curl -s 'http://localhost:2442/chat' \
  -X POST \
  -H 'Content-Type: application/json' \
  --data '{
    "prompt": "请使用 crawler 抓取以下网页的内容:\n\nhttps://news.ycombinator.com/front?day=2026-01-28\n\n```yaml\n# 周刊参数\nweek_id: Y26W04\nweek_number: 04\nyear_short: 26\nyear_full: 2026\nstart_date: 2026-01-25\nend_date: 2026-01-31\ntimezone: UTC+0\n```\n\n请抓取这一天的 Hacker News 热门新闻，筛选出与 AI/AIGC/LLM 相关的内容，保存到 drafts/ 目录。"
  }'
