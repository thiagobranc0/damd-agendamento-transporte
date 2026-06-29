import { Request, Response, NextFunction } from 'express'
import { PrismaDriverNotificationRepository } from '../../database/repositories/prisma-driver-notification.repository'
import { ListDriverNotificationsUseCase } from '../../../application/use-cases/driver-notification/list-driver-notifications.use-case'
import { MarkDriverNotificationReadUseCase } from '../../../application/use-cases/driver-notification/mark-driver-notification-read.use-case'

const repo = new PrismaDriverNotificationRepository()
const listDriverNotifications = new ListDriverNotificationsUseCase(repo)
const markDriverNotificationRead = new MarkDriverNotificationReadUseCase(repo)

export async function listDriverNotificationsController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const onlyUnread = req.query.unread === 'true'
    const notifications = await listDriverNotifications.execute({ onlyUnread })
    res.json(notifications)
  } catch (err) {
    next(err)
  }
}

export async function markDriverNotificationReadController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    await markDriverNotificationRead.execute(req.params.id)
    res.status(204).send()
  } catch (err) {
    next(err)
  }
}
