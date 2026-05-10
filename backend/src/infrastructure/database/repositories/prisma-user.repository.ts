import { CreateUserData, User } from '../../../domain/entities/user.entity'
import { UserRepository } from '../../../application/repositories/user.repository'
import prisma from '../prisma-client'

export class PrismaUserRepository implements UserRepository {
  async create(data: CreateUserData): Promise<User> {
    return prisma.user.create({ data })
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } })
  }
}
