import express from 'express'
import cors from 'cors'
import 'dotenv/config'
import routes from './routes'
import { errorMiddleware } from './middlewares/error.middleware'

const app = express()

app.use(cors())
app.use(express.json())

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' })
})

app.use('/api', routes)

app.use(errorMiddleware)

export default app
