import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../dtos/user_dto.dart';

class UserRepositoryImpl implements UserRepository {
  final Dio _dio;

  UserRepositoryImpl(this._dio);

  @override
  Future<User> create({
    required String name,
    required String email,
    required String phone,
  }) async {
    final response = await _dio.post('/users', data: {
      'name': name,
      'email': email,
      'phone': phone,
    });
    return UserDto.fromJson(response.data as Map<String, dynamic>).toDomain();
  }
}
