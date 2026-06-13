import { Notification } from '../../../domain/entities/notification.entity'
import { NotificationRepository } from '../../repositories/notification.repository'

interface Input {
  userId: string
  onlyUnread?: boolean
}

export class ListNotificationsUseCase {
  constructor(private readonly notificationRepository: NotificationRepository) {}

  async execute({ userId, onlyUnread }: Input): Promise<Notification[]> {
    return this.notificationRepository.findByUser(userId, onlyUnread)
  }
}
