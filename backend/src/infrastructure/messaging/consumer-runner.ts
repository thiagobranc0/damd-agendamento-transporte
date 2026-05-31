import { getRabbitMQChannel, closeRabbitMQ } from './rabbitmq-connection'

const EXCHANGE = process.env.RIDES_EXCHANGE ?? 'rides.events'

interface ConsumerConfig<T> {
  /** Nome da fila durável que este consumidor escuta. */
  queue: string
  /** Routing key vinculada à fila no exchange topic. */
  routingKey: string
  /** Handler de domínio chamado para cada mensagem (envelope JSON já parseado). */
  handler: (envelope: T) => void
  /** Rótulo usado nos logs deste processo (ex.: "consumer:driver"). */
  label: string
}

/**
 * Runner genérico de consumidor. Cada entry point (consumer-driver, consumer-passenger)
 * chama esta função com sua própria fila/routing key/handler. Responsabilidade única:
 * conectar, declarar topologia de forma idempotente, consumir com ack manual e encerrar
 * de forma graciosa. Reutiliza a conexão singleton de rabbitmq-connection.ts.
 */
export async function startConsumer<T>({ queue, routingKey, handler, label }: ConsumerConfig<T>): Promise<void> {
  const channel = await getRabbitMQChannel()

  await channel.assertExchange(EXCHANGE, 'topic', { durable: true })
  await channel.assertQueue(queue, { durable: true })
  await channel.bindQueue(queue, EXCHANGE, routingKey)

  channel.prefetch(1)

  console.log(`[${label}] Aguardando "${routingKey}" na fila "${queue}"...`)

  channel.consume(queue, (msg) => {
    if (!msg) return
    try {
      const envelope = JSON.parse(msg.content.toString()) as T
      handler(envelope)
      channel.ack(msg)
    } catch (err) {
      console.error(`[${label}] Erro ao processar "${routingKey}":`, (err as Error).message)
      channel.nack(msg, false, false)
    }
  })

  const shutdown = async () => {
    console.log(`[${label}] Encerrando...`)
    await closeRabbitMQ()
    process.exit(0)
  }

  process.on('SIGINT', shutdown)
  process.on('SIGTERM', shutdown)
}
