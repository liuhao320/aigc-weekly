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
console.info('  ANTHROPIC_BASE_URL:', process.env.ANTHROPIC_BASE_URL)
console.info('  ANTHROPIC_API_KEY:', `${process.env.ANTHROPIC_API_KEY?.substring(0, 12)}...`)
console.info('  ANTHROPIC_DEFAULT_OPUS_MODEL:', process.env.ANTHROPIC_DEFAULT_OPUS_MODEL)
console.info('  ANTHROPIC_DEFAULT_SONNET_MODEL:', process.env.ANTHROPIC_DEFAULT_SONNET_MODEL)
console.info('  ANTHROPIC_DEFAULT_HAIKU_MODEL:', process.env.ANTHROPIC_DEFAULT_HAIKU_MODEL)
console.info('  FIRECRAWL_API_KEY:', `${process.env.FIRECRAWL_API_KEY?.substring(0, 8)}...`)
console.info('')

// Test with timeout
console.info('📡 开始测试 Agent SDK (30秒超时)...')
console.info('提示词: "测试一下"')
console.info('')

const timeoutMs = 30000
const timeoutPromise = new Promise((_, reject) => {
  setTimeout(() => reject(new Error('请求超时 30 秒')), timeoutMs)
})

async function main() {
  const queryPromise = (async () => {
    console.info('⏳ 调用 query() 函数...')

    const result = query({
      prompt: '测试一下',
      options: {
        cwd: process.cwd(),
        allowDangerouslySkipPermissions: true,
        permissionMode: 'bypassPermissions',
      },
    })

    console.info('✅ query() 返回了 iterator')
    console.info('⏳ 等待第一条消息...')

    let messageCount = 0
    const startTime = Date.now()

    for await (const message of result) {
      const elapsed = ((Date.now() - startTime) / 1000).toFixed(1)
      messageCount++

      console.info(`\n📨 消息 #${messageCount} (${elapsed}秒):`)
      console.info('  类型:', message.type)
      if (message.subtype)
        console.info('  子类型:', message.subtype)
      if (message.text)
        console.info('  文本:', message.text.substring(0, 100))
      console.info('  完整消息:', JSON.stringify(message, null, 2))

      // 只显示前 3 条消息
      if (messageCount >= 3) {
        console.info('\n✅ 已收到 3 条消息,测试成功!')
        break
      }
    }

    if (messageCount === 0) {
      throw new Error('iterator 没有产生任何消息')
    }
  })()

  try {
    await Promise.race([queryPromise, timeoutPromise])
    console.info('\n✅ 测试完成')
  }
  catch (error) {
    console.error('\n❌ 错误:')
    console.error('  类型:', error.constructor.name)
    console.error('  消息:', error.message)
    if (error.stack) {
      console.error('  堆栈:', error.stack)
    }
    if (error.status) {
      console.error('  HTTP 状态:', error.status)
    }
    if (error.error) {
      console.error('  详细错误:', error.error)
    }
    console.error('\n完整错误对象:', JSON.stringify(error, null, 2))
    process.exit(1)
  }
}

main()
