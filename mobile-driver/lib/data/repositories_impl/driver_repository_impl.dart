import 'package:dio/dio.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/driver_repository.dart';
import '../dtos/driver_dto.dart';

class DriverRepositoryImpl implements DriverRepository {
  final Dio _dio;
  DriverRepositoryImpl(this._dio);

  @override
  Future<Driver> create({
    required String name,
    required String email,
    required String phone,
    required String vehicleModel,
    required String licensePlate,
  }) async {
    final response = await _dio.post('/drivers', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'vehicleModel': vehicleModel,
      'licensePlate': licensePlate,
    });
    return DriverDto.fromJson(response.data as Map<String, dynamic>);
  }
}
