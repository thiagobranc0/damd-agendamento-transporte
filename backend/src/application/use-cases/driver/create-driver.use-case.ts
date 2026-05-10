import { Driver } from '../../../domain/entities/driver.entity'
import { DriverRepository } from '../../repositories/driver.repository'

interface Input {
  name: string
  email: string
  phone: string
  vehicleModel: string
  licensePlate: string
}

export class CreateDriverUseCase {
  constructor(private readonly driverRepository: DriverRepository) {}

  async execute(input: Input): Promise<Driver> {
    return this.driverRepository.create(input)
  }
}
