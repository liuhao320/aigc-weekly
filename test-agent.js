import path from 'node:path'
import process from 'node:process'
import { fileURLToPath } from 'node:url'
import { query } from '@anthropic-ai/claude-agent-sdk'
import dotenv from 'dotenv'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, 'worker/.env.local') })

console.info('🔍 测试 Agent SDK 配置...')
console.info('ANTHROPIC_BASE_URL:', process.env.ANTHROPIC_BASE_URL)
console.info('ANTHROPIC_API_KEY:', `${process.env.ANTHROPIC_API_KEY?.substring(0, 8)}...`)
console.info('Model:', process.env.ANTHROPIC_DEFAULT_SONNET_MODEL)
console.info('')

console.info('📡 发送测试请求...')
console.info('提示词: "你好，请回复一个字"')
console.info('')

async function main() {
  const result = query({
    prompt: '你好，请回复一个字',
    options: {
      cwd: process.cwd(),
      allowDangerouslySkipPermissions: true,
      permissionMode: 'bypassPermissions',
    },
  })

  let messageCount = 0

  try {
    for await (const message of result) {
      messageCount++
      console.info(`📨 消息 #${messageCount}:`, JSON.stringify(message, null, 2))

      if (messageCount > 5) {
        console.info('⚠️  已收到 5 条消息，停止测试')
        break
      }
    }

    console.info('✅ Agent SDK 测试完成')
  }
  catch (error) {
    console.error('❌ Agent SDK 错误:')
    console.error('错误类型:', error.constructor.name)
    console.error('错误信息:', error.message)
    console.error('错误栈:', error.stack)
    process.exit(1)
  }
}

main()
