import { DriverNotification, CreateDriverNotificationData } from '../../../domain/entities/driver-notification.entity'
import { DriverNotificationRepository } from '../../repositories/driver-notification.repository'

export class CreateDriverNotificationUseCase {
  constructor(private readonly repo: DriverNotificationRepository) {}

  async execute(data: CreateDriverNotificationData): Promise<DriverNotification> {
    return this.repo.create(data)
  }
}
