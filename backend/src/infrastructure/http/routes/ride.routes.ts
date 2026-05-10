import { Router } from 'express'
import {
  createRideController,
  listRidesController,
  getRideController,
  updateRideStatusController,
} from '../controllers/ride.controller'

const router = Router()

router.post('/', createRideController)
router.get('/', listRidesController)
router.get('/:id', getRideController)
router.patch('/:id/status', updateRideStatusController)

export default router
