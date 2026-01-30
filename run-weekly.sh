#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== AIGC Weekly 生成脚本 ===${NC}\n"

# 1. 检查 agent 服务是否运行
echo -e "${YELLOW}[1/4] 检查 agent 服务状态...${NC}"
if ! nc -z localhost 2442 2>/dev/null; then
    echo -e "${RED}❌ Agent 服务未运行！${NC}"
    echo -e "\n${YELLOW}请在新终端启动 agent 服务：${NC}"
    echo -e "  ${GREEN}bash start-agent.sh${NC}"
    echo -e "\n${YELLOW}或者手动启动：${NC}"
    echo -e "  npx pnpm dev:agent"
    echo -e "\n${YELLOW}等待看到 'Server running at http://localhost:2442' 后，${NC}"
    echo -e "${YELLOW}再回到此终端运行：${NC}"
    echo -e "  ${GREEN}bash run-weekly.sh${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Agent 服务正常运行 (端口 2442)${NC}\n"

# 2. 清理旧文件
echo -e "${YELLOW}[2/4] 清理旧文件...${NC}"
rm -f data/app/drafts/*.md
rm -f data/app/logs/*.jsonl
rm -f data/app/weekly/*.md
echo -e "${GREEN}✅ 清理完成${NC}\n"

# 3. 发送生成请求
echo -e "${YELLOW}[3/4] 发送周刊生成请求...${NC}"
echo -e "${YELLOW}提示：这可能需要 1-3 小时，请耐心等待...${NC}\n"

START_TIME=$(date +%s)

# 发送请求（不设置超时，让 agent 自己控制）
curl -X POST http://localhost:2442/chat \
  -H 'Content-Type: application/json' \
  -d '{"prompt": "/weekly"}' \
  --no-buffer \
  2>&1

EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n"

# 4. 检查结果
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${YELLOW}[4/4] 检查生成结果...${NC}"

    DRAFT_COUNT=$(ls -1 data/app/drafts/*.md 2>/dev/null | wc -l)
    WEEKLY_COUNT=$(ls -1 data/app/weekly/*.md 2>/dev/null | wc -l)

    echo -e "执行时间: ${DURATION} 秒 ($(($DURATION / 60)) 分钟)"
    echo -e "草稿文件: ${DRAFT_COUNT} 个"
    echo -e "周刊文件: ${WEEKLY_COUNT} 个"

    if [ $WEEKLY_COUNT -gt 0 ]; then
        echo -e "\n${GREEN}✅ 周刊生成成功！${NC}"
        echo -e "\n生成的文件："
        ls -lh data/app/weekly/*.md
    else
        echo -e "\n${RED}❌ 周刊文件未生成${NC}"
        echo -e "请查看 drafts 目录和日志："
        echo -e "  ls -lh data/app/drafts/"
        echo -e "  ls -lh data/app/logs/"
    fi
else
    echo -e "${RED}❌ 命令执行失败 (退出码: $EXIT_CODE)${NC}"
    echo -e "常见退出码："
    echo -e "  7   - 无法连接到服务器"
    echo -e "  28  - 操作超时"
    echo -e "  52  - 服务器未返回数据"
    echo -e "  143 - 进程被终止 (SIGTERM)"
fi
