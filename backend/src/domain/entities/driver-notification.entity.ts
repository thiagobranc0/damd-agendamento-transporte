export interface DriverNotification {
  id: string
  rideId: string
  title: string
  message: string
  read: boolean
  createdAt: Date
}

export interface CreateDriverNotificationData {
  rideId: string
  title: string
  message: string
}
