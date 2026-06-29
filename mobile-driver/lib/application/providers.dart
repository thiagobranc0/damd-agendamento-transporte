import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/api_client.dart';
import '../data/repositories_impl/driver_repository_impl.dart';
import '../data/repositories_impl/ride_repository_impl.dart';
import '../data/repositories_impl/driver_notification_repository_impl.dart';
import '../domain/repositories/driver_repository.dart';
import '../domain/repositories/ride_repository.dart';
import '../domain/repositories/driver_notification_repository.dart';

final apiClientProvider = Provider((ref) => createApiClient());

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DriverRepositoryImpl(ref.watch(apiClientProvider)),
);

final rideRepositoryProvider = Provider<RideRepository>(
  (ref) => RideRepositoryImpl(ref.watch(apiClientProvider)),
);

final driverNotificationRepositoryProvider = Provider<DriverNotificationRepository>(
  (ref) => DriverNotificationRepositoryImpl(ref.watch(apiClientProvider)),
);
