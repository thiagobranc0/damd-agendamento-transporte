# Catálogo de Eventos — Sprint 2

Sistema: **Agendamento de Transporte**
MOM: **RabbitMQ 3.13** · Exchange: `rides.events` (type: `topic`, durable)

---

## Evento 1 — `ride.created`

| Atributo | Valor |
|---|---|
| **Nome** | `ride.created` |
| **Exchange** | `rides.events` |
| **Routing key** | `ride.created` |
| **Fila consumidora** | `notifications.driver` |
| **Produtor** | `CreateRideUseCase` (camada Application) |
| **Consumidor** | `worker.ts` → `notifyDriverHandler` |
| **Trigger** | `POST /api/rides` com sucesso — após persistência no banco |
| **Finalidade** | Notificar motoristas disponíveis de nova corrida criada |

### Payload

```json
{
  "event": "ride.created",
  "occurredAt": "2026-05-20T18:30:00.000Z",
  "data": {
    "rideId": "3f2e1d0c-...",
    "userId": "a1b2c3d4-...",
    "origin": "Rua das Flores, 100 — BH",
    "destination": "Aeroporto Confins — MG",
    "scheduledAt": "2026-05-21T06:00:00.000Z"
  }
}
```

### Comportamento do consumidor (Sprint 2)

Log estruturado simulando notificação ao motorista:
```
[notification:driver] Nova corrida disponível! | rideId=3f2e... | Rua das Flores → Aeroporto Confins | agendada para 21/05/2026, 06:00:00
```

> **Ponto de extensão Sprint 4:** substituir o log por push FCM ou mensagem WebSocket para o app do motorista.

---

## Evento 2 — `ride.status_updated`

| Atributo | Valor |
|---|---|
| **Nome** | `ride.status_updated` |
| **Exchange** | `rides.events` |
| **Routing key** | `ride.status_updated` |
| **Fila consumidora** | `notifications.passenger` |
| **Produtor** | `UpdateRideStatusUseCase` (camada Application) |
| **Consumidor** | `worker.ts` → `notifyPassengerHandler` |
| **Trigger** | `PATCH /api/rides/:id/status` com sucesso — após persistência no banco |
| **Finalidade** | Notificar o passageiro de que o status da sua corrida foi alterado |

### Payload

```json
{
  "event": "ride.status_updated",
  "occurredAt": "2026-05-20T18:45:00.000Z",
  "data": {
    "rideId": "3f2e1d0c-...",
    "userId": "a1b2c3d4-...",
    "driverId": "d9e8f7a6-...",
    "previousStatus": "PENDING",
    "newStatus": "ACCEPTED"
  }
}
```

### Comportamento do consumidor (Sprint 2)

```
[notification:passenger] Status da corrida atualizado! | rideId=3f2e... | PENDING → ACCEPTED | driverId=d9e8...
```

> **Ponto de extensão Sprint 3:** substituir o log por polling assíncrono ou WebSocket para o app do passageiro.

---

## Topologia RabbitMQ

```
Exchange: rides.events (topic, durable)
│
├── ride.created      ──→ Queue: notifications.driver    (durable, prefetch: 1, ack manual)
└── ride.status_updated ─→ Queue: notifications.passenger (durable, prefetch: 1, ack manual)
```

A declaração da exchange e das filas é **idempotente** — tanto o publisher quanto o worker executam `assertExchange` / `assertQueue` ao iniciar, garantindo que a topologia existe independentemente da ordem de inicialização dos processos.
