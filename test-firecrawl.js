import path from 'node:path'
import process from 'node:process'
import { fileURLToPath } from 'node:url'
import { query } from '@anthropic-ai/claude-agent-sdk'
import dotenv from 'dotenv'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

// Load environment variables
console.info('📂 正在加载环境变量...')
const result = dotenv.config({ path: path.resolve(__dirname, 'worker/.env.local') })
if (result.error) {
  console.error('❌ 加载 .env.local 失败:', result.error)
  process.exit(1)
}
console.info('✅ 已加载', Object.keys(result.parsed || {}).length, '个环境变量')
console.info('')

// Display configuration
console.info('🔍 当前配置:')
console.info('  FIRECRAWL_API_KEY:', `${process.env.FIRECRAWL_API_KEY?.substring(0, 8)}...`)
console.info('')

console.info('📡 开始测试 Firecrawl MCP...')
console.info('测试任务: 使用 Firecrawl 抓取 Anthropic 博客首页')
console.info('')

const timeoutMs = 60000 // 60秒超时
const timeoutPromise = new Promise((_, reject) => {
  setTimeout(() => reject(new Error('请求超时 60 秒')), timeoutMs)
})

async function main() {
  const queryPromise = (async () => {
    console.info('⏳ 调用 query() 函数...')

    const result = query({
      prompt: `请使用 mcp__firecrawl__firecrawl_scrape 工具抓取以下网页:

https://www.anthropic.com/news

抓取成功后,请告诉我:
1. 页面标题是什么
2. 找到了多少篇文章
3. 列出前3篇文章的标题

注意: 只使用 Firecrawl MCP 工具,不要使用其他工具。`,
      options: {
        cwd: process.cwd(),
        allowDangerouslySkipPermissions: true,
        permissionMode: 'bypassPermissions',
      },
    })

    console.info('✅ query() 返回了 iterator')
    console.info('⏳ 等待响应...')
    console.info('')

    let messageCount = 0
    const startTime = Date.now()

    for await (const message of result) {
      const elapsed = ((Date.now() - startTime) / 1000).toFixed(1)
      messageCount++

      if (message.type === 'assistant') {
        console.info(`\n📨 消息 #${messageCount} (${elapsed}秒):`)

        // 检查是否有文本内容
        if (message.message?.content) {
          for (const content of message.message.content) {
            if (content.type === 'text') {
              console.info('📝 文本:', content.text)
            }
            else if (content.type === 'tool_use') {
              console.info('🔧 工具调用:', content.name)
              if (content.name.includes('firecrawl')) {
                console.info('✅ 正在使用 Firecrawl!')
                console.info('   参数:', JSON.stringify(content.input, null, 2))
              }
            }
          }
        }
      }
      else if (message.type === 'user') {
        // 工具结果
        if (message.message?.content) {
          for (const content of message.message.content) {
            if (content.type === 'tool_result' && content.tool_use_id) {
              console.info(`\n🔄 工具结果 (${elapsed}秒):`)
              if (content.is_error) {
                console.error('❌ 工具执行失败:', content.content)
              }
              else {
                console.info('✅ 工具执行成功')
                const resultStr = typeof content.content === 'string'
                  ? content.content
                  : JSON.stringify(content.content)
                console.info('   结果预览:', resultStr.substring(0, 500))
              }
            }
          }
        }
      }
      else if (message.type === 'system' && message.subtype === 'init') {
        console.info('🚀 Agent 初始化完成')
        console.info('   可用的 MCP 服务器:', message.mcp_servers?.map(s => s.name).join(', ') || '无')
      }

      // 限制输出前10条消息
      if (messageCount >= 10) {
        console.info('\n⚠️  已收到 10 条消息，停止测试')
        break
      }
    }

    if (messageCount === 0) {
      throw new Error('iterator 没有产生任何消息')
    }

    console.info('\n✅ 测试完成！')
  })()

  try {
    await Promise.race([queryPromise, timeoutPromise])
  }
  catch (error) {
    console.error('\n❌ 错误:')
    console.error('  类型:', error.constructor.name)
    console.error('  消息:', error.message)
    if (error.stack) {
      console.error('  堆栈:', error.stack)
    }
    process.exit(1)
  }
}

main()
