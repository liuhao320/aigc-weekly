# Agili 的 AIGC 周刊

一个由 Agentic AI Agent 驱动的 AIGC（人工智能生成内容）精选周刊。本项目利用最新的 AI 和 Serverless 技术，为您提供最新的资讯、工具和资源。

---

**在线阅读**: <https://aigc-weekly.agi.li>

**RSS订阅**: <https://aigc-weekly.agi.li/rss.xml>

![aigc-weekly](https://socialify.git.ci/miantiao-me/aigc-weekly/image?description=1&forks=1&name=1&owner=1&pattern=Circuit+Board&stargazers=1&theme=Auto)

## 🚀 特性

- **AI 智能策展**：利用 Agentic AI Agent 自动发现和筛选内容。
- **现代技术栈**：基于 Next.js 15、Payload CMS 3.0 和 Cloudflare 边缘基础设施构建。
- **Serverless 架构**：完全部署在 Cloudflare (Workers, D1, R2, Containers) 上，实现高性能和低延迟。
- **Agent MCP 集成**：使用模型上下文协议 (MCP) 允许 AI Agent 直接与 CMS 交互。

## 🛠 技术栈

- **框架**：[Next.js](https://nextjs.org/) (App Router) & [OpenNext](https://opennext.js.org/)
- **CMS**：[Payload CMS](https://payloadcms.com/) (Headless)
- **数据库**：[Cloudflare D1](https://developers.cloudflare.com/d1/) (SQLite)
- **存储**：[Cloudflare R2](https://developers.cloudflare.com/r2/) (对象存储)
- **Agent 框架**：[OpenCode](https://opencode.ai/)
- **Agent 运行时**：[Cloudflare Containers](https://developers.cloudflare.com/containers/) （需要付费套餐，或者在本地运行）
- **边缘运行时**：[Cloudflare Workers](https://workers.cloudflare.com/)

## 🏗 架构

本项目包含三个主要组件：

1. **Next.js 应用 (`app/`)**：负责面向读者的前端页面以及 Payload CMS 管理界面。
2. **OpenCode Agent (`agent/`)**：一个独立的 Agent 服务，运行在 **Cloudflare Containers** 上，负责收集信息并通过 MCP 更新 CMS。
3. **Cloudflare Worker (`worker/`)**：转发请求到 Container 并控制其生命周期。

## 🏁 快速开始

### 前置要求

- **Node.js**：v22 或更高版本
- **pnpm**：v10 或更高版本
- **Cloudflare 账号**：用于 D1、R2 和 Workers 部署。

### 安装

1. 克隆仓库：

   ```bash
   git clone https://github.com/miantiao-me/aigc-weekly.git
   cd aigc-weekly
   ```

2. 安装依赖：
   ```bash
   pnpm install
   ```

### 配置

1. **环境变量**：
   配置必要的环境变量：
   - 复制 `.env.example` 为 `.env.local` 并填写相应值。
   - 复制 `worker/.env.example` 为 `worker/.env.local` 并填写相应值。

   确保你已经配置了必要的 Cloudflare 绑定, 你需要在 `wrangler.jsonc` 中配置以下绑定：
   - `D1`：数据库
   - `R2`：对象存储
   - `PAYLOAD_SECRET`：一个安全的随机字符串。

2. **生成类型**：

   ```bash
   pnpm generate:types
   ```

3. **配置 MCP 和 Agent**：
   你可以在 `agent/opencode.json` 配置 MCP Server 和模型，在 `agent/.opencode/` 目录修改 Agent 的技能、子 Agent 和命令等配置。

   项目使用 [**Firecrawl**](https://firecrawl.link/playground) 进行网页爬取和信息提取, 你需要在 Firecrawl 注册账号并获取 API Key，然后在 `worker/.env.local` 中配置 `FIRECRAWL_API_KEY`。

### 本地运行

- **Next.js 应用**：

  ```bash
  pnpm dev
  ```

  访问应用：`http://localhost:3000` 和 `http://localhost:3000/admin`。

- **Cloudflare Worker（包含 Agent）**：

  ```bash
  pnpm dev:worker
  ```

  需要安装 Docker 以运行本地沙箱。Worker 会自动启动 OpenCode Agent 容器。

## 🚀 部署

本项目设计为部署在 Cloudflare 上。

1. **部署数据库和应用**：

   ```bash
   pnpm deploy
   ```

   此命令会运行 `deploy:database`（迁移）和 `deploy:app`（OpenNext 构建与上传）。

2. **部署 Worker**：
   ```bash
   pnpm deploy:worker
   ```

## 📂 项目结构

- `app/`：Next.js 应用源代码。
- `agent/`：OpenCode Agent 配置和技能定义。
- `worker/`：Cloudflare Worker 源代码。
- `collections/`：Payload CMS 数据模型。
- `migrations/`：数据库迁移文件。
- `public/`：静态资源。

## 🤖 AI 代码助手

本项目包含 [AGENTS.md](AGENTS.md) 文件，为 AI 代码助手（如 Claude Code、Cursor、Copilot 等）提供开发指南，包括命令、代码风格和架构信息。

## 📄 许可证

本项目采用 [GNU Affero General Public License v3.0](LICENSE) 许可证。
