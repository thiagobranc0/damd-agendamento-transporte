import { CreateDriverNotificationData, DriverNotification } from '../../../domain/entities/driver-notification.entity'
import { DriverNotificationRepository } from '../../../application/repositories/driver-notification.repository'
import prisma from '../prisma-client'

export class PrismaDriverNotificationRepository implements DriverNotificationRepository {
  async create(data: CreateDriverNotificationData): Promise<DriverNotification> {
    return prisma.driverNotification.create({ data })
  }

  async findAll(onlyUnread?: boolean): Promise<DriverNotification[]> {
    return prisma.driverNotification.findMany({
      where: onlyUnread ? { read: false } : undefined,
      orderBy: { createdAt: 'desc' },
    })
  }

  async markAsRead(id: string): Promise<void> {
    await prisma.driverNotification.update({ where: { id }, data: { read: true } })
  }
}
