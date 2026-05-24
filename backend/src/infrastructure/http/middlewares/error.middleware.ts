import { Request, Response, NextFunction } from 'express'
import { Prisma } from '@prisma/client'
import { AppError } from '../../../shared/errors/app-error'

export function errorMiddleware(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({ error: err.message })
    return
  }

  if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
    const fields = (err.meta?.target as string[])?.join(', ') ?? 'field'
    res.status(409).json({ error: `A record with this ${fields} already exists` })
    return
  }

  console.error(err)
  res.status(500).json({ error: 'Internal server error' })
}
