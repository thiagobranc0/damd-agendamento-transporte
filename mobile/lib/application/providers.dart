import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/api_client.dart';
import '../data/repositories_impl/user_repository_impl.dart';
import '../data/repositories_impl/ride_repository_impl.dart';
import '../data/repositories_impl/notification_repository_impl.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/ride_repository.dart';
import '../domain/repositories/notification_repository.dart';

final apiClientProvider = Provider((ref) => createApiClient());

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.read(apiClientProvider)),
);

final rideRepositoryProvider = Provider<RideRepository>(
  (ref) => RideRepositoryImpl(ref.read(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.read(apiClientProvider)),
);
