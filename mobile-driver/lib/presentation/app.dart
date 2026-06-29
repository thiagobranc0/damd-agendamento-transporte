import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/driver_session_controller.dart';
import 'screens/driver_identify_screen.dart';
import 'screens/available_rides_screen.dart';
import 'screens/ride_request_detail_screen.dart';
import 'screens/active_rides_screen.dart';
import 'theme/app_theme.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  final sessionAsync = ref.watch(driverSessionControllerProvider);

  return GoRouter(
    redirect: (context, state) {
      if (sessionAsync.isLoading) return null;
      final loggedIn = sessionAsync.valueOrNull != null;
      final isIdentify = state.matchedLocation == '/';
      if (!loggedIn && !isIdentify) return '/';
      if (loggedIn && isIdentify) return '/rides';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (ctx, _) => const DriverIdentifyScreen()),
      GoRoute(path: '/rides', builder: (ctx, _) => const AvailableRidesScreen()),
      GoRoute(
        path: '/rides/:id',
        builder: (_, state) =>
            RideRequestDetailScreen(rideId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/active', builder: (ctx, _) => const ActiveRidesScreen()),
    ],
  );
});

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'DAMD Motorista',
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
