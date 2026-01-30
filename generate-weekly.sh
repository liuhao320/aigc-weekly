#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  AIGC Weekly 一键生成脚本${NC}"
echo -e "${GREEN}========================================${NC}\n"

# 进入项目目录
cd "$(dirname "$0")"

# 步骤 1：检查并启动 Agent 服务
echo -e "${BLUE}[步骤 1/5] 检查 Agent 服务...${NC}"

PORT=2442
AGENT_PID=""

# 检查端口是否被占用
if lsof -ti :$PORT >/dev/null 2>&1; then
    AGENT_PID=$(lsof -ti :$PORT)
    echo -e "${YELLOW}⚠️  端口 $PORT 已被进程 $AGENT_PID 占用${NC}"
    echo -e "${GREEN}✅ Agent 服务已在运行，将使用现有服务${NC}\n"
    AGENT_ALREADY_RUNNING=true
else
    echo -e "${YELLOW}正在启动 Agent 服务...${NC}"

    # 后台启动 agent
    npx pnpm dev:agent > /tmp/agent-output.log 2>&1 &
    AGENT_PID=$!

    echo -e "${YELLOW}Agent PID: $AGENT_PID${NC}"
    echo -e "${YELLOW}等待服务启动（最多 30 秒）...${NC}"

    # 等待服务就绪
    RETRY=0
    MAX_RETRY=30
    while [ $RETRY -lt $MAX_RETRY ]; do
        if nc -z localhost $PORT 2>/dev/null; then
            echo -e "${GREEN}✅ Agent 服务启动成功！${NC}\n"
            AGENT_ALREADY_RUNNING=false
            break
        fi
        sleep 1
        RETRY=$((RETRY + 1))
        echo -n "."
    done

    if [ $RETRY -eq $MAX_RETRY ]; then
        echo -e "\n${RED}❌ Agent 服务启动超时${NC}"
        echo -e "${YELLOW}查看日志：${NC}"
        cat /tmp/agent-output.log
        exit 1
    fi
fi

# 步骤 2：清理旧文件
echo -e "${BLUE}[步骤 2/5] 清理旧文件...${NC}"
rm -f data/app/drafts/*.md 2>/dev/null
rm -f data/app/logs/*.jsonl 2>/dev/null
rm -f data/app/weekly/*.md 2>/dev/null
echo -e "${GREEN}✅ 清理完成${NC}\n"

# 步骤 3：发送生成请求
echo -e "${BLUE}[步骤 3/5] 生成周刊...${NC}"
echo -e "${YELLOW}提示：这可能需要 1-3 小时，请耐心等待${NC}"
echo -e "${YELLOW}你可以在另一个终端运行以下命令查看进度：${NC}"
echo -e "${YELLOW}  ls -lh data/app/drafts/  # 查看已抓取的文章${NC}\n"

START_TIME=$(date +%s)

# 发送请求
curl -X POST http://localhost:2442/chat \
  -H 'Content-Type: application/json' \
  -d '{"prompt": "/weekly"}' \
  --no-buffer \
  2>&1

CURL_EXIT=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n"

# 步骤 4：检查结果
echo -e "${BLUE}[步骤 4/5] 检查生成结果...${NC}"

DRAFT_COUNT=$(ls -1 data/app/drafts/*.md 2>/dev/null | wc -l | tr -d ' ')
WEEKLY_COUNT=$(ls -1 data/app/weekly/*.md 2>/dev/null | wc -l | tr -d ' ')

echo -e "${YELLOW}执行时间: ${DURATION} 秒 ($(($DURATION / 60)) 分钟)${NC}"
echo -e "${YELLOW}草稿文件: ${DRAFT_COUNT} 个${NC}"
echo -e "${YELLOW}周刊文件: ${WEEKLY_COUNT} 个${NC}\n"

if [ $WEEKLY_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ 周刊生成成功！${NC}\n"
    echo -e "${GREEN}生成的文件：${NC}"
    ls -lh data/app/weekly/*.md
    echo -e ""
elif [ $DRAFT_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  周刊未完全生成，但有 ${DRAFT_COUNT} 个草稿文件${NC}"
    echo -e "${YELLOW}可能的原因：${NC}"
    echo -e "  - 编辑或写作阶段出错"
    echo -e "  - 请查看日志：data/app/logs/${NC}\n"
else
    echo -e "${RED}❌ 未生成任何文件${NC}"
    echo -e "${YELLOW}可能的原因：${NC}"
    echo -e "  - Agent 抓取失败"
    echo -e "  - API 限流"
    echo -e "  - 请查看 Agent 日志：/tmp/agent-output.log${NC}\n"
fi

# 步骤 5：停止服务（可选）
echo -e "${BLUE}[步骤 5/5] 清理${NC}"

if [ "$AGENT_ALREADY_RUNNING" = true ]; then
    echo -e "${YELLOW}Agent 服务原本就在运行，保持运行状态${NC}"
    echo -e "${YELLOW}如需停止，请手动运行：lsof -ti :2442 | xargs kill${NC}\n"
else
    echo -e "${YELLOW}是否停止 Agent 服务？(y/N)${NC} "
    read -t 10 -n 1 STOP_AGENT
    echo ""

    if [[ "$STOP_AGENT" =~ ^[Yy]$ ]]; then
        if [ -n "$AGENT_PID" ] && kill -0 $AGENT_PID 2>/dev/null; then
            echo -e "${YELLOW}正在停止 Agent 服务 (PID: $AGENT_PID)...${NC}"
            kill $AGENT_PID 2>/dev/null
            sleep 2
            echo -e "${GREEN}✅ Agent 服务已停止${NC}\n"
        fi
    else
        echo -e "${YELLOW}保持 Agent 服务运行 (PID: $AGENT_PID)${NC}"
        echo -e "${YELLOW}如需停止，请运行：kill $AGENT_PID${NC}\n"
    fi
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  完成！${NC}"
echo -e "${GREEN}========================================${NC}\n"

# 显示最终统计
if [ $WEEKLY_COUNT -gt 0 ]; then
    echo -e "${GREEN}📊 最终统计：${NC}"
    echo -e "  ⏱  执行时间：$(($DURATION / 60)) 分钟"
    echo -e "  📝 草稿文章：${DRAFT_COUNT} 篇"
    echo -e "  📰 周刊文件：${WEEKLY_COUNT} 篇"
    echo -e "\n${GREEN}查看周刊：${NC}"
    echo -e "  cat data/app/weekly/*.md"
fi

exit 0
