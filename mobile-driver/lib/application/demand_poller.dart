import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/driver_notification.dart';
import 'providers.dart';

/// Mantém o contador de demandas não lidas (badge "nova corrida").
/// A lista de corridas disponíveis se atualiza por conta própria
/// (ver AvailableRidesController); aqui só alimentamos o sininho.
class DemandPoller extends AsyncNotifier<List<DriverNotification>> {
  Timer? _timer;

  @override
  Future<List<DriverNotification>> build() {
    _startPolling();
    ref.onDispose(() => _timer?.cancel());
    return _fetchUnread();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final fresh = await _fetchUnread();
        state = AsyncData(fresh);
      } catch (_) {
        // Erro transitório de rede: mantém o estado atual.
      }
    });
  }

  Future<List<DriverNotification>> _fetchUnread() {
    return ref.read(driverNotificationRepositoryProvider).listUnread();
  }

  Future<void> markRead(String id) async {
    await ref.read(driverNotificationRepositoryProvider).markRead(id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((n) => n.id != id).toList(),
    );
  }
}

final demandPollerProvider =
    AsyncNotifierProvider<DemandPoller, List<DriverNotification>>(DemandPoller.new);

final unreadDemandCountProvider = Provider<int>((ref) {
  return ref.watch(demandPollerProvider).valueOrNull?.length ?? 0;
});
