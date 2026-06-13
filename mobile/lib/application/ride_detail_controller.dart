import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/ride.dart';
import 'providers.dart';

class RideDetailController extends AutoDisposeFamilyAsyncNotifier<Ride, String> {
  @override
  Future<Ride> build(String rideId) async {
    return ref.read(rideRepositoryProvider).getById(rideId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final rideDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<RideDetailController, Ride, String>(RideDetailController.new);
