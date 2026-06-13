import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/ride.dart';
import 'providers.dart';
import 'session_controller.dart';

class RidesController extends AsyncNotifier<List<Ride>> {
  @override
  Future<List<Ride>> build() async {
    final userId = await ref.watch(sessionControllerProvider.future);
    if (userId == null) return [];
    return ref.read(rideRepositoryProvider).listByUser(userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<Ride> createRide({
    required String userId,
    required String origin,
    required String destination,
    required DateTime scheduledAt,
  }) async {
    final ride = await ref.read(rideRepositoryProvider).create(
          userId: userId,
          origin: origin,
          destination: destination,
          scheduledAt: scheduledAt,
        );
    await refresh();
    return ride;
  }
}

final ridesControllerProvider =
    AsyncNotifierProvider<RidesController, List<Ride>>(RidesController.new);
