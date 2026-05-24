# Diagrama de Arquitetura — Sistema de Agendamento de Transporte

> Renderize este arquivo com a extensão **Mermaid Preview** no VSCode ou abra no GitHub.

```mermaid
graph TB
    subgraph Backend ["⚙️ Backend — Node.js + TypeScript"]
        subgraph Infrastructure ["Infrastructure Layer"]
            Controllers["Controllers\n(Express)"]
            PrismaRepos["Repositories\n(Prisma)"]
            Publisher["RabbitMQEventPublisher"]
        end
        subgraph Application ["Application Layer"]
            UseCases["Use Cases\nCreateRide | ListRides\nGetRide | UpdateStatus\nCreateUser | CreateDriver"]
            RepoInterfaces["Repository Interfaces\n(Ports)"]
            EventPublisher["EventPublisher\n(Interface / Port)"]
        end
        subgraph Domain ["Domain Layer"]
            Entities["Entities\nUser · Driver · Ride"]
            RideStatus["RideStatus\nPENDING · ACCEPTED\nIN_PROGRESS · COMPLETED\nCANCELLED"]
        end
    end

    subgraph MOM ["📨 Middleware Orientado a Mensagens"]
        RabbitMQ[["RabbitMQ\n(Docker)\nExchange: rides.events\ntopic"]]
        QueueDriver[["Queue\nnotifications.driver\nrouting: ride.created"]]
        QueuePassenger[["Queue\nnotifications.passenger\nrouting: ride.status_updated"]]
    end

    subgraph Worker ["🔄 Worker (processo separado)"]
        WorkerProc["worker.ts\n(npm run worker)"]
        HandlerDriver["notifyDriverHandler\n(stub → Sprint 4: FCM/WS)"]
        HandlerPassenger["notifyPassengerHandler\n(stub → Sprint 3: FCM/WS)"]
    end

    subgraph DB ["🗄️ Infraestrutura de Dados"]
        Postgres[("PostgreSQL\n(Docker)")]
    end

    Controllers --> UseCases
    UseCases --> RepoInterfaces
    RepoInterfaces -.->|"implementa"| PrismaRepos
    UseCases --> EventPublisher
    EventPublisher -.->|"implementa"| Publisher
    UseCases --> Entities
    Entities --> RideStatus
    PrismaRepos -- "Prisma ORM" --> Postgres

    Publisher -- "AMQP publish\n(assíncrono)" --> RabbitMQ
    RabbitMQ --> QueueDriver
    RabbitMQ --> QueuePassenger

    WorkerProc -- "consume + ack" --> QueueDriver
    WorkerProc -- "consume + ack" --> QueuePassenger
    QueueDriver --> HandlerDriver
    QueuePassenger --> HandlerPassenger

    style Backend fill:#f3f9f3,stroke:#4CAF50
    style Domain fill:#fff8e1,stroke:#FFC107
    style Application fill:#fce4ec,stroke:#E91E63
    style Infrastructure fill:#f3e5f5,stroke:#9C27B0
    style DB fill:#e8eaf6,stroke:#3F51B5
    style MOM fill:#fff3e0,stroke:#FF9800
    style Worker fill:#e0f2f1,stroke:#009688
```

## Descrição dos Componentes

| Componente | Tecnologia | Papel |
|---|---|---|
| Backend REST | Node.js + Express + TypeScript | Lógica de negócio, expõe API RESTful |
| ORM | Prisma | Acesso tipado ao banco de dados |
| Banco de Dados | PostgreSQL (Docker) | Persistência de dados |
| Message Broker | RabbitMQ 3.13 (Docker) | Exchange topic `rides.events`; garante entrega durável entre produtor e consumidor |
| Worker | Node.js (processo separado) | Consome filas `notifications.driver` e `notifications.passenger`; notifica apps móveis (stub em Sprint 2) |

## Fluxo de Eventos

```
POST /api/rides (HTTP síncrono)
  → CreateRideUseCase persiste no banco
  → publica "ride.created" em rides.events
  → retorna 201
         ↕ (assíncrono — sem REST entre backend e worker)
Worker consome notifications.driver
  → notifyDriverHandler loga notificação
  → ack

PATCH /api/rides/:id/status (HTTP síncrono)
  → UpdateRideStatusUseCase persiste no banco
  → publica "ride.status_updated" em rides.events
  → retorna 200
         ↕ (assíncrono)
Worker consome notifications.passenger
  → notifyPassengerHandler loga notificação
  → ack
```
