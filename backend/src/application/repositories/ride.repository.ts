import { CreateRideData, Ride, RideStatus } from '../../domain/entities/ride.entity'

export interface RideFilters {
  userId?: string
  status?: RideStatus
}

export interface RideRepository {
  create(data: CreateRideData): Promise<Ride>
  findById(id: string): Promise<Ride | null>
  findAll(filters?: RideFilters): Promise<Ride[]>
  updateStatus(id: string, status: RideStatus, driverId?: string): Promise<Ride>
}
