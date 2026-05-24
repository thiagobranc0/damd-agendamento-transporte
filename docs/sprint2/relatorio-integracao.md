# Relatório de Integração — Sprint 2

**Sistema:** Agendamento de Transporte · **Data:** 25/05/2026
**Disciplina:** LDAMD — PUC Minas, Engenharia de Software, 5º Período

---

## 1. Escolha do MOM: RabbitMQ

O middleware orientado a mensagens escolhido foi o **RabbitMQ 3.13**, executado em contêiner Docker via `docker-compose`.

A decisão considerou três critérios:

**Durabilidade.** Diferente do Redis Pub/Sub, o RabbitMQ persiste mensagens em disco (exchanges e filas declaradas com `durable: true`). Caso o worker caia, as mensagens aguardam na fila e são reprocessadas na reconexão — comportamento essencial em sistemas de transporte onde uma corrida não pode ser silenciosamente descartada.

**Acknowledgment manual.** O protocolo AMQP suporta `ack` e `nack` explícitos. O worker só confirma a mensagem (`channel.ack`) após processar com sucesso; em falha, executa `nack` com `requeue: false`, descartando sem travar a fila. Isso garante *at-least-once delivery* do lado do broker.

**Management UI embutida.** A imagem `rabbitmq:3.13-management-alpine` expõe um painel web em `http://localhost:15672` com visibilidade em tempo real de exchanges, filas, throughput e mensagens acumuladas — recurso direto para evidenciar o funcionamento durante a avaliação.

---

## 2. Padrão Utilizado

Adotou-se o padrão **Publish/Subscribe** com **Topic Exchange**.

Uma única exchange `rides.events` do tipo `topic` recebe todas as publicações do backend. As filas são vinculadas por *routing keys* exatas (`ride.created`, `ride.status_updated`), o que permite adicionar futuros eventos no mesmo exchange sem alterar consumidores existentes — o binding filtra somente o que cada fila precisa.

O fluxo assíncrono funciona da seguinte forma:

```
POST /api/rides
    ↓ (HTTP, síncrono)
CreateRideUseCase.execute()
    ↓ persiste no banco (Prisma/PostgreSQL)
    ↓ publica evento "ride.created" em rides.events
    ↓ retorna 201 ao cliente
         ↕ (assíncrono, sem chamada REST)
Worker (processo separado)
    ↓ consome fila notifications.driver
    ↓ executa notifyDriverHandler
    ↓ ack → mensagem removida da fila
```

A resposta HTTP retorna imediatamente após a persistência no banco. A publicação no broker e o consumo pelo worker ocorrem de forma **completamente desacoplada** — o cliente REST nunca espera pelo processamento do evento.

---

## 3. Preservação da Clean Architecture

A integração respeitou a regra de dependência da Clean Architecture:

- **Camada Domain:** nenhuma alteração.
- **Camada Application:** criada a interface `EventPublisher` (`src/application/events/event-publisher.ts`). Os use cases `CreateRideUseCase` e `UpdateRideStatusUseCase` recebem a interface via construtor — nunca a implementação concreta.
- **Camada Infrastructure:** a classe `RabbitMQEventPublisher` implementa `EventPublisher`. O singleton de conexão `rabbitmq-connection.ts` e os handlers ficam em `src/infrastructure/messaging/`.
- **Wiring:** o controller (Infrastructure) instancia `RabbitMQEventPublisher` e o injeta nos use cases. Nenhuma referência ao RabbitMQ existe fora da camada Infrastructure.

Esse isolamento garante que, se o MOM for trocado (ex.: para Redis Streams), apenas a implementação em Infrastructure precisa ser substituída — os use cases e o domínio permanecem intocados.

---

## 4. Desafios e Soluções

**Ordem de inicialização.** O worker pode subir antes do broker estar pronto. Solução: tanto o publisher quanto o worker executam `assertExchange` e `assertQueue` ao conectar, tornando a declaração idempotente. Em produção seria necessário retry com backoff exponencial.

**Falha do broker não deve derrubar o HTTP.** Se o RabbitMQ estiver indisponível, a corrida já foi persistida no banco; perder o evento é preferível a retornar erro 500 ao passageiro. A implementação captura exceções no publisher e loga sem propagar — garantia eventual fica como dívida técnica para sprints futuras.

**Tipos TypeScript para amqplib v2.** A versão 2.x do amqplib mudou o tipo de retorno de `connect` de `Connection` para `ChannelModel`. Após identificar a divergência nos typings instalados (`@types/amqplib`), os arquivos de conexão foram ajustados para usar `ChannelModel`, eliminando erros de compilação.

---

## 5. Próximos Passos (Sprints 3 e 4)

Os handlers `notifyDriverHandler` e `notifyPassengerHandler` são stubs deliberados. Nas próximas sprints serão substituídos por:

- **Sprint 3 (App Passageiro):** polling assíncrono ou WebSocket no app Flutter consumindo o endpoint `GET /api/rides` — o handler pode persistir em tabela de notificações para facilitar o polling.
- **Sprint 4 (App Motorista):** o worker passa a enviar push via Firebase Cloud Messaging (FCM) ou manter conexão WebSocket com o app do motorista.

A interface `EventPublisher` e a topologia de filas permanecem inalteradas nessa evolução.

---
