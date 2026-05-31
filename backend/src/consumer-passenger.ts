import 'dotenv/config'
import { startConsumer } from './infrastructure/messaging/consumer-runner'
import { notifyPassengerHandler } from './infrastructure/messaging/handlers/notify-passenger.handler'

// Consumidor independente (papel único): notifica passageiros de mudança de status.
// Escuta apenas a fila notifications.passenger, vinculada ao evento ride.status_updated.
startConsumer({
  label: 'consumer:passenger',
  queue: 'notifications.passenger',
  routingKey: 'ride.status_updated',
  handler: notifyPassengerHandler,
}).catch((err) => {
  console.error('[consumer:passenger] Falha ao iniciar:', err.message)
  process.exit(1)
})
