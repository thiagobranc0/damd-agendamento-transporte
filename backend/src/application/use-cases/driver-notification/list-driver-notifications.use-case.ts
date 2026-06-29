import { DriverNotification } from '../../../domain/entities/driver-notification.entity'
import { DriverNotificationRepository } from '../../repositories/driver-notification.repository'

interface Input {
  onlyUnread?: boolean
}

export class ListDriverNotificationsUseCase {
  constructor(private readonly repo: DriverNotificationRepository) {}

  async execute(input?: Input): Promise<DriverNotification[]> {
    return this.repo.findAll(input?.onlyUnread)
  }
}
