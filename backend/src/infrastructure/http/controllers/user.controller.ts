import { Request, Response, NextFunction } from 'express'
import { CreateUserUseCase } from '../../../application/use-cases/user/create-user.use-case'
import { PrismaUserRepository } from '../../database/repositories/prisma-user.repository'

const userRepository = new PrismaUserRepository()
const createUser = new CreateUserUseCase(userRepository)

export async function createUserController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const user = await createUser.execute(req.body)
    res.status(201).json(user)
  } catch (err) {
    next(err)
  }
}
