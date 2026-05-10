import { User } from '../../../domain/entities/user.entity'
import { UserRepository } from '../../repositories/user.repository'

interface Input {
  name: string
  email: string
  phone: string
}

export class CreateUserUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  async execute(input: Input): Promise<User> {
    return this.userRepository.create(input)
  }
}
