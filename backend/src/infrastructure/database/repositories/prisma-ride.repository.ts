import { CreateRideData, Ride, RideStatus } from '../../../domain/entities/ride.entity'
import { RideFilters, RideRepository } from '../../../application/repositories/ride.repository'
import prisma from '../prisma-client'

export class PrismaRideRepository implements RideRepository {
  async create(data: CreateRideData): Promise<Ride> {
    const ride = await prisma.ride.create({ data })
    return { ...ride, status: ride.status as RideStatus }
  }

  async findById(id: string): Promise<Ride | null> {
    const ride = await prisma.ride.findUnique({ where: { id } })
    if (!ride) return null
    return { ...ride, status: ride.status as RideStatus }
  }

  async findAll(filters?: RideFilters): Promise<Ride[]> {
    const rides = await prisma.ride.findMany({
      where: {
        ...(filters?.userId && { userId: filters.userId }),
        ...(filters?.driverId && { driverId: filters.driverId }),
        ...(filters?.status && { status: filters.status }),
      },
      orderBy: { createdAt: 'desc' },
    })
    return rides.map(r => ({ ...r, status: r.status as RideStatus }))
  }

  async updateStatus(id: string, status: RideStatus, driverId?: string): Promise<Ride> {
    const ride = await prisma.ride.update({
      where: { id },
      data: { status, ...(driverId ? { driverId } : {}) },
    })
    return { ...ride, status: ride.status as RideStatus }
  }
}
