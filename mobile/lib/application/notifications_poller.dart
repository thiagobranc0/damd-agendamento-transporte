import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/notification.dart';
import 'providers.dart';
import 'session_controller.dart';

const _pollInterval = Duration(seconds: 5);

class NotificationsPoller extends AsyncNotifier<List<AppNotification>> {
  Timer? _timer;

  @override
  Future<List<AppNotification>> build() async {
    ref.onDispose(() => _timer?.cancel());

    final userId = await ref.watch(sessionControllerProvider.future);
    if (userId == null) return [];

    _startPolling(userId);
    return _fetch(userId);
  }

  void _startPolling(String userId) {
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) async {
      final fresh = await AsyncValue.guard(() => _fetch(userId));
      state = fresh;
    });
  }

  Future<List<AppNotification>> _fetch(String userId) {
    return ref
        .read(notificationRepositoryProvider)
        .listByUser(userId, onlyUnread: true);
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    final userId = await ref.read(sessionControllerProvider.future);
    if (userId != null) {
      state = await AsyncValue.guard(() => _fetch(userId));
    }
  }
}

final notificationsPollerProvider =
    AsyncNotifierProvider<NotificationsPoller, List<AppNotification>>(
        NotificationsPoller.new);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsPollerProvider).maybeWhen(
        data: (list) => list.where((n) => !n.read).length,
        orElse: () => 0,
      );
});

// Busca todas as notificações (lidas + não lidas) para exibir no painel
final allNotificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final userId = await ref.watch(sessionControllerProvider.future);
  if (userId == null) return [];
  return ref.read(notificationRepositoryProvider).listByUser(userId, onlyUnread: false);
});
