# DAMD — Sistema de Agendamento de Transporte

Projeto Integrador — LDAMD | PUC Minas | 2026/1

Sistema distribuído de agendamento de transporte com arquitetura orientada a eventos (EDA).

## Stack

- **Backend**: Node.js + Express + TypeScript
- **ORM**: Prisma
- **Banco de Dados**: PostgreSQL (Docker)
- **MOM**: RabbitMQ (Sprint 2)
- **Apps Móveis**: Flutter/Dart (Sprints 3 e 4)

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Node.js 20+](https://nodejs.org/)
- [npm](https://www.npmjs.com/)

## Como executar (Sprint 1)

### 1. Subir o banco de dados

```bash
docker-compose up -d
```

### 2. Instalar dependências do backend

```bash
cd backend
npm install
```

### 3. Configurar variáveis de ambiente

O arquivo `backend/.env` já vem configurado para o Docker local:

```
DATABASE_URL="postgresql://damd:damd123@localhost:5432/damd_transport"
```

### 4. Rodar as migrações

```bash
cd backend
npx prisma migrate dev --name init
```

### 5. Iniciar o servidor

```bash
cd backend
npm run dev
```

O servidor estará disponível em `http://localhost:3000`.

## Endpoints disponíveis

| Método | Rota                      | Descrição                     |
|--------|---------------------------|-------------------------------|
| POST   | `/api/users`              | Criar passageiro               |
| POST   | `/api/drivers`            | Criar motorista                |
| GET    | `/api/drivers`            | Listar motoristas              |
| POST   | `/api/rides`              | Solicitar corrida              |
| GET    | `/api/rides`              | Listar corridas                |
| GET    | `/api/rides/:id`          | Buscar corrida por ID          |
| PATCH  | `/api/rides/:id/status`   | Atualizar status da corrida    |

Importe `postman_collection.json` no Postman para exemplos de requisição/resposta.

## Arquitetura

Consulte [architecture/diagram.md](architecture/diagram.md) para o diagrama Mermaid do sistema.

## Estrutura do projeto

```
damd-agendamento-transporte/
├── docker-compose.yml
├── architecture/diagram.md
├── postman_collection.json
└── backend/
    ├── prisma/schema.prisma
    └── src/
        ├── domain/          # Entidades puras
        ├── application/     # Use cases + interfaces de repositório
        ├── infrastructure/  # Prisma, Express, controllers
        └── shared/          # Erros compartilhados
```
