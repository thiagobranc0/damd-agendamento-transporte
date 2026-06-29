import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/active_rides_controller.dart';
import '../../domain/entities/ride.dart';
import '../widgets/async_value_view.dart';
import '../widgets/status_badge.dart';

class ActiveRidesScreen extends ConsumerWidget {
  const ActiveRidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(activeRidesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Em Andamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.read(activeRidesControllerProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AsyncValueView<List<Ride>>(
        value: ridesAsync,
        emptyMessage: 'Nenhuma corrida em andamento.',
        isEmpty: (list) => list.isEmpty,
        builder: (rides) => RefreshIndicator(
          onRefresh: () => ref.read(activeRidesControllerProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: rides.length,
            itemBuilder: (_, i) => _ActiveRideCard(ride: rides[i]),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/rides');
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.list_alt_outlined), label: 'Disponíveis'),
          NavigationDestination(
              icon: Icon(Icons.directions_car_outlined), label: 'Em Andamento'),
        ],
      ),
    );
  }
}

class _ActiveRideCard extends ConsumerStatefulWidget {
  final Ride ride;
  const _ActiveRideCard({required this.ride});

  @override
  ConsumerState<_ActiveRideCard> createState() => _ActiveRideCardState();
}

class _ActiveRideCardState extends ConsumerState<_ActiveRideCard> {
  bool _loading = false;

  Future<void> _transition(RideStatus to) async {
    setState(() => _loading = true);
    try {
      await ref.read(activeRidesControllerProvider.notifier).updateStatus(widget.ride.id, to);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    final ride = widget.ride;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: ride.status),
                Text(
                  fmt.format(ride.scheduledAt.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(ride.origin,
                style: Theme.of(context).textTheme.bodyMedium),
            Text('→ ${ride.destination}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            if (ride.status == RideStatus.accepted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : () => _transition(RideStatus.inProgress),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Iniciar corrida'),
                ),
              ),
            if (ride.status == RideStatus.inProgress)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669)),
                  onPressed: _loading ? null : () => _transition(RideStatus.completed),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Concluir corrida'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
