export interface Notification {
  id: string
  userId: string
  rideId: string
  type: string
  title: string
  message: string
  read: boolean
  createdAt: Date
}

export interface CreateNotificationData {
  userId: string
  rideId: string
  type: string
  title: string
  message: string
}
