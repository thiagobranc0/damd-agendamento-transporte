import { Router } from 'express'
import {
  listDriverNotificationsController,
  markDriverNotificationReadController,
} from '../controllers/driver-notification.controller'

const router = Router()

router.get('/', listDriverNotificationsController)
router.patch('/:id/read', markDriverNotificationReadController)

export default router
