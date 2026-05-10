import { CreateDriverData, Driver } from '../../domain/entities/driver.entity'

export interface DriverRepository {
  create(data: CreateDriverData): Promise<Driver>
  findById(id: string): Promise<Driver | null>
  findAll(): Promise<Driver[]>
}
