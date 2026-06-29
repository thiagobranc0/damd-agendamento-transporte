import { PrismaDriverNotificationRepository } from '../../database/repositories/prisma-driver-notification.repository'
import { CreateDriverNotificationUseCase } from '../../../application/use-cases/driver-notification/create-driver-notification.use-case'

interface RideCreatedData {
  rideId: string
  userId: string
  origin: string
  destination: string
  scheduledAt: string
}

interface RideCreatedEnvelope {
  event: string
  occurredAt: string
  data: RideCreatedData
}

const repo = new PrismaDriverNotificationRepository()
const createDriverNotification = new CreateDriverNotificationUseCase(repo)

export async function notifyDriverHandler(envelope: RideCreatedEnvelope): Promise<void> {
  const { data } = envelope
  const scheduledAt = new Date(data.scheduledAt).toLocaleString('pt-BR')

  console.log(
    `[notification:driver] Nova corrida disponível!` +
    ` | rideId=${data.rideId}` +
    ` | ${data.origin} → ${data.destination}` +
    ` | agendada para ${scheduledAt}`
  )

  await createDriverNotification.execute({
    rideId: data.rideId,
    title: 'Nova corrida disponível',
    message: `${data.origin} → ${data.destination} | agendada para ${scheduledAt}`,
  })
}
