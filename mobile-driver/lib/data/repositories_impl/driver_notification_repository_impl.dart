import 'package:dio/dio.dart';
import '../../domain/entities/driver_notification.dart';
import '../../domain/repositories/driver_notification_repository.dart';
import '../dtos/driver_notification_dto.dart';

class DriverNotificationRepositoryImpl implements DriverNotificationRepository {
  final Dio _dio;
  DriverNotificationRepositoryImpl(this._dio);

  @override
  Future<List<DriverNotification>> listUnread() async {
    final response = await _dio.get('/driver/notifications', queryParameters: {'unread': 'true'});
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DriverNotificationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markRead(String id) async {
    await _dio.patch('/driver/notifications/$id/read');
  }
}
