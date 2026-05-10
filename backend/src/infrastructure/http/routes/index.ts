import { Router } from 'express'
import userRoutes from './user.routes'
import driverRoutes from './driver.routes'
import rideRoutes from './ride.routes'

const router = Router()

router.use('/users', userRoutes)
router.use('/drivers', driverRoutes)
router.use('/rides', rideRoutes)

export default router
