import '../../domain/entities/notification.dart';

class NotificationDto {
  final String id;
  final String userId;
  final String rideId;
  final String type;
  final String title;
  final String message;
  final bool read;
  final String createdAt;

  const NotificationDto({
    required this.id,
    required this.userId,
    required this.rideId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) => NotificationDto(
        id: json['id'] as String,
        userId: json['userId'] as String,
        rideId: json['rideId'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        read: json['read'] as bool,
        createdAt: json['createdAt'] as String,
      );

  AppNotification toDomain() => AppNotification(
        id: id,
        userId: userId,
        rideId: rideId,
        type: type,
        title: title,
        message: message,
        read: read,
        createdAt: DateTime.parse(createdAt),
      );
}
