# Diagrama de Arquitetura — Sistema de Agendamento de Transporte

> Renderize este arquivo com a extensão **Mermaid Preview** no VSCode ou abra no GitHub.

## 1. Arquitetura Geral do Sistema (Sprints 1–3)

```mermaid
graph TB
    subgraph App ["📱 App do Passageiro — Flutter (Sprint 3)"]
        Presentation["presentation\n(telas + widgets)"]
        AppState["application\n(Riverpod controllers + poller)"]
        AppData["data\n(Dio + repositories impl)"]
        AppDomain["domain\n(entities + interfaces)"]
    end

    subgraph Backend ["⚙️ Backend — Node.js + TypeScript"]
        subgraph Infrastructure ["Infrastructure Layer"]
            Controllers["Controllers\n(Express)\nride · user · driver · notification"]
            PrismaRepos["Repositories\n(Prisma)\nride · user · driver · notification"]
            Publisher["RabbitMQEventPublisher"]
        end
        subgraph Application ["Application Layer"]
            UseCases["Use Cases\nCreateRide | ListRides | GetRide\nUpdateStatus | CreateUser | CreateDriver\nCreateNotification | ListNotifications\nMarkNotificationRead"]
            RepoInterfaces["Repository Interfaces\n(Ports)"]
            EventPublisher["EventPublisher\n(Interface / Port)"]
        end
        subgraph Domain ["Domain Layer"]
            Entities["Entities\nUser · Driver · Ride · Notification"]
            RideStatus["RideStatus\nPENDING · ACCEPTED\nIN_PROGRESS · COMPLETED\nCANCELLED"]
        end
    end

    subgraph MOM ["📨 Middleware Orientado a Mensagens"]
        RabbitMQ[["RabbitMQ (Docker)\nExchange: rides.events · topic"]]
        QueueDriver[["Queue\nnotifications.driver\nrouting: ride.created"]]
        QueuePassenger[["Queue\nnotifications.passenger\nrouting: ride.status_updated"]]
    end

    subgraph Consumers ["🔄 Consumidores (processos independentes)"]
        ConsumerDriver["consumer-driver.ts\n(npm run consumer:driver)\n→ notifyDriverHandler\n(PERSISTE em driver_notifications)"]
        ConsumerPassenger["consumer-passenger.ts\n(npm run consumer:passenger)\n→ notifyPassengerHandler\n(PERSISTE em notifications)"]
    end

    subgraph DB ["🗄️ Infraestrutura de Dados"]
        Postgres[("PostgreSQL (Docker)\nUser · Driver · Ride\nNotification · DriverNotification")]
    end

    Controllers --> UseCases
    UseCases --> RepoInterfaces
    RepoInterfaces -.->|"implementa"| PrismaRepos
    UseCases --> EventPublisher
    EventPublisher -.->|"implementa"| Publisher
    UseCases --> Entities
    Entities --> RideStatus
    PrismaRepos -- "Prisma ORM" --> Postgres

    Publisher -- "AMQP publish (assíncrono)" --> RabbitMQ
    RabbitMQ --> QueueDriver
    RabbitMQ --> QueuePassenger

    ConsumerDriver -- "consume + await + ack" --> QueueDriver
    ConsumerPassenger -- "consume + await + ack" --> QueuePassenger
    ConsumerDriver -- "INSERT driver_notification" --> Postgres
    ConsumerPassenger -- "INSERT notification" --> Postgres

    Presentation --> AppState
    AppState --> AppDomain
    AppData --> AppDomain
    AppData -- "HTTP REST\n(GET /rides, POST /rides,\nGET /notifications, ...)" --> Controllers
    AppState -. "polling 5s\nGET /notifications?unread=true" .-> Controllers

    style App fill:#e3f2fd,stroke:#2196F3
    style Backend fill:#f3f9f3,stroke:#4CAF50
    style Domain fill:#fff8e1,stroke:#FFC107
    style Application fill:#fce4ec,stroke:#E91E63
    style Infrastructure fill:#f3e5f5,stroke:#9C27B0
    style DB fill:#e8eaf6,stroke:#3F51B5
    style MOM fill:#fff3e0,stroke:#FF9800
    style Consumers fill:#e0f2f1,stroke:#009688
```

