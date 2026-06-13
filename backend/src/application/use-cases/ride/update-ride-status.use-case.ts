import { Ride, RideStatus } from '../../../domain/entities/ride.entity'
import { RideRepository } from '../../repositories/ride.repository'
import { EventPublisher } from '../../events/event-publisher'
import { AppError } from '../../../shared/errors/app-error'

const VALID_TRANSITIONS: Record<RideStatus, RideStatus[]> = {
  [RideStatus.PENDING]: [RideStatus.ACCEPTED, RideStatus.CANCELLED],
  [RideStatus.ACCEPTED]: [RideStatus.IN_PROGRESS, RideStatus.CANCELLED],
  [RideStatus.IN_PROGRESS]: [RideStatus.COMPLETED, RideStatus.CANCELLED],
  [RideStatus.COMPLETED]: [],
  [RideStatus.CANCELLED]: [],
}

interface Input {
  id: string
  status: RideStatus
  driverId?: string
}

export class UpdateRideStatusUseCase {
  constructor(
    private readonly rideRepository: RideRepository,
    private readonly eventPublisher: EventPublisher
  ) {}

  async execute(input: Input): Promise<Ride> {
    const ride = await this.rideRepository.findById(input.id)
    if (!ride) throw new AppError('Ride not found', 404)

    const allowed = VALID_TRANSITIONS[ride.status]
    if (!allowed.includes(input.status)) {
      throw new AppError(
        `Cannot transition from ${ride.status} to ${input.status}`,
        400
      )
    }

    const previousStatus = ride.status
    const updated = await this.rideRepository.updateStatus(input.id, input.status, input.driverId)

    await this.eventPublisher.publish('ride.status_updated', {
      rideId: updated.id,
      userId: updated.userId,
      driverId: updated.driverId ?? null,
      previousStatus,
      newStatus: updated.status,
    })

    return updated
  }
}
