import { Router } from 'express'
import { createDriverController, listDriversController } from '../controllers/driver.controller'

const router = Router()

router.post('/', createDriverController)
router.get('/', listDriversController)

export default router
