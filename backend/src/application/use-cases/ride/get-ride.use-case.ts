import { Ride } from '../../../domain/entities/ride.entity'
import { RideRepository } from '../../repositories/ride.repository'
import { AppError } from '../../../shared/errors/app-error'

export class GetRideUseCase {
  constructor(private readonly rideRepository: RideRepository) {}

  async execute(id: string): Promise<Ride> {
    const ride = await this.rideRepository.findById(id)
    if (!ride) throw new AppError('Ride not found', 404)
    return ride
  }
}
