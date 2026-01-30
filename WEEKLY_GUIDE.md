# 周刊生成使用指南

本指南说明如何使用 Agent 自动生成 AIGC 周刊。

## 快速开始

### 1️⃣ 启动 Agent 服务（终端 1）

```bash
bash start-agent.sh
```

或者手动启动：

```bash
npx pnpm dev:agent
```

**等待看到**：

```
Server running at http://localhost:2442
```

### 2️⃣ 生成周刊（终端 2 - 新开）

```bash
bash run-weekly.sh
```

## 常见问题

### Q: 遇到 "EADDRINUSE: address already in use" 错误

**原因**：端口 2442 已被占用

**解决方案**：使用 `start-agent.sh` 脚本，它会自动停止旧进程并启动新进程

```bash
bash start-agent.sh
```

### Q: 遇到 "exit code 143" 错误

**原因**：Agent 进程被终止了

**解决方案**：

1. 确保 Agent 服务正在运行：`bash start-agent.sh`
2. 等待服务启动完成
3. 在新终端运行：`bash run-weekly.sh`

### Q: 只抓取了 Hacker News，没有其他源

**原因**：旧版本 researcher 错误使用了 Skill 工具

**解决方案**：

1. 拉取最新代码：`git pull`
2. 重启 Agent 服务（Ctrl+C 停止，然后 `bash start-agent.sh`）
3. 重新生成周刊：`bash run-weekly.sh`

### Q: 如何停止 Agent 服务

在运行 Agent 的终端按 `Ctrl+C`

或者查找进程并停止：

```bash
lsof -ti :2442 | xargs kill
```

## 技术细节

### 抓取策略

- **优先使用**：Firecrawl MCP 工具（更好的内容提取）
- **自动降级**：Firecrawl 失败时切换到 WebFetch
- **智能重试**：每个 URL 独立尝试 Firecrawl
- **频率控制**：每次请求间隔 2 秒，避免 429 限流

### 并发控制

- **Researcher 层**：每批最多 3 个 crawler 任务
- **Crawler 层**：每次请求后等待 2 秒
- **多层防护**：避免触发 API 限流

### 信息源

总共 26+ 信息源，包括：

- **Important Resources**（10个）：Hacker News, Reddit, GitHub Trending 等
- **Blogs & Websites**（13个）：Anthropic, OpenAI, DeepMind 等
- **KOL & Influencers**（3个）：宝玉、Ben's Bites、Lenny's Newsletter

完整列表见：`agent/.claude/REFERENCE.md`

## 预期执行时间

- **单日测试**（test-yesterday.sh）：10-15 分钟
- **完整周刊**：1-3 小时

## 生成的文件

- **drafts/**：抓取的原始文章（Markdown 格式）
- **logs/**：错误日志和失败记录
- **weekly/**：最终生成的周刊文章

## 脚本说明

| 脚本                | 用途                               |
| ------------------- | ---------------------------------- |
| `start-agent.sh`    | 智能启动 Agent（自动处理端口占用） |
| `run-weekly.sh`     | 生成周刊（含检查和统计）           |
| `test-yesterday.sh` | 快速测试（仅抓取昨天的 HN）        |
| `test-firecrawl.js` | 测试 Firecrawl MCP 连接            |

## 提交历史（本次会话）

- `a5e6176` - Firecrawl 智能降级策略
- `49065f8` - 请求频率控制（2 秒间隔）
- `c0acd52` - 修正 researcher 错误使用 Skill 工具
- `077913e` - 增强版周刊生成脚本
