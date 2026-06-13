import { PrismaNotificationRepository } from '../../database/repositories/prisma-notification.repository'
import { CreateNotificationUseCase } from '../../../application/use-cases/notification/create-notification.use-case'

interface RideStatusUpdatedData {
  rideId: string
  userId: string
  driverId: string | null
  previousStatus: string
  newStatus: string
}

interface RideStatusUpdatedEnvelope {
  event: string
  occurredAt: string
  data: RideStatusUpdatedData
}

const notificationRepository = new PrismaNotificationRepository()
const createNotification = new CreateNotificationUseCase(notificationRepository)

export async function notifyPassengerHandler(envelope: RideStatusUpdatedEnvelope): Promise<void> {
  const { data } = envelope

  const driverInfo = data.driverId ? ` | motorista=${data.driverId}` : ''
  console.log(
    `[notification:passenger] Status da corrida atualizado!` +
    ` | rideId=${data.rideId}` +
    ` | ${data.previousStatus} → ${data.newStatus}` +
    driverInfo
  )

  await createNotification.execute({
    userId: data.userId,
    rideId: data.rideId,
    type: 'ride.status_updated',
    title: 'Status da corrida atualizado',
    message: `Sua corrida mudou de ${data.previousStatus} para ${data.newStatus}`,
  })
}
