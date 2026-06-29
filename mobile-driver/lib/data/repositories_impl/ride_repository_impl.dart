import 'package:dio/dio.dart';
import '../../domain/entities/ride.dart';
import '../../domain/repositories/ride_repository.dart';
import '../dtos/ride_dto.dart';

class RideRepositoryImpl implements RideRepository {
  final Dio _dio;
  RideRepositoryImpl(this._dio);

  @override
  Future<List<Ride>> listPending() async {
    final response = await _dio.get('/rides', queryParameters: {'status': 'PENDING'});
    final list = response.data as List<dynamic>;
    return list.map((e) => RideDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Ride>> listByDriver(String driverId) async {
    final response = await _dio.get('/rides', queryParameters: {'driverId': driverId});
    final list = response.data as List<dynamic>;
    return list.map((e) => RideDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Ride> getById(String id) async {
    final response = await _dio.get('/rides/$id');
    return RideDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Ride> updateStatus(String id, RideStatus status, {String? driverId}) async {
    final body = <String, dynamic>{'status': status.toApiString()};
    if (driverId != null) body['driverId'] = driverId;
    final response = await _dio.patch('/rides/$id/status', data: body);
    return RideDto.fromJson(response.data as Map<String, dynamic>);
  }
}
