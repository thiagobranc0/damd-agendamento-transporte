import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/driver.dart';
import 'providers.dart';

const _keyDriverId = 'driverId';
const _keyDriverName = 'driverName';

class DriverSessionController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDriverId);
  }

  Future<void> identify({
    required String name,
    required String email,
    required String phone,
    required String vehicleModel,
    required String licensePlate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(driverRepositoryProvider);
      Driver driver;
      try {
        driver = await repo.create(
          name: name,
          email: email,
          phone: phone,
          vehicleModel: vehicleModel,
          licensePlate: licensePlate,
        );
      } catch (_) {
        rethrow;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDriverId, driver.id);
      await prefs.setString(_keyDriverName, driver.name);
      return driver.id;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDriverId);
    await prefs.remove(_keyDriverName);
    state = const AsyncData(null);
  }
}

final driverSessionControllerProvider =
    AsyncNotifierProvider<DriverSessionController, String?>(DriverSessionController.new);

// Expõe o nome salvo sem precisar de network
final driverNameProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyDriverName);
});
