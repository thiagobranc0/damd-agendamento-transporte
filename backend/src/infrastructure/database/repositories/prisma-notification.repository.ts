import { CreateNotificationData, Notification } from '../../../domain/entities/notification.entity'
import { NotificationRepository } from '../../../application/repositories/notification.repository'
import prisma from '../prisma-client'

export class PrismaNotificationRepository implements NotificationRepository {
  async create(data: CreateNotificationData): Promise<Notification> {
    return prisma.notification.create({ data })
  }

  async findByUser(userId: string, onlyUnread?: boolean): Promise<Notification[]> {
    return prisma.notification.findMany({
      where: {
        userId,
        ...(onlyUnread ? { read: false } : {}),
      },
      orderBy: { createdAt: 'desc' },
    })
  }

  async markAsRead(id: string): Promise<void> {
    await prisma.notification.update({ where: { id }, data: { read: true } })
  }
}
