# Arquitetura do App do Passageiro — Sprint 3

## Visão Geral

O app segue **Clean Architecture** com quatro camadas concêntricas. A regra de dependência é unidirecional: camadas externas dependem de camadas internas; `domain` não importa nada externo (nem Flutter, nem Dio).

```
presentation → application → domain
data                       → domain
```

---

## Diagrama de Camadas

```mermaid
graph TD
    subgraph presentation["📱 presentation (UI)"]
        SC[identify_screen]
        SL[rides_list_screen]
        SD[ride_detail_screen]
        SN[create_ride_screen]
        WC[ride_card]
        WB[status_badge]
        WN[notifications_bottom_sheet]
        WA[async_value_view]
        AP[app.dart · GoRouter]
    end

    subgraph application["⚙️ application (Estado)"]
        SE[session_controller\nshared_preferences]
        RC[rides_controller\nAsyncNotifier]
        RD[ride_detail_controller\nAutoDisposeFamily]
        NP[notifications_poller\nTimer 5s]
        PR[providers.dart\nDI wiring]
    end

    subgraph data["🌐 data (HTTP)"]
        AC[api_client\nDio · baseUrl]
        UR[user_repository_impl]
        RR[ride_repository_impl]
        NR[notification_repository_impl]
        DU[UserDto]
        DR[RideDto]
        DN[NotificationDto]
    end

    subgraph domain["🔷 domain (Puro)"]
        EU[User]
        ER[Ride · RideStatus]
        EN[AppNotification]
        IU[UserRepository]
        IR[RideRepository]
        IN[NotificationRepository]
    end

    presentation --> application
    application --> domain
    data --> domain
    presentation -.->|lê AsyncValue| application

    UR --> IU
    RR --> IR
    NR --> IN
    AC --> UR & RR & NR
```

---

## Fluxo de Atualização Assíncrona

```mermaid
sequenceDiagram
    actor Motorista
    participant API as Backend REST
    participant MQ as RabbitMQ
    participant CP as consumer:passenger
    participant DB as PostgreSQL
    participant APP as App Flutter

    Motorista->>API: PATCH /rides/:id/status {ACCEPTED}
    API->>MQ: publica ride.status_updated
    MQ->>CP: entrega mensagem
    CP->>DB: INSERT notifications (userId, rideId, message)
    CP->>MQ: ack

    loop A cada 5 segundos
        APP->>API: GET /notifications?userId=X&unread=true
        API->>DB: SELECT WHERE userId=X AND read=false
        DB-->>API: [{ id, rideId, message }]
        API-->>APP: lista de notificações
        APP->>APP: atualiza badge + rebusca lista de corridas
    end
```

---

## Descrição das Camadas

### `domain/`
Entidades e contratos puros — sem dependência de Flutter, Dio ou qualquer framework.

| Arquivo | Conteúdo |
|---|---|
| `entities/user.dart` | `User` (id, name, email, phone) |
| `entities/ride.dart` | `Ride` + `enum RideStatus` com `fromString` e `isTerminal` |
| `entities/notification.dart` | `AppNotification` |
| `repositories/user_repository.dart` | Interface `UserRepository` |
| `repositories/ride_repository.dart` | Interface `RideRepository` |
| `repositories/notification_repository.dart` | Interface `NotificationRepository` |

### `data/`
Implementações concretas: serialização JSON ↔ entidade e chamadas HTTP via Dio.

| Arquivo | Responsabilidade |
|---|---|
| `datasources/api_client.dart` | Cria instância `Dio` com `baseUrl` configurável via `--dart-define` |
| `dtos/` | `UserDto`, `RideDto`, `NotificationDto` — `fromJson` + `toDomain()` |
| `repositories_impl/` | Implementações das interfaces do `domain` |

`baseUrl` padrão: `http://10.0.2.2:3000/api` (emulador Android → localhost do host).
Configurável via: `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000/api`.

### `application/`
Estado gerenciado com **Riverpod 2.x**. Cada controller tem responsabilidade única.

| Provider | Tipo | Responsabilidade |
|---|---|---|
| `sessionControllerProvider` | `AsyncNotifier<String?>` | `userId` persistido via `shared_preferences` |
| `ridesControllerProvider` | `AsyncNotifier<List<Ride>>` | Lista de corridas do usuário logado |
| `rideDetailControllerProvider` | `AutoDisposeFamilyAsyncNotifier` | Corrida individual; polling de status |
| `notificationsPollerProvider` | `AsyncNotifier<List<AppNotification>>` | Polling a cada 5s, apenas não lidas |
| `allNotificationsProvider` | `FutureProvider.autoDispose` | Todas as notificações para exibição no painel |
| `unreadCountProvider` | `Provider<int>` | Contador derivado do poller |

### `presentation/`
Telas e widgets stateless/stateful. Dependem apenas de `application` via `ref.watch`.

| Tela | Função na rubrica |
|---|---|
| `identify_screen` | Cadastro leve (nome + email + telefone → `POST /users`) |
| `rides_list_screen` | **Tela de listagem** — `GET /rides?userId=X` + badge de notificações |
| `create_ride_screen` | **Tela de ação principal** — `POST /rides` |
| `ride_detail_screen` | **Tela de detalhes** — polling 5s, timeline de status, atualização automática |

---

## Regra de Dependência (resumo visual)

```
domain          ← nenhuma dependência externa
  ↑
data            ← depende de domain + Dio
  ↑
application     ← depende de domain + Riverpod
  ↑
presentation    ← depende de application + Flutter widgets
```
