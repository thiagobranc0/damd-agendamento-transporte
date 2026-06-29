# DAMD — Sistema de Agendamento de Transporte

Projeto Integrador — LDAMD | PUC Minas | 2026/1

Sistema distribuído de agendamento de transporte com arquitetura orientada a eventos (EDA).

## Stack

| Componente | Tecnologia |
|---|---|
| Backend | Node.js 20 + Express + TypeScript |
| ORM | Prisma 5 |
| Banco de dados | PostgreSQL 16 (Docker) |
| MOM | RabbitMQ 3.13 (Docker) |
| App do passageiro | Flutter/Dart (`mobile/`) |
| App do motorista | Flutter/Dart (`mobile-driver/`) |

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Node.js 20+](https://nodejs.org/)
- [Flutter 3.x](https://docs.flutter.dev/get-started/install)
- Android Studio com emulador Android configurado (para o app)

---

## Como executar

### 1. Infraestrutura (banco + broker)

```bash
docker-compose up -d
```

| Serviço | Endereço |
|---|---|
| PostgreSQL | `localhost:5433` |
| RabbitMQ AMQP | `localhost:5672` |
| RabbitMQ Management UI | `http://localhost:15672` (usuário `damd`, senha `damd123`) |

### 2. Backend

```bash
cd backend
npm install
npx prisma migrate dev   # aplica migrações (incluindo notifications e driver_notifications)
```

Variáveis de ambiente em `backend/.env`:
```
DATABASE_URL="postgresql://damd:damd123@localhost:5433/damd_transport"
PORT=3000
RABBITMQ_URL=amqp://damd:damd123@localhost:5672
RIDES_EXCHANGE=rides.events
```

**Terminal 1 — API REST (produtor de eventos):**
```bash
npm run dev
```

**Terminal 2 — Consumer do passageiro (`ride.status_updated`):**
```bash
npm run consumer:passenger
```

**Terminal 3 — Consumer do motorista (`ride.created`):**
```bash
npm run consumer:driver
```

### 3. App do passageiro (Flutter)

**Pré-requisito:** emulador Android iniciado no Android Studio.

```bash
cd mobile
flutter pub get
flutter run -d emulator-5554
```

> O app usa `10.0.2.2:3000` para acessar o backend a partir do emulador Android.
> Para dispositivo físico ou IP diferente:
> ```bash
> flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000/api
> ```

**Gerar APK de release:**
```bash
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

### 4. App do motorista (Flutter)

**Para demonstração ponta-a-ponta, use um segundo emulador (ou dispositivo físico).**

```bash
cd mobile-driver
flutter pub get
flutter run -d emulator-5556   # segundo emulador
```

> Mesmo padrão de baseUrl: `10.0.2.2:3000` para emulador Android.
> Para IP customizado:
> ```bash
> flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000/api
> ```

**Gerar APK de release:**
```bash
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

---

## Endpoints da API

Base URL: `http://localhost:3000/api`

| Método | Rota | Descrição | Evento publicado |
|---|---|---|---|
| POST | `/users` | Criar passageiro | — |
| POST | `/drivers` | Criar motorista | — |
| GET | `/drivers` | Listar motoristas | — |
| POST | `/rides` | Solicitar corrida | `ride.created` |
| GET | `/rides` | Listar corridas (`?userId=X`) | — |
| GET | `/rides/:id` | Buscar corrida por ID | — |
| PATCH | `/rides/:id/status` | Atualizar status (`driverId` opcional) | `ride.status_updated` |
| GET | `/notifications` | Listar notificações do passageiro (`?userId=X&unread=true`) | — |
| PATCH | `/notifications/:id/read` | Marcar notificação do passageiro como lida | — |
| GET | `/driver/notifications` | Listar demandas do motorista (`?unread=true`) | — |
| PATCH | `/driver/notifications/:id/read` | Marcar demanda como lida | — |
| GET | `/health` | Health check | — |

Importe `postman_collection.json` no Postman para exemplos de requisição/resposta.

---

## Arquitetura

Consulte [architecture/diagram.md](architecture/diagram.md) para o diagrama completo (backend + MOM + consumidores).

Consulte [docs/sprint3/arquitetura-app.md](docs/sprint3/arquitetura-app.md) para o diagrama de camadas do app Flutter do passageiro e o fluxo de atualização assíncrona.

Consulte [docs/sprint4/arquitetura-final.md](docs/sprint4/arquitetura-final.md) para o diagrama e2e com os dois apps.

---

## Documentação por Sprint

| Documento | Descrição |
|---|---|
| [docs/sprint2/eventos.md](docs/sprint2/eventos.md) | Catálogo de eventos: payloads, routing keys, filas |
| [docs/sprint2/relatorio-integracao.md](docs/sprint2/relatorio-integracao.md) | Decisões de design, padrões e desafios da integração MOM |
| [docs/sprint3/arquitetura-app.md](docs/sprint3/arquitetura-app.md) | Arquitetura Clean do app do passageiro + fluxo assíncrono |
| [docs/sprint4/arquitetura-final.md](docs/sprint4/arquitetura-final.md) | Diagrama e2e dos dois apps + fluxo ponta-a-ponta |
| [docs/sprint4/relatorio-tecnico-final.md](docs/sprint4/relatorio-tecnico-final.md) | Relatório Técnico Final (Sprint 4) |

---

## Estrutura do projeto

```
damd-agendamento-transporte/
├── docker-compose.yml
├── architecture/diagram.md
├── postman_collection.json
├── docs/
│   ├── sprint2/
│   └── sprint3/
│       └── arquitetura-app.md
├── backend/
│   ├── prisma/schema.prisma
│   └── src/
│       ├── domain/entities/        # Entidades puras
│       ├── application/
│       │   ├── events/             # Interface EventPublisher (port)
│       │   ├── repositories/       # Interfaces de repositório (ports)
│       │   └── use-cases/          # Regras de negócio
│       ├── infrastructure/
│       │   ├── database/           # Prisma repositories
│       │   ├── http/               # Express controllers, routes, middlewares
│       │   └── messaging/          # RabbitMQ publisher, handlers, consumer-runner
│       ├── shared/
│       ├── server.ts               # Entry point — API REST (produtor)
│       ├── consumer-driver.ts      # Entry point — consumer ride.created
│       └── consumer-passenger.ts   # Entry point — consumer ride.status_updated
├── mobile/                         # App Flutter do passageiro
│   └── lib/
│       ├── domain/                 # Entidades e interfaces (sem Flutter/Dio)
│       ├── data/                   # Dio, DTOs, implementações de repositório
│       ├── application/            # Riverpod providers, controllers, poller
│       └── presentation/           # Telas e widgets Flutter
└── mobile-driver/                  # App Flutter do motorista
    └── lib/
        ├── domain/                 # Entidades e interfaces (sem Flutter/Dio)
        ├── data/                   # Dio, DTOs, implementações de repositório
        ├── application/            # Riverpod providers, controllers, demand_poller
        └── presentation/           # Telas e widgets Flutter
```
