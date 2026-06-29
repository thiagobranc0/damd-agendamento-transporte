class DriverNotification {
  final String id;
  final String rideId;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  const DriverNotification({
    required this.id,
    required this.rideId,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });
}
