# Diagrama de Arquitetura — Sistema de Agendamento de Transporte

> Renderize este arquivo com a extensão **Mermaid Preview** no VSCode ou abra no GitHub.

```mermaid
graph TB
    subgraph Backend ["⚙️ Backend — Node.js + TypeScript"]
        subgraph Infrastructure ["Infrastructure Layer"]
            Controllers["Controllers\n(Express)"]
            PrismaRepos["Repositories\n(Prisma)"]
        end
        subgraph Application ["Application Layer"]
            UseCases["Use Cases\nCreateRide | ListRides\nGetRide | UpdateStatus\nCreateUser | CreateDriver"]
            RepoInterfaces["Repository Interfaces\n(Ports)"]
        end
        subgraph Domain ["Domain Layer"]
            Entities["Entities\nUser · Driver · Ride"]
            RideStatus["RideStatus\nPENDING · ACCEPTED\nIN_PROGRESS · COMPLETED\nCANCELLED"]
        end
    end

    subgraph DB ["🗄️ Infraestrutura de Dados"]
        Postgres[("PostgreSQL\n(Docker)")]
    end

    Controllers --> UseCases
    UseCases --> RepoInterfaces
    RepoInterfaces -.->|"implementa"| PrismaRepos
    UseCases --> Entities
    Entities --> RideStatus
    PrismaRepos -- "Prisma ORM" --> Postgres

    style Backend fill:#f3f9f3,stroke:#4CAF50
    style Domain fill:#fff8e1,stroke:#FFC107
    style Application fill:#fce4ec,stroke:#E91E63
    style Infrastructure fill:#f3e5f5,stroke:#9C27B0
    style DB fill:#e8eaf6,stroke:#3F51B5
```

## Descrição dos Componentes

| Componente | Tecnologia | Papel |
|---|---|---|
| Backend REST | Node.js + Express + TypeScript | Lógica de negócio, expõe API RESTful |
| ORM | Prisma | Acesso tipado ao banco de dados |
| Banco de Dados | PostgreSQL (Docker) | Persistência de dados |
