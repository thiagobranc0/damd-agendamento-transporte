import '../entities/driver.dart';

abstract class DriverRepository {
  Future<Driver> create({
    required String name,
    required String email,
    required String phone,
    required String vehicleModel,
    required String licensePlate,
  });
}
