import '../../domain/entities/ride.dart';

class RideDto {
  final String id;
  final String userId;
  final String? driverId;
  final String origin;
  final String destination;
  final String status;
  final String scheduledAt;
  final String createdAt;

  const RideDto({
    required this.id,
    required this.userId,
    this.driverId,
    required this.origin,
    required this.destination,
    required this.status,
    required this.scheduledAt,
    required this.createdAt,
  });

  factory RideDto.fromJson(Map<String, dynamic> json) => RideDto(
        id: json['id'] as String,
        userId: json['userId'] as String,
        driverId: json['driverId'] as String?,
        origin: json['origin'] as String,
        destination: json['destination'] as String,
        status: json['status'] as String,
        scheduledAt: json['scheduledAt'] as String,
        createdAt: json['createdAt'] as String,
      );

  Ride toDomain() => Ride(
        id: id,
        userId: userId,
        driverId: driverId,
        origin: origin,
        destination: destination,
        status: RideStatus.fromString(status),
        scheduledAt: DateTime.parse(scheduledAt),
        createdAt: DateTime.parse(createdAt),
      );
}
