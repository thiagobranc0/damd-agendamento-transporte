import { CreateNotificationData, Notification } from '../../domain/entities/notification.entity'

export interface NotificationRepository {
  create(data: CreateNotificationData): Promise<Notification>
  findByUser(userId: string, onlyUnread?: boolean): Promise<Notification[]>
  markAsRead(id: string): Promise<void>
}
