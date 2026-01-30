import type { Query } from '@anthropic-ai/claude-agent-sdk'
import type { WSContext } from 'hono/ws'
import path from 'node:path'
import process from 'node:process'
import { query } from '@anthropic-ai/claude-agent-sdk'
import { serve } from '@hono/node-server'
import { createNodeWebSocket } from '@hono/node-ws'
import dotenv from 'dotenv'
import { Hono } from 'hono'
import { streamText } from 'hono/streaming'
import { agentConfig, isDev } from './config'
import { mcpServers } from './mcp.json' assert { type: 'json' }

if (isDev) {
  dotenv.config({ path: path.resolve(import.meta.dirname, '../worker/.env.local') })
}

const CWD = process.env.CWD ?? path.resolve(import.meta.dirname, '../data/app')

console.info('💡 Agent CWD:', CWD)

const app = new Hono()
const wsClients = new Set<WSContext>()
const { injectWebSocket, upgradeWebSocket } = createNodeWebSocket({ app })

app.get(
  '/ws',
  upgradeWebSocket(() => {
    return {
      onOpen(_event, ws) {
        wsClients.add(ws)
      },
      onClose(_event, ws) {
        wsClients.delete(ws)
      },
      async onMessage(event, ws) {
        const res = await app.request('/chat', {
          method: 'POST',
          body: event.data as string,
        })
        ws.send(await res.text())
      },
    }
  }),
)

/**
 对话接口
curl 'http://localhost:2442/chat' \
-X POST \
--data-raw '{
  "prompt": "写一个 Hello World 的网页"
}'
 */
app.post('/chat', async (c) => {
  const body = await c.req.json()
  const { prompt } = body

  const result: Query = query({
    prompt: prompt || '/weekly',
    options: {
      ...body,
      cwd: CWD,
      mcpServers,
      ...agentConfig,
    },
  })

  return streamText(c, async (stream) => {
    try {
      for await (const message of result) {
        if (message.type === 'system' && message.subtype === 'init') {
          await stream.write(`${JSON.stringify({ type: 'agent', resume: message.session_id })}\n`)
          // 不要关闭流，让 Agent 继续执行
        }

        const log = JSON.stringify(message)
        wsClients.forEach(ws => ws.send(log))
        console.info(log)
      }
    }
    catch (error) {
      console.error('🚨 Agent Error:', error)
      if (!stream.closed) {
        await stream.close()
      }
    }
  })
})

app.get('*', (c) => {
  return c.text('Agent is running. Connect via /ws for WebSocket or POST /chat for chat.')
})

console.info('🚀 Starting Agent Server...')
const server = serve({
  fetch: app.fetch,
  hostname: process.env.HOSTNAME ?? '0.0.0.0',
  port: Number(process.env.PORT ?? 2442),
}, (info) => {
  console.info(`🚀 Agent Server Run on: http://${info.address}:${info.port}`)
})

injectWebSocket(server)
