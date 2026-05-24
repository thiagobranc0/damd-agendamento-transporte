export interface EventPublisher {
  publish(routingKey: string, payload: unknown): Promise<void>
}
