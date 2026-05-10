export interface Driver {
  id: string
  name: string
  email: string
  phone: string
  vehicleModel: string
  licensePlate: string
  createdAt: Date
  updatedAt: Date
}

export interface CreateDriverData {
  name: string
  email: string
  phone: string
  vehicleModel: string
  licensePlate: string
}
