import path from 'node:path'
import process from 'node:process'
import { fileURLToPath } from 'node:url'
import Anthropic from '@anthropic-ai/sdk'
import dotenv from 'dotenv'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, 'worker/.env.local') })

console.info('🔍 测试 API 配置...')
console.info('Base URL:', process.env.ANTHROPIC_BASE_URL)
console.info('API Key:', `${process.env.ANTHROPIC_API_KEY?.substring(0, 8)}...`)
console.info('Model:', process.env.ANTHROPIC_DEFAULT_SONNET_MODEL)
console.info('')

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
  baseURL: process.env.ANTHROPIC_BASE_URL,
})

console.info('📡 发送测试请求到 Volces API...')

async function main() {
  try {
    const message = await client.messages.create({
      model: process.env.ANTHROPIC_DEFAULT_SONNET_MODEL || 'ark-code-latest',
      max_tokens: 10,
      messages: [{ role: 'user', content: 'Hi' }],
    })

    console.info('✅ API 连接成功！')
    console.info('响应:', JSON.stringify(message, null, 2))
  }
  catch (error) {
    console.error('❌ API 连接失败:')
    console.error('错误类型:', error.constructor.name)
    console.error('错误信息:', error.message)
    if (error.status) {
      console.error('HTTP 状态:', error.status)
    }
    if (error.headers) {
      console.error('响应头:', error.headers)
    }
    console.error('完整错误:', error)
    process.exit(1)
  }
}

main()
