enum RideStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled;

  static RideStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return RideStatus.pending;
      case 'ACCEPTED':
        return RideStatus.accepted;
      case 'IN_PROGRESS':
        return RideStatus.inProgress;
      case 'COMPLETED':
        return RideStatus.completed;
      case 'CANCELLED':
        return RideStatus.cancelled;
      default:
        return RideStatus.pending;
    }
  }

  String toApiString() {
    switch (this) {
      case RideStatus.pending:
        return 'PENDING';
      case RideStatus.accepted:
        return 'ACCEPTED';
      case RideStatus.inProgress:
        return 'IN_PROGRESS';
      case RideStatus.completed:
        return 'COMPLETED';
      case RideStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get label {
    switch (this) {
      case RideStatus.pending:
        return 'Pendente';
      case RideStatus.accepted:
        return 'Aceita';
      case RideStatus.inProgress:
        return 'Em Andamento';
      case RideStatus.completed:
        return 'Concluída';
      case RideStatus.cancelled:
        return 'Cancelada';
    }
  }

  bool get isTerminal => this == RideStatus.completed || this == RideStatus.cancelled;
}

class Ride {
  final String id;
  final String userId;
  final String? driverId;
  final String origin;
  final String destination;
  final RideStatus status;
  final DateTime scheduledAt;
  final DateTime createdAt;

  const Ride({
    required this.id,
    required this.userId,
    this.driverId,
    required this.origin,
    required this.destination,
    required this.status,
    required this.scheduledAt,
    required this.createdAt,
  });
}
