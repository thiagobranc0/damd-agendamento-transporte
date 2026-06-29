import '../../domain/entities/driver.dart';

class DriverDto {
  static Driver fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      vehicleModel: json['vehicleModel'] as String,
      licensePlate: json['licensePlate'] as String,
    );
  }
}
