# Arquitetura Final — Fluxo Ponta-a-Ponta (Sprint 4)

> Diagrama e2e com os dois apps Flutter, backend e MOM.

## Diagrama de Componentes

```mermaid
graph TD
    subgraph "App Passageiro (mobile/)"
        PA[Identificação\nPOST /users]
        PB[Nova Corrida\nPOST /rides]
        PC[Minhas Corridas\nGET /rides?userId=X]
        PD[Detalhe da Corrida\nGET /rides/:id]
        PE[NotificationsPoller\nGET /notifications?userId=X\nunread=true — 5s]
    end

    subgraph "App Motorista (mobile-driver/)"
        DA[Identificação\nPOST /drivers]
        DB[Corridas Disponíveis\nGET /rides?status=PENDING]
        DC[Detalhe / Aceitar\nPATCH /rides/:id/status]
        DD[Em Andamento\nGET /rides?driverId=X]
        DE[DemandPoller\nGET /driver/notifications?unread=true\n— 5s]
    end

    subgraph "Backend REST (Node.js/Express)"
        API[API REST\nport 3000]
        DB_PG[(PostgreSQL 16\nport 5433)]
        API -- Prisma ORM --> DB_PG
    end

    subgraph "MOM (RabbitMQ)"
        EX[Exchange: rides.events\ntype topic]
        QD[Fila: notifications.driver\nrouting: ride.created]
        QP[Fila: notifications.passenger\nrouting: ride.status_updated]
    end

    subgraph "Consumers (Node.js)"
        CD[consumer:driver\nnotify-driver.handler\nPERSISTE DriverNotification]
        CP[consumer:passenger\nnotify-passenger.handler\nPERSISTE Notification]
    end

    PB -- POST /rides --> API
    API -- ride.created --> EX
    EX --> QD --> CD
    CD -- INSERT --> DB_PG

    PC -- GET /rides --> API
    PD -- GET /rides/:id --> API
    PE -- GET /notifications --> API
    PE -. "nova notif → refresh" .-> PD

    DB -- GET /rides?status=PENDING --> API
    DE -- GET /driver/notifications --> API
    DE -. "nova demanda → refresh" .-> DB

    DC -- PATCH status ACCEPTED + driverId --> API
    API -- ride.status_updated --> EX
    EX --> QP --> CP
    CP -- INSERT --> DB_PG

    DD -- PATCH status IN_PROGRESS/COMPLETED --> API
    API -- ride.status_updated --> EX
```

## Fluxo e2e (narrativa)

```
1. Passageiro cria corrida
   POST /rides → backend persiste (PENDING) → publica ride.created no Exchange

2. consumer:driver consome ride.created
   → persiste DriverNotification (broadcast, sem driverId)

3. App do motorista (DemandPoller, 5s) detecta notificação nova
   → refresh automático da lista de corridas disponíveis
   → motorista vê a corrida SEM refresh manual  ← assincronicidade via MOM

4. Motorista abre o detalhe → Aceitar
   PATCH /rides/:id/status { status: "ACCEPTED", driverId }
   → backend persiste (ACCEPTED, driverId gravado) → publica ride.status_updated

5. consumer:passenger consome ride.status_updated
   → persiste Notification para o passageiro

6. App do passageiro (NotificationsPoller, 5s) detecta notificação nova
   → tela de detalhe muda para ACEITA SEM refresh manual  ← ponta-a-ponta completo

7. Motorista → Iniciar (IN_PROGRESS) → mesmo fluxo (passos 4–6)
8. Motorista → Concluir (COMPLETED) → mesmo fluxo (passos 4–6)
```

## Diagrama de Camadas (Clean Architecture — os dois apps)

```mermaid
graph LR
    subgraph "mobile/ e mobile-driver/"
        P[presentation\nscreens · widgets] --> A[application\nRiverpod notifiers\nproviders · poller]
        A --> D[domain\nentities · repository interfaces\nsem Flutter, sem Dio]
        DATA[data\nDio · DTOs\nrepositories_impl] --> D
        P --> DATA
    end

    subgraph "backend/"
        CTRL[infrastructure/http\ncontrollers · routes] --> UC[application/use-cases]
        CONS[infrastructure/messaging\nhandlers · consumer-runner] --> UC
        UC --> DOM[domain/entities\nports: repositories · EventPublisher]
        REPO[infrastructure/database\nPrisma repositories] --> DOM
        PUB[infrastructure/messaging\nRabbitMQEventPublisher] --> DOM
    end
```

## Tabela de Eventos (catálogo completo)

| Evento | Routing Key | Exchange | Produtor | Fila | Consumidor | Efeito |
|---|---|---|---|---|---|---|
| `ride.created` | `ride.created` | `rides.events` | `CreateRideUseCase` | `notifications.driver` | `consumer:driver` | Persiste `DriverNotification` (broadcast) |
| `ride.status_updated` | `ride.status_updated` | `rides.events` | `UpdateRideStatusUseCase` | `notifications.passenger` | `consumer:passenger` | Persiste `Notification` para o passageiro |
