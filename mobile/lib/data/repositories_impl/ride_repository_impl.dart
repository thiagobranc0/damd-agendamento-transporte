import 'package:dio/dio.dart';
import '../../domain/entities/ride.dart';
import '../../domain/repositories/ride_repository.dart';
import '../dtos/ride_dto.dart';

class RideRepositoryImpl implements RideRepository {
  final Dio _dio;

  RideRepositoryImpl(this._dio);

  @override
  Future<Ride> create({
    required String userId,
    required String origin,
    required String destination,
    required DateTime scheduledAt,
  }) async {
    final response = await _dio.post('/rides', data: {
      'userId': userId,
      'origin': origin,
      'destination': destination,
      'scheduledAt': scheduledAt.toIso8601String(),
    });
    return RideDto.fromJson(response.data as Map<String, dynamic>).toDomain();
  }

  @override
  Future<List<Ride>> listByUser(String userId) async {
    final response = await _dio.get('/rides', queryParameters: {'userId': userId});
    final list = response.data as List<dynamic>;
    return list
        .map((e) => RideDto.fromJson(e as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<Ride> getById(String id) async {
    final response = await _dio.get('/rides/$id');
    return RideDto.fromJson(response.data as Map<String, dynamic>).toDomain();
  }
}
