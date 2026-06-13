import { Request, Response, NextFunction } from 'express'
import { PrismaNotificationRepository } from '../../database/repositories/prisma-notification.repository'
import { ListNotificationsUseCase } from '../../../application/use-cases/notification/list-notifications.use-case'
import { MarkNotificationReadUseCase } from '../../../application/use-cases/notification/mark-notification-read.use-case'
import { AppError } from '../../../shared/errors/app-error'

const notificationRepository = new PrismaNotificationRepository()
const listNotifications = new ListNotificationsUseCase(notificationRepository)
const markNotificationRead = new MarkNotificationReadUseCase(notificationRepository)

export async function listNotificationsController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { userId, unread } = req.query
    if (!userId || typeof userId !== 'string') {
      throw new AppError('userId query param is required', 400)
    }
    const notifications = await listNotifications.execute({
      userId,
      onlyUnread: unread === 'true',
    })
    res.json(notifications)
  } catch (err) {
    next(err)
  }
}

export async function markNotificationReadController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    await markNotificationRead.execute(req.params.id)
    res.status(204).send()
  } catch (err) {
    next(err)
  }
}
