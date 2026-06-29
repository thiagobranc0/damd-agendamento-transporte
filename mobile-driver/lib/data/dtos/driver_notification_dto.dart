import '../../domain/entities/driver_notification.dart';

class DriverNotificationDto {
  static DriverNotification fromJson(Map<String, dynamic> json) {
    return DriverNotification(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
