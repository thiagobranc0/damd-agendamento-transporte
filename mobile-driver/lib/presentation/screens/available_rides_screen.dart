import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/available_rides_controller.dart';
import '../../application/demand_poller.dart';
import '../../domain/entities/ride.dart';
import '../widgets/async_value_view.dart';
import '../widgets/status_badge.dart';

class AvailableRidesScreen extends ConsumerWidget {
  const AvailableRidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(availableRidesControllerProvider);
    final unread = ref.watch(unreadDemandCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corridas Disponíveis'),
        actions: [
          if (unread > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Badge(
                label: Text('$unread'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Atualizar',
            onPressed: () =>
                ref.read(availableRidesControllerProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AsyncValueView<List<Ride>>(
        value: ridesAsync,
        emptyMessage: 'Nenhuma corrida disponível.',
        isEmpty: (list) => list.isEmpty,
        builder: (rides) => RefreshIndicator(
          onRefresh: () =>
              ref.read(availableRidesControllerProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: rides.length,
            itemBuilder: (_, i) => _RideCard(ride: rides[i]),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) context.go('/active');
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

class _RideCard extends StatelessWidget {
  final Ride ride;
  const _RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: () => context.push('/rides/${ride.id}'),
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
              _RouteRow(origin: ride.origin, destination: ride.destination),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String origin;
  final String destination;
  const _RouteRow({required this.origin, required this.destination});

  @override
  Widget build(BuildContext context) {
    final sub = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Row(
      children: [
        Column(
          children: [
            Icon(Icons.trip_origin, size: 14,
                color: Theme.of(context).colorScheme.primary),
            Container(width: 1, height: 20, color: Theme.of(context).colorScheme.outlineVariant),
            Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.error),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(origin, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(destination, style: sub),
            ],
          ),
        ),
      ],
    );
  }
}
