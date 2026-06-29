import { Request, Response, NextFunction } from 'express'
import { CreateRideUseCase } from '../../../application/use-cases/ride/create-ride.use-case'
import { ListRidesUseCase } from '../../../application/use-cases/ride/list-rides.use-case'
import { GetRideUseCase } from '../../../application/use-cases/ride/get-ride.use-case'
import { UpdateRideStatusUseCase } from '../../../application/use-cases/ride/update-ride-status.use-case'
import { PrismaRideRepository } from '../../database/repositories/prisma-ride.repository'
import { PrismaUserRepository } from '../../database/repositories/prisma-user.repository'
import { RabbitMQEventPublisher } from '../../messaging/rabbitmq-event-publisher'
import { RideStatus } from '../../../domain/entities/ride.entity'
import { AppError } from '../../../shared/errors/app-error'

const rideRepository = new PrismaRideRepository()
const userRepository = new PrismaUserRepository()
const eventPublisher = new RabbitMQEventPublisher()

const createRide = new CreateRideUseCase(rideRepository, userRepository, eventPublisher)
const listRides = new ListRidesUseCase(rideRepository)
const getRide = new GetRideUseCase(rideRepository)
const updateRideStatus = new UpdateRideStatusUseCase(rideRepository, eventPublisher)

export async function createRideController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const ride = await createRide.execute(req.body)
    res.status(201).json(ride)
  } catch (err) {
    next(err)
  }
}

export async function listRidesController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { userId, driverId, status } = req.query
    const rides = await listRides.execute({
      userId: userId as string | undefined,
      driverId: driverId as string | undefined,
      status: status as RideStatus | undefined,
    })
    res.json(rides)
  } catch (err) {
    next(err)
  }
}

export async function getRideController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const ride = await getRide.execute(req.params.id)
    res.json(ride)
  } catch (err) {
    next(err)
  }
}

export async function updateRideStatusController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { status, driverId } = req.body
    if (!Object.values(RideStatus).includes(status)) {
      throw new AppError(`Invalid status. Valid values: ${Object.values(RideStatus).join(', ')}`)
    }
    const ride = await updateRideStatus.execute({ id: req.params.id, status, driverId })
    res.json(ride)
  } catch (err) {
    next(err)
  }
}
