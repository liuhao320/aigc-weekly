#!/bin/bash

echo "=== 诊断报告 ==="
echo ""

echo "1. 检查目录结构："
ls -lh data/app/ 2>/dev/null || echo "data/app/ 不存在"
echo ""

echo "2. 检查 drafts 目录："
ls -lh data/app/drafts/ 2>/dev/null || echo "drafts/ 不存在或为空"
echo ""

echo "3. 检查 logs 目录："
ls -lh data/app/logs/ 2>/dev/null || echo "logs/ 不存在或为空"
echo ""

echo "4. 检查 weekly 目录："
ls -lh data/app/weekly/ 2>/dev/null || echo "weekly/ 不存在或为空"
echo ""

echo "5. 检查 Agent 日志："
if [ -f /tmp/agent-output.log ]; then
    echo "Agent 日志最后 50 行："
    tail -50 /tmp/agent-output.log
else
    echo "❌ /tmp/agent-output.log 不存在"
fi
echo ""

echo "6. 检查环境变量："
if [ -f worker/.env.local ]; then
    echo "✅ worker/.env.local 存在"
    grep "ANTHROPIC" worker/.env.local | head -3
else
    echo "❌ worker/.env.local 不存在"
fi
echo ""

echo "7. 检查 Agent 配置："
if [ -f agent/.claude/REFERENCE.md ]; then
    echo "✅ REFERENCE.md 存在"
    wc -l agent/.claude/REFERENCE.md
else
    echo "❌ REFERENCE.md 不存在"
fi
echo ""

echo "8. 检查 Agent 进程："
lsof -ti :2442 2>/dev/null && echo "✅ Agent 正在运行" || echo "❌ Agent 未运行"
echo ""

echo "9. 测试 Agent 连接："
curl -s --max-time 2 http://localhost:2442/ > /dev/null 2>&1 && echo "✅ Agent 端口可访问" || echo "❌ Agent 端口不可访问"
