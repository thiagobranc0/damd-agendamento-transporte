import { Request, Response, NextFunction } from 'express'
import { CreateDriverUseCase } from '../../../application/use-cases/driver/create-driver.use-case'
import { PrismaDriverRepository } from '../../database/repositories/prisma-driver.repository'

const driverRepository = new PrismaDriverRepository()
const createDriver = new CreateDriverUseCase(driverRepository)

export async function createDriverController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const driver = await createDriver.execute(req.body)
    res.status(201).json(driver)
  } catch (err) {
    next(err)
  }
}

export async function listDriversController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const drivers = await driverRepository.findAll()
    res.json(drivers)
  } catch (err) {
    next(err)
  }
}
