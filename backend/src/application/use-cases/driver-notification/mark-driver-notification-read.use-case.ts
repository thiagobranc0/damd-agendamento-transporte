import { DriverNotificationRepository } from '../../repositories/driver-notification.repository'

export class MarkDriverNotificationReadUseCase {
  constructor(private readonly repo: DriverNotificationRepository) {}

  async execute(id: string): Promise<void> {
    return this.repo.markAsRead(id)
  }
}
