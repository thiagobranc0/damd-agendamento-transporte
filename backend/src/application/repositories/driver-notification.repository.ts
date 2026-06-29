import { CreateDriverNotificationData, DriverNotification } from '../../domain/entities/driver-notification.entity'

export interface DriverNotificationRepository {
  create(data: CreateDriverNotificationData): Promise<DriverNotification>
  findAll(onlyUnread?: boolean): Promise<DriverNotification[]>
  markAsRead(id: string): Promise<void>
}
