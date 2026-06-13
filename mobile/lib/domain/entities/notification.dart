class AppNotification {
  final String id;
  final String userId;
  final String rideId;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.rideId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });
}
