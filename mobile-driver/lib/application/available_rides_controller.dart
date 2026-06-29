import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/ride.dart';
import 'providers.dart';

class AvailableRidesController extends AsyncNotifier<List<Ride>> {
  Timer? _timer;

  @override
  Future<List<Ride>> build() {
    _startPolling();
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<List<Ride>> _fetch() {
    return ref.read(rideRepositoryProvider).listPending();
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
}

final availableRidesControllerProvider =
    AsyncNotifierProvider<AvailableRidesController, List<Ride>>(
        AvailableRidesController.new);
