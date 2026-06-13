import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/session_controller.dart';
import 'theme/app_theme.dart';
import 'screens/identify_screen.dart';
import 'screens/rides_list_screen.dart';
import 'screens/create_ride_screen.dart';
import 'screens/ride_detail_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  final sessionAsync = ref.watch(sessionControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (sessionAsync.isLoading) return null;
      final userId = sessionAsync.valueOrNull;
      final onIdentify = state.matchedLocation == '/';

      if (userId == null && !onIdentify) return '/';
      if (userId != null && onIdentify) return '/rides';
      return null;
    },
    refreshListenable: _SessionListenable(ref),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const IdentifyScreen()),
      GoRoute(path: '/rides', builder: (context, state) => const RidesListScreen()),
      GoRoute(path: '/rides/new', builder: (context, state) => const CreateRideScreen()),
      GoRoute(
        path: '/rides/:id',
        builder: (context, state) =>
            RideDetailScreen(rideId: state.pathParameters['id']!),
      ),
    ],
  );
});

class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionControllerProvider, (previous, next) => notifyListeners());
  }
}

class DamdPassengerApp extends ConsumerWidget {
  const DamdPassengerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      title: 'DAMD Passageiro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
