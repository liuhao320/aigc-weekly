---
name: batch-research
description: 批量并发执行信息采集任务的技能。
---

# Batch Research 技能指南

此技能指导 Agent 如何高效、并发地从多个数据源采集信息。

## 核心原则

1. **分批并行**：利用 `Task` 工具的并发调用能力，**每批最多 3 个任务**，避免 API 限流
2. **参数块传递**：从上游接收参数块，**原样传递**给每个下游任务
3. **结果导向**：关注最终生成的草稿文件数量和质量
4. **限流保护**：严格控制并发数，防止触发 429 错误

## 参数块格式

所有任务必须携带以下 YAML 格式的参数块：

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

**严禁修改或省略任何字段。**

## 使用步骤

### 1. 准备阶段：解析与生成 URL

解析上游传入的参数块，提取 `start_date` 和 `end_date`。

对于动态 URL，使用 `.claude/utils.js` 中的辅助函数：

```javascript
import { generateHNUrls } from '../../utils.js'

const urls = generateHNUrls(start_date, end_date)
// 返回: [
//   "https://news.ycombinator.com/front?day=2026-03-22",
//   "https://news.ycombinator.com/front?day=2026-03-23",
//   ...
// ]
```

### 2. 执行阶段：分批并发调度

**重要**：为避免 API 限流（429 错误），必须分批执行，每批最多 3 个任务。

**正确做法**：

````text
我将分批使用 Task 工具调度 crawler 子任务。

## 第一批（3个任务）

[Task 1]
Task(subagent_type='crawler', prompt='''
抓取 https://news.ycombinator.com/front?day=2026-03-25

```yaml
# 周刊参数（请原样传递）
week_id: Y26W12
start_date: 2026-03-22
end_date: 2026-03-28
timezone: UTC+0
```
''')

[Task 2]
Task(subagent_type='crawler', prompt='''
抓取 https://www.anthropic.com/engineering

```yaml
# 周刊参数（请原样传递）
week_id: Y26W12
start_date: 2026-03-22
end_date: 2026-03-28
timezone: UTC+0
```
''')

[Task 3]
Task(subagent_type='crawler', prompt='''
抓取 https://baoyu.io/

```yaml
# 周刊参数（请原样传递）
week_id: Y26W12
start_date: 2026-03-22
end_date: 2026-03-28
timezone: UTC+0
```
''')

## 等待第一批完成后，再启动第二批...

````

**错误做法**：一次性启动超过 3 个任务（会触发 API 限流）

### 3. 监控阶段：错误处理

- 某个子任务失败不影响其他子任务
- crawler 内部已实现重试机制（2 次重试 + 指数退避）
- 失败记录会写入 `logs/crawl-failures.jsonl`

### 4. 汇总阶段：生成报告

在所有任务完成后，汇总结果：

```markdown
## 抓取报告

**参数回显**：

- week_id: Y26W12
- 时间范围: 2026-03-22 至 2026-03-28
- 时区: UTC+0

**统计**：

- 总任务数: 15
- 成功: 12
- 失败: 3

**成功列表**：
| 源 | 文件 |
|---|---|
| Hacker News (03-25) | drafts/2026-03-25-hn-xxx.md |
| Anthropic Blog | drafts/2026-03-24-anthropic-xxx.md |

**失败列表**：
| 源 | 错误 |
|---|---|
| daily.dev | 429 Too Many Requests |
```

## 最佳实践

- **参数传递**：每个 Task prompt 必须包含完整的参数块
- **并发控制**：**严格限制每批 3 个任务**，避免 API 限流
  - 启动第一批 3 个任务
  - 等待全部完成
  - 启动第二批 3 个任务
  - 重复直到完成
- **时区一致性**：所有时间判断基于 UTC+0
- **限流保护**：如果遇到 429 错误，等待 10 秒后重试
