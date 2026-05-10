import { CreateUserData, User } from '../../domain/entities/user.entity'

export interface UserRepository {
  create(data: CreateUserData): Promise<User>
  findById(id: string): Promise<User | null>
}
