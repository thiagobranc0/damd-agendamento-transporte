import 'package:dio/dio.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../dtos/notification_dto.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;

  NotificationRepositoryImpl(this._dio);

  @override
  Future<List<AppNotification>> listByUser(
    String userId, {
    bool onlyUnread = false,
  }) async {
    final response = await _dio.get('/notifications', queryParameters: {
      'userId': userId,
      if (onlyUnread) 'unread': 'true',
    });
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
            NotificationDto.fromJson(e as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.patch('/notifications/$id/read');
  }
}
