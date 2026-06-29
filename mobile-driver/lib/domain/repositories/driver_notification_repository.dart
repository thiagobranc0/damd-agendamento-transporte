import '../entities/driver_notification.dart';

abstract class DriverNotificationRepository {
  Future<List<DriverNotification>> listUnread();
  Future<void> markRead(String id);
}
