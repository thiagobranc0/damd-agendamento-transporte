import amqplib, { ChannelModel, Channel } from 'amqplib'

let connection: ChannelModel | null = null
let channel: Channel | null = null

export async function getRabbitMQChannel(): Promise<Channel> {
  if (channel) return channel

  const url = process.env.RABBITMQ_URL ?? 'amqp://guest:guest@localhost:5672'
  connection = await amqplib.connect(url)
  channel = await connection.createChannel()

  connection.on('error', (err) => {
    console.error('[RabbitMQ] Connection error:', err.message)
    connection = null
    channel = null
  })

  connection.on('close', () => {
    console.warn('[RabbitMQ] Connection closed')
    connection = null
    channel = null
  })

  return channel
}

export async function closeRabbitMQ(): Promise<void> {
  try {
    await channel?.close()
    await connection?.close()
  } catch {
    // ignora erros no fechamento
  } finally {
    channel = null
    connection = null
  }
}
