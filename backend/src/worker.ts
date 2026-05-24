import 'dotenv/config'
import amqplib from 'amqplib'
import { notifyDriverHandler } from './infrastructure/messaging/handlers/notify-driver.handler'
import { notifyPassengerHandler } from './infrastructure/messaging/handlers/notify-passenger.handler'

const RABBITMQ_URL = process.env.RABBITMQ_URL ?? 'amqp://guest:guest@localhost:5672'
const EXCHANGE = process.env.RIDES_EXCHANGE ?? 'rides.events'
const QUEUE_DRIVER = 'notifications.driver'
const QUEUE_PASSENGER = 'notifications.passenger'

async function start(): Promise<void> {
  console.log('[worker] Conectando ao RabbitMQ...')
  const connection = await amqplib.connect(RABBITMQ_URL)
  const channel = await connection.createChannel()

  await channel.assertExchange(EXCHANGE, 'topic', { durable: true })

  await channel.assertQueue(QUEUE_DRIVER, { durable: true })
  await channel.bindQueue(QUEUE_DRIVER, EXCHANGE, 'ride.created')

  await channel.assertQueue(QUEUE_PASSENGER, { durable: true })
  await channel.bindQueue(QUEUE_PASSENGER, EXCHANGE, 'ride.status_updated')

  channel.prefetch(1)

  console.log(`[worker] Aguardando eventos em "${EXCHANGE}"...`)

  channel.consume(QUEUE_DRIVER, (msg) => {
    if (!msg) return
    try {
      const envelope = JSON.parse(msg.content.toString())
      notifyDriverHandler(envelope)
      channel.ack(msg)
    } catch (err) {
      console.error('[worker] Erro ao processar ride.created:', (err as Error).message)
      channel.nack(msg, false, false)
    }
  })

  channel.consume(QUEUE_PASSENGER, (msg) => {
    if (!msg) return
    try {
      const envelope = JSON.parse(msg.content.toString())
      notifyPassengerHandler(envelope)
      channel.ack(msg)
    } catch (err) {
      console.error('[worker] Erro ao processar ride.status_updated:', (err as Error).message)
      channel.nack(msg, false, false)
    }
  })

  const shutdown = async () => {
    console.log('[worker] Encerrando...')
    await channel.close()
    await connection.close()
    process.exit(0)
  }

  process.on('SIGINT', shutdown)
  process.on('SIGTERM', shutdown)
}

start().catch((err) => {
  console.error('[worker] Falha ao iniciar:', err.message)
  process.exit(1)
})
