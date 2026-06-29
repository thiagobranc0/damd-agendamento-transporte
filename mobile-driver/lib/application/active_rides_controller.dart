import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/ride.dart';
import 'providers.dart';
import 'driver_session_controller.dart';

class ActiveRidesController extends AsyncNotifier<List<Ride>> {
  Timer? _timer;

  @override
  Future<List<Ride>> build() {
    _startPolling();
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<List<Ride>> _fetch() async {
    final driverId = ref.read(driverSessionControllerProvider).valueOrNull;
    if (driverId == null) return [];
    final all = await ref.read(rideRepositoryProvider).listByDriver(driverId);
    return all
        .where((r) => r.status == RideStatus.accepted || r.status == RideStatus.inProgress)
        .toList();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final fresh = await _fetch();
        state = AsyncData(fresh);
      } catch (_) {
        // Erro transitório de rede: mantém os dados atuais, tenta de novo no próximo tick.
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> updateStatus(String rideId, RideStatus status) async {
    await ref.read(rideRepositoryProvider).updateStatus(rideId, status);
    await refresh();
  }
}

final activeRidesControllerProvider =
    AsyncNotifierProvider<ActiveRidesController, List<Ride>>(ActiveRidesController.new);
