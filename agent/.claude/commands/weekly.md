---
description: 创建周刊
---

请你作为一名资深的技术编辑，帮助我创建一份关于人工智能生成内容（AIGC）的周刊。

## 时间计算

使用 `.claude/utils.js` 中的 `getWeekInfo()` 函数计算时间参数：

```javascript
import { formatWeekParams, getWeekInfo, getWeeklyFilename, getWeeklyTitle } from '../utils.js'

// 使用用户输入的日期，或默认当前日期
const weekInfo = getWeekInfo($1) // $1 为用户输入的日期参数（可选）

// 生成参数块
const params = formatWeekParams(weekInfo)

// 生成文件名和标题
const filename = getWeeklyFilename(weekInfo) // 如 "aigc-weekly-y25-w02.md"
const title = getWeeklyTitle(weekInfo) // 如 "Agili 的 AIGC 周刊（Y26W12）"
```

## 参数块格式

所有下游任务必须接收并原样传递以下参数块：

```yaml
# 周刊参数（请原样传递给下游任务）
week_id: Y26W12
week_number: 12
year_short: 26
year_full: 2026
start_date: 2026-03-22
end_date: 2026-03-28
timezone: UTC+0
```

## 准备工作

在开始各阶段任务前，必须完成：

1. 调用 `getWeekInfo()` 计算时间参数
2. 创建 `drafts/` 目录（如不存在）
3. 生成参数块，用于传递给所有下游任务

## 工作流程

请按照以下步骤操作，使用 `Task` 工具协调各个子任务完成工作：

### 1. 收集内容 (Phase 1)

使用 `Task` 工具调用 `researcher` 子任务：

````
prompt: |
  收集本周 AIGC 相关资讯。

  **重要**：必须读取 `.claude/REFERENCE.md` 文件获取所有信息源，包括：
  - Important Resources（约10个）
  - Blogs & Websites（约13个）
  - KOL & Influencers（约3个）

  总共应该抓取约 26-30 个信息源！不要遗漏任何源！

  ```yaml
  # 周刊参数（请原样传递给下游任务）
  week_id: {weekInfo.weekId}
  week_number: {weekInfo.weekNumber}
  year_short: {weekInfo.yearShort}
  year_full: {weekInfo.yearFull}
  start_date: {weekInfo.startDate}
  end_date: {weekInfo.endDate}
  timezone: UTC+0
  ```

  请根据上述时间范围从 **所有** 信息源抓取内容，保存到 drafts/ 目录。

```

- 产出：`drafts` 目录下的原始内容文件

### 2. 筛选信息 (Phase 2)

使用 `Task` 工具调用 `editor` 子任务：

```

prompt: |
筛选 drafts/ 目录中的内容。

```yaml
# 周刊参数
week_id: {weekInfo.weekId}
start_date: {weekInfo.startDate}
end_date: {weekInfo.endDate}
timezone: UTC+0
```

请对内容进行筛选、去重和打分，生成 drafts.yaml。

```

- 产出：`drafts.yaml` 高价值内容列表

### 3. 撰写内容 (Phase 3)

使用 `Task` 工具调用 `writer` 子任务：

```

prompt: |
撰写周刊内容。

```yaml
# 周刊参数
week_id: {weekInfo.weekId}
title: {title}
filename: {filename}
start_date: {weekInfo.startDate}
end_date: {weekInfo.endDate}
```

请基于 drafts.yaml 撰写周刊，保存为 {filename}。

```

- 产出：最终的 Markdown 周刊文件

### 4. 审核与修订 (Phase 4)

使用 `Task` 工具调用 `reviewer` 子任务：

```

prompt: |
审核周刊文件 {filename}。

```yaml
# 周刊参数
week_id: {weekInfo.weekId}
start_date: {weekInfo.startDate}
end_date: {weekInfo.endDate}
```

```

**循环逻辑**：
- 如果 Reviewer 返回 "PASS"，则任务完成。
- 如果 Reviewer 返回修改意见，使用 `Task` 调用 `writer` 子任务进行修改。
- 再次使用 `Task` 调用 `reviewer` 子任务进行复核。
- 此过程最多重复 3 次。如果 3 次后仍未通过，请保存当前版本并提示用户人工介入。

请务必一次性完成所有任务，过程中无需向我确认，向我呈现最终的周刊内容。
```
````
