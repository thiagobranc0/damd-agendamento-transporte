import { Ride, RideStatus } from '../../../domain/entities/ride.entity'
import { RideRepository } from '../../repositories/ride.repository'

interface Input {
  userId?: string
  status?: RideStatus
}

export class ListRidesUseCase {
  constructor(private readonly rideRepository: RideRepository) {}

  async execute(filters?: Input): Promise<Ride[]> {
    return this.rideRepository.findAll(filters)
  }
}
