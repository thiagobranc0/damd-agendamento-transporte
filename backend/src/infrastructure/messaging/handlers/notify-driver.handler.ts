interface RideCreatedData {
  rideId: string
  userId: string
  origin: string
  destination: string
  scheduledAt: string
}

interface RideCreatedEnvelope {
  event: string
  occurredAt: string
  data: RideCreatedData
}

export function notifyDriverHandler(envelope: RideCreatedEnvelope): void {
  const { data } = envelope
  const scheduledAt = new Date(data.scheduledAt).toLocaleString('pt-BR')

  console.log(
    `[notification:driver] Nova corrida disponível!` +
    ` | rideId=${data.rideId}` +
    ` | ${data.origin} → ${data.destination}` +
    ` | agendada para ${scheduledAt}`
  )
  // Sprint 3/4: substituir por gateway WebSocket/FCM para os apps dos motoristas
}
