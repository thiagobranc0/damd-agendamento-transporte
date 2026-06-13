import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> listByUser(String userId, {bool onlyUnread});
  Future<void> markAsRead(String id);
}
