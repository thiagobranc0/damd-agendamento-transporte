import { Ride } from '../../../domain/entities/ride.entity'
import { RideRepository } from '../../repositories/ride.repository'
import { UserRepository } from '../../repositories/user.repository'
import { EventPublisher } from '../../events/event-publisher'
import { AppError } from '../../../shared/errors/app-error'

interface Input {
  userId: string
  origin: string
  destination: string
  scheduledAt: string | Date
}

export class CreateRideUseCase {
  constructor(
    private readonly rideRepository: RideRepository,
    private readonly userRepository: UserRepository,
    private readonly eventPublisher: EventPublisher
  ) {}

  async execute(input: Input): Promise<Ride> {
    const user = await this.userRepository.findById(input.userId)
    if (!user) throw new AppError('User not found', 404)

    const ride = await this.rideRepository.create({
      userId: input.userId,
      origin: input.origin,
      destination: input.destination,
      scheduledAt: new Date(input.scheduledAt),
    })

    await this.eventPublisher.publish('ride.created', {
      rideId: ride.id,
      userId: ride.userId,
      origin: ride.origin,
      destination: ride.destination,
      scheduledAt: ride.scheduledAt,
    })

    return ride
  }
}
