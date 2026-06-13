import { Router } from 'express'
import { listNotificationsController, markNotificationReadController } from '../controllers/notification.controller'

const router = Router()

router.get('/', listNotificationsController)
router.patch('/:id/read', markNotificationReadController)

export default router
