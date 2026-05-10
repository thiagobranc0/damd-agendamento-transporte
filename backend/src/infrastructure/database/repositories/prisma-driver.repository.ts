import { CreateDriverData, Driver } from '../../../domain/entities/driver.entity'
import { DriverRepository } from '../../../application/repositories/driver.repository'
import prisma from '../prisma-client'

export class PrismaDriverRepository implements DriverRepository {
  async create(data: CreateDriverData): Promise<Driver> {
    return prisma.driver.create({ data })
  }

  async findById(id: string): Promise<Driver | null> {
    return prisma.driver.findUnique({ where: { id } })
  }

  async findAll(): Promise<Driver[]> {
    return prisma.driver.findMany({ orderBy: { createdAt: 'desc' } })
  }
}
