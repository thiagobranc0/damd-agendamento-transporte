import 'dotenv/config'
import { startConsumer } from './infrastructure/messaging/consumer-runner'
import { notifyDriverHandler } from './infrastructure/messaging/handlers/notify-driver.handler'

// Consumidor independente (papel único): notifica motoristas de novas corridas.
// Escuta apenas a fila notifications.driver, vinculada ao evento ride.created.
startConsumer({
  label: 'consumer:driver',
  queue: 'notifications.driver',
  routingKey: 'ride.created',
  handler: notifyDriverHandler,
}).catch((err) => {
  console.error('[consumer:driver] Falha ao iniciar:', err.message)
  process.exit(1)
})
