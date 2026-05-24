import { EventPublisher } from '../../application/events/event-publisher'
import { getRabbitMQChannel } from './rabbitmq-connection'

const EXCHANGE = process.env.RIDES_EXCHANGE ?? 'rides.events'

export class RabbitMQEventPublisher implements EventPublisher {
  async publish(routingKey: string, payload: unknown): Promise<void> {
    try {
      const channel = await getRabbitMQChannel()

      await channel.assertExchange(EXCHANGE, 'topic', { durable: true })

      const envelope = {
        event: routingKey,
        occurredAt: new Date().toISOString(),
        data: payload,
      }

      const content = Buffer.from(JSON.stringify(envelope))
      channel.publish(EXCHANGE, routingKey, content, {
        persistent: true,
        contentType: 'application/json',
      })
    } catch (err) {
      console.error(`[RabbitMQ] Failed to publish event "${routingKey}":`, (err as Error).message)
    }
  }
}
