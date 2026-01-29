# 本地运行指南

本文档帮助你在本地电脑上运行 AIGC Weekly 项目。

## 前置要求

- **Node.js**: v22 或更高版本
- **pnpm**: v10 或更高版本
- **Git**: 用于克隆仓库

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/liuhao320/aigc-weekly.git
cd aigc-weekly
```

### 2. 安装依赖

```bash
pnpm install
```

### 3. 配置环境变量

#### 3.1 根目录 `.env` 文件

创建 `.env` 文件（复制自 `.env.example`）：

```bash
cp .env.example .env
```

编辑 `.env` 文件，设置以下变量：

```env
# 生成随机密钥（必需）
PAYLOAD_SECRET=your-random-secret-here

# 应用基础 URL（可选，默认 http://localhost:3000）
NEXT_PUBLIC_BASE_URL=http://localhost:3000
```

**生成 PAYLOAD_SECRET**：

```bash
openssl rand -hex 32
```

#### 3.2 Worker 目录 `worker/.env.local` 文件

创建 `worker/.env.local` 文件（复制自 `worker/.env.example`）：

```bash
cp worker/.env.example worker/.env.local
```

编辑 `worker/.env.local` 文件，配置火山引擎豆包 Coding Plan：

```env
# 模型配置（使用火山引擎豆包 Coding Plan）
ANTHROPIC_BASE_URL=https://ark.cn-beijing.volces.com/api/coding
ANTHROPIC_AUTH_TOKEN=your-volces-api-key

# 模型名称
ANTHROPIC_DEFAULT_OPUS_MODEL=ark-code-latest
ANTHROPIC_DEFAULT_SONNET_MODEL=ark-code-latest
ANTHROPIC_DEFAULT_HAIKU_MODEL=ark-code-latest

# Claude 功能控制
DISABLE_NON_ESSENTIAL_MODEL_CALLS=1
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1

# Firecrawl API Key（用于网页抓取，可选）
FIRECRAWL_API_KEY=your-firecrawl-api-key
```

**如何获取火山引擎 API Key**：

1. 访问 [火山引擎控制台](https://console.volcengine.com/)
2. 开通 Coding Plan 套餐
3. 在管理页面获取 API Key

**如何获取 Firecrawl API Key**（可选）：

1. 访问 [Firecrawl](https://firecrawl.link/)
2. 注册并获取 API Key

### 4. 生成类型文件

```bash
pnpm generate:types
```

## 运行项目

### 启动 Claude Agent（生成周刊）

```bash
pnpm dev:agent
```

Agent 服务会启动在 `http://localhost:2442`

#### 使用 HTTP 接口生成周刊

在另一个终端窗口执行：

```bash
curl 'http://localhost:2442/chat' \
  -X POST \
  -H 'Content-Type: application/json' \
  --data-raw '{
    "prompt": "/weekly"
  }'
```

**指定日期生成周刊**：

```bash
curl 'http://localhost:2442/chat' \
  -X POST \
  -H 'Content-Type: application/json' \
  --data-raw '{
    "prompt": "/weekly 2026-01-28"
  }'
```

#### 使用 WebSocket 连接

```bash
# 连接 WebSocket 端点
ws://localhost:2442/ws
```

发送 JSON 数据：

```json
{
  "prompt": "/weekly"
}
```

### 启动 Next.js 应用（查看周刊网页）

```bash
pnpm dev
```

访问：

- **前台页面**: http://localhost:3000
- **Payload CMS 管理后台**: http://localhost:3000/admin

### 启动 Cloudflare Worker（可选）

需要 Docker 支持本地持久化：

```bash
pnpm dev:worker
```

访问：

- **HTTP 接口**: http://localhost:8787/chat
- **WebSocket 接口**: ws://localhost:8787/ws

## 周刊生成流程

Agent 会按照以下步骤自动生成周刊：

1. **收集内容**（researcher）- 从信息源抓取 AIGC 相关资讯
2. **筛选信息**（editor）- 去重、打分，生成高价值内容列表
3. **撰写内容**（writer）- 基于筛选结果撰写周刊
4. **审核修订**（reviewer）- 质量检查和修改建议

生成的周刊文件会保存在 `data/app/` 目录下。

## 常见问题

### Q: Agent 请求超时或无响应？

**A**: 检查以下几点：

1. 确认火山引擎 API Key 正确且有效
2. 检查网络连接是否正常
3. 查看 Agent 日志输出是否有错误信息

### Q: 如何查看 Agent 执行日志？

**A**: Agent 会在终端输出详细日志，包括每个阶段的执行情况。

### Q: 生成的周刊保存在哪里？

**A**: 周刊文件保存在 `data/app/` 目录下，文件名格式为 `aigc-weekly-y26-w05.md`。

### Q: 可以自定义周刊内容吗？

**A**: 可以修改以下文件自定义：

- `agent/.claude/commands/weekly.md` - 周刊生成命令
- `agent/.claude/agents/` - 子 Agent 配置
- `agent/.claude/skills/` - Agent 技能配置

## 部署到生产环境

### 部署到 Cloudflare

```bash
# 部署数据库和应用
pnpm deploy

# 或分步部署
pnpm deploy:database  # 部署数据库迁移
pnpm deploy:app       # 部署 Next.js 应用
pnpm deploy:worker    # 部署 Worker
```

**注意**：部署前需要在 `wrangler.jsonc` 中配置 Cloudflare 绑定（D1、R2 等）。

## 项目结构

```
aigc-weekly/
├── agent/              # Claude Agent 源代码
│   ├── .claude/       # Agent 配置（技能、命令、子 Agent）
│   ├── index.ts       # Agent 服务器入口
│   └── mcp.json       # MCP 服务器配置
├── app/               # Next.js 应用
├── worker/            # Cloudflare Worker
├── collections/       # Payload CMS 数据模型
├── data/              # Agent 工作目录（本地生成）
├── .env              # 根目录环境变量（不提交到 git）
└── worker/.env.local  # Worker 环境变量（不提交到 git）
```

## 技术支持

如有问题，请查看：

- [项目 README](README.md)
- [CLAUDE.md](CLAUDE.md) - Claude Code 项目指南
- [GitHub Issues](https://github.com/liuhao320/aigc-weekly/issues)

---

**祝你使用愉快！** 🚀
