export enum RideStatus {
  PENDING = 'PENDING',
  ACCEPTED = 'ACCEPTED',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
}

export interface Ride {
  id: string
  userId: string
  driverId: string | null
  origin: string
  destination: string
  status: RideStatus
  scheduledAt: Date
  createdAt: Date
  updatedAt: Date
}

export interface CreateRideData {
  userId: string
  origin: string
  destination: string
  scheduledAt: Date
}
