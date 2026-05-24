# DAMD — Sistema de Agendamento de Transporte

Projeto Integrador — LDAMD | PUC Minas | 2026/1

Sistema distribuído de agendamento de transporte com arquitetura orientada a eventos (EDA).

## Stack

- **Backend**: Node.js + Express + TypeScript
- **ORM**: Prisma
- **Banco de Dados**: PostgreSQL (Docker)
- **MOM**: RabbitMQ 3.13 (Docker)
- **Apps Móveis**: Flutter/Dart (Sprints 3 e 4)

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Node.js 20+](https://nodejs.org/)
- [npm](https://www.npmjs.com/)

## Como executar (Sprint 2)

### 1. Subir banco de dados e broker de mensagens

```bash
docker-compose up -d
```

Serviços iniciados:
- **PostgreSQL** em `localhost:5433`
- **RabbitMQ** em `localhost:5672` (AMQP) e `localhost:15672` (Management UI)

Acesso à Management UI: `http://localhost:15672` · usuário `damd` · senha `damd123`

### 2. Instalar dependências do backend

```bash
cd backend
npm install
```

### 3. Configurar variáveis de ambiente

O arquivo `backend/.env` já vem configurado para o Docker local:

```
DATABASE_URL="postgresql://damd:damd123@localhost:5433/damd_transport"
PORT=3000
RABBITMQ_URL=amqp://damd:damd123@localhost:5672
RIDES_EXCHANGE=rides.events
```

### 4. Rodar as migrações

```bash
cd backend
npx prisma migrate dev
```

### 5. Iniciar o servidor REST (Terminal 1)

```bash
cd backend
npm run dev
```

O servidor estará disponível em `http://localhost:3000`.

### 6. Iniciar o worker consumidor (Terminal 2)

```bash
cd backend
npm run worker
```

O worker conecta ao RabbitMQ, declara exchange e filas, e aguarda eventos. Cada chamada a `POST /api/rides` ou `PATCH /api/rides/:id/status` gera uma mensagem processada pelo worker no terminal 2.

## Endpoints disponíveis

| Método | Rota                      | Descrição                      | Evento publicado |
|--------|---------------------------|--------------------------------|------------------|
| POST   | `/api/users`              | Criar passageiro               | —                |
| POST   | `/api/drivers`            | Criar motorista                | —                |
| GET    | `/api/drivers`            | Listar motoristas              | —                |
| POST   | `/api/rides`              | Solicitar corrida              | `ride.created`   |
| GET    | `/api/rides`              | Listar corridas                | —                |
| GET    | `/api/rides/:id`          | Buscar corrida por ID          | —                |
| PATCH  | `/api/rides/:id/status`   | Atualizar status da corrida    | `ride.status_updated` |

Importe `postman_collection.json` no Postman para exemplos de requisição/resposta.

## Arquitetura

Consulte [architecture/diagram.md](architecture/diagram.md) para o diagrama Mermaid completo (backend + MOM + worker).

## Documentação Sprint 2

| Documento | Descrição |
|---|---|
| [docs/sprint2/eventos.md](docs/sprint2/eventos.md) | Catálogo de eventos: payloads, routing keys, filas |
| [docs/sprint2/relatorio-integracao.md](docs/sprint2/relatorio-integracao.md) | Decisões de design, padrões e desafios da integração MOM |

## Estrutura do projeto

```
damd-agendamento-transporte/
├── docker-compose.yml
├── architecture/diagram.md
├── postman_collection.json
└── backend/
    ├── prisma/schema.prisma
    └── src/
        ├── domain/            # Entidades puras
        ├── application/
        │   ├── events/        # Interface EventPublisher (port)
        │   ├── repositories/  # Interfaces de repositório (ports)
        │   └── use-cases/     # Regras de negócio
        ├── infrastructure/
        │   ├── database/      # Prisma repositories
        │   ├── http/          # Express controllers, routes, middlewares
        │   └── messaging/     # RabbitMQ publisher + handlers
        ├── shared/            # Erros compartilhados
        ├── server.ts          # Entry point da API REST
        └── worker.ts          # Entry point do consumidor de eventos
```
