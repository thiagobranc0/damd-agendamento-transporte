import { Notification, CreateNotificationData } from '../../../domain/entities/notification.entity'
import { NotificationRepository } from '../../repositories/notification.repository'

export class CreateNotificationUseCase {
  constructor(private readonly notificationRepository: NotificationRepository) {}

  async execute(data: CreateNotificationData): Promise<Notification> {
    return this.notificationRepository.create(data)
  }
}
