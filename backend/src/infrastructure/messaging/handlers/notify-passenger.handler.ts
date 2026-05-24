interface RideStatusUpdatedData {
  rideId: string
  userId: string
  driverId: string | null
  previousStatus: string
  newStatus: string
}

interface RideStatusUpdatedEnvelope {
  event: string
  occurredAt: string
  data: RideStatusUpdatedData
}

export function notifyPassengerHandler(envelope: RideStatusUpdatedEnvelope): void {
  const { data } = envelope

  console.log(
    `[notification:passenger] Status da corrida atualizado!` +
    ` | rideId=${data.rideId}` +
    ` | ${data.previousStatus} → ${data.newStatus}` +
    ` | driverId=${data.driverId ?? 'n/a'}`
  )
  // Sprint 3/4: substituir por gateway WebSocket/FCM para o app do passageiro
}
