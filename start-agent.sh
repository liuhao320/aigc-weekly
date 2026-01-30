#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== 启动 Agent 服务 ===${NC}\n"

# 检查端口是否被占用
PORT=2442
PID=$(lsof -ti :$PORT 2>/dev/null)

if [ -n "$PID" ]; then
    echo -e "${YELLOW}⚠️  端口 $PORT 已被进程 $PID 占用${NC}"
    echo -e "${YELLOW}正在停止旧进程...${NC}"
    kill $PID 2>/dev/null
    sleep 2

    # 检查是否成功停止
    if lsof -ti :$PORT >/dev/null 2>&1; then
        echo -e "${RED}❌ 无法停止旧进程，尝试强制终止...${NC}"
        kill -9 $PID 2>/dev/null
        sleep 1
    fi

    echo -e "${GREEN}✅ 旧进程已停止${NC}\n"
fi

# 启动新进程
echo -e "${YELLOW}正在启动 Agent 服务...${NC}"
echo -e "${YELLOW}提示：按 Ctrl+C 可停止服务${NC}\n"

cd "$(dirname "$0")"
npx pnpm dev:agent
