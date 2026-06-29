import '../../domain/entities/ride.dart';

class RideDto {
  static Ride fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String,
      userId: json['userId'] as String,
      driverId: json['driverId'] as String?,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      status: RideStatus.fromString(json['status'] as String),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
