import { Router } from 'express'
import userRoutes from './user.routes'
import driverRoutes from './driver.routes'
import rideRoutes from './ride.routes'
import notificationRoutes from './notification.routes'
import driverNotificationRoutes from './driver-notification.routes'

const router = Router()

router.use('/users', userRoutes)
router.use('/drivers', driverRoutes)
router.use('/rides', rideRoutes)
router.use('/notifications', notificationRoutes)
router.use('/driver/notifications', driverNotificationRoutes)

export default router