## 2. Camadas do App Flutter (Clean Architecture)

```mermaid
graph TD
    subgraph presentation["📱 presentation (UI)"]
        Screens["screens\nidentify · rides_list\ncreate_ride · ride_detail"]
        Widgets["widgets\nride_card · status_badge\nasync_value_view · notifications_sheet"]
        Router["app.dart\n(GoRouter)"]
    end

    subgraph application["⚙️ application (Estado — Riverpod)"]
        Session["session_controller\n(shared_preferences)"]
        RidesCtrl["rides_controller"]
        DetailCtrl["ride_detail_controller\n(polling status)"]
        Poller["notifications_poller\n(Timer 5s)"]
        Providers["providers.dart (DI)"]
    end

    subgraph data["🌐 data (HTTP)"]
        ApiClient["api_client (Dio)"]
        Dtos["dtos\nUserDto · RideDto · NotificationDto"]
        ReposImpl["repositories_impl"]
    end

    subgraph domain["🔷 domain (Puro — sem Flutter/Dio)"]
        DEntities["entities\nUser · Ride · RideStatus · AppNotification"]
        DInterfaces["repositories (interfaces)"]
    end

    presentation --> application
    application --> domain
    data --> domain
    ReposImpl -.->|"implementa"| DInterfaces
    ApiClient --> ReposImpl

    style presentation fill:#e3f2fd,stroke:#2196F3
    style application fill:#fce4ec,stroke:#E91E63
    style data fill:#f3e5f5,stroke:#9C27B0
    style domain fill:#fff8e1,stroke:#FFC107
```

**Regra de dependência:** `presentation → application → domain` e `data → domain`. O `domain` não importa nada externo — espelha a filosofia do backend.

## Descrição dos Componentes

| Componente | Tecnologia | Papel |
|---|---|---|
| App do passageiro | Flutter/Dart + Riverpod | Cliente humano: identifica-se, solicita corridas, acompanha status em tempo quase-real via polling |
| Backend REST | Node.js + Express + TypeScript | Lógica de negócio, expõe API RESTful, produtor de eventos |
| ORM | Prisma | Acesso tipado ao banco de dados |
| Banco de Dados | PostgreSQL (Docker) | Persistência: User, Driver, Ride, Notification, DriverNotification |
| Message Broker | RabbitMQ 3.13 (Docker) | Exchange topic `rides.events`; entrega durável produtor → consumidor |
| consumer-driver | Node.js (processo independente) | Consome `notifications.driver` (`ride.created`); **persiste** linha em `driver_notifications` para o app do motorista fazer polling |
| consumer-passenger | Node.js (processo independente) | Consome `notifications.passenger` (`ride.status_updated`); **persiste** linha em `notifications` para o app fazer polling |

## Fluxo de Eventos + Atualização Assíncrona do App

```
POST /api/rides (HTTP síncrono)
  → CreateRideUseCase persiste no banco
  → publica "ride.created" em rides.events → retorna 201
         ↕ (assíncrono — sem REST entre backend e consumidor)
consumer-driver consome notifications.driver
  → notifyDriverHandler PERSISTE linha em driver_notifications
  → await antes do ack (nack em falha de banco)
         ↕
App do motorista faz polling GET /driver/notifications?unread=true (~5s)
  → detecta demanda nova → rebusca lista de corridas PENDING sem ação manual

PATCH /api/rides/:id/status (HTTP síncrono, driverId opcional)
  → UpdateRideStatusUseCase persiste no banco
  → publica "ride.status_updated" em rides.events → retorna 200
         ↕ (assíncrono)
consumer-passenger consome notifications.passenger
  → notifyPassengerHandler PERSISTE linha em notifications
  → await antes do ack (nack em falha de banco)
         ↕
App do passageiro faz polling GET /notifications?userId=X&unread=true (~5s)
  → detecta notificação nova → atualiza badge + rebusca lista/detalhe
  → UI reflete novo status SEM ação manual do usuário
```
