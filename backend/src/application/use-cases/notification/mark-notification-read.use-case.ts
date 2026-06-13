import { NotificationRepository } from '../../repositories/notification.repository'
import { AppError } from '../../../shared/errors/app-error'

export class MarkNotificationReadUseCase {
  constructor(private readonly notificationRepository: NotificationRepository) {}

  async execute(id: string): Promise<void> {
    if (!id) throw new AppError('Notification id is required', 400)
    await this.notificationRepository.markAsRead(id)
  }
}
