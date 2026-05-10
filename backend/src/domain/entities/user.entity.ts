export interface User {
  id: string
  name: string
  email: string
  phone: string
  createdAt: Date
  updatedAt: Date
}

export interface CreateUserData {
  name: string
  email: string
  phone: string
}
