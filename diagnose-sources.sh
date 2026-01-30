#!/bin/bash
# 诊断脚本：检查信息源抓取情况

echo "=== AIGC Weekly 信息源抓取诊断 ==="
echo ""

# 统计 REFERENCE.md 中的信息源数量
TOTAL_SOURCES=$(grep -E "^- https://" agent/.claude/REFERENCE.md | wc -l | tr -d ' ')
echo "📋 REFERENCE.md 中配置的信息源数量: $TOTAL_SOURCES"
echo ""

# 列出所有信息源
echo "📝 所有信息源列表:"
grep -E "^- https://" agent/.claude/REFERENCE.md | nl
echo ""

# 检查 drafts 目录
echo "=== Drafts 目录内容 ==="
DRAFT_COUNT=$(find data/app/drafts -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "📄 Drafts 文件数量: $DRAFT_COUNT"

if [ "$DRAFT_COUNT" -gt 0 ]; then
  echo ""
  echo "📂 Drafts 文件列表:"
  find data/app/drafts -name "*.md" -type f -exec ls -lh {} \; | awk '{print $9, "(" $5 ")"}'
else
  echo "⚠️  Drafts 目录为空"
fi
echo ""

# 检查失败记录
if [ -f "data/app/logs/crawl-failures.jsonl" ]; then
  FAILURE_COUNT=$(wc -l < data/app/logs/crawl-failures.jsonl | tr -d ' ')
  echo "=== 抓取失败记录 ==="
  echo "❌ 失败次数: $FAILURE_COUNT"
  echo ""
  echo "失败详情:"
  cat data/app/logs/crawl-failures.jsonl | jq -r '"\(.url) - \(.error_message)"' 2>/dev/null || cat data/app/logs/crawl-failures.jsonl
  echo ""
fi

# 检查研究报告
if [ -f "data/app/logs/research-report.md" ]; then
  echo "=== 研究报告 ==="
  cat data/app/logs/research-report.md
  echo ""
fi

# 总结
echo "=== 诊断总结 ==="
echo "- 配置的信息源: $TOTAL_SOURCES 个"
echo "- 生成的草稿: $DRAFT_COUNT 个"
if [ "$DRAFT_COUNT" -lt "$TOTAL_SOURCES" ]; then
  echo "⚠️  警告: 草稿数量少于信息源数量，可能有源未被抓取"
fi
