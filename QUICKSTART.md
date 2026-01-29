# 🚀 3 步快速开始

## 第一步：安装（在你的本地电脑）

```bash
git clone https://github.com/liuhao320/aigc-weekly.git
cd aigc-weekly
bash setup.sh
```

## 第二步：配置 API Key

编辑 `worker/.env.local` 文件，填入你的火山引擎 API Key：

```env
ANTHROPIC_AUTH_TOKEN=你的火山引擎API密钥
```

**获取方式**：访问 https://console.volcengine.com/ 开通 Coding Plan

## 第三步：运行

### 启动 Agent（在第1个终端）

```bash
pnpm dev:agent
```

### 生成周刊（在第2个终端）

```bash
pnpm weekly
```

就这么简单！🎉

---

## 查看网页（可选）

```bash
pnpm dev
```

访问 http://localhost:3000

---

## 详细文档

- [完整安装指南](LOCAL_SETUP.md)
- [项目说明](README.md)
