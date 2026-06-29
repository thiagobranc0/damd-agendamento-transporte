import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/available_rides_controller.dart';
import '../../application/active_rides_controller.dart';
import '../../application/demand_poller.dart';
import '../../application/driver_session_controller.dart';
import '../../application/providers.dart';
import '../../domain/entities/ride.dart';
import '../widgets/status_badge.dart';

final _rideDetailProvider = FutureProvider.autoDispose.family<Ride, String>((ref, id) {
  return ref.read(rideRepositoryProvider).getById(id);
});

class RideRequestDetailScreen extends ConsumerWidget {
  final String rideId;
  const RideRequestDetailScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideAsync = ref.watch(_rideDetailProvider(rideId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Corrida')),
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (ride) {
          if (ride.status != RideStatus.pending) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block,
                        size: 56, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Esta corrida não está mais disponível.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _RideDetail(ride: ride);
        },
      ),
    );
  }
}

class _RideDetail extends ConsumerStatefulWidget {
  final Ride ride;
  const _RideDetail({required this.ride});

  @override
  ConsumerState<_RideDetail> createState() => _RideDetailState();
}

class _RideDetailState extends ConsumerState<_RideDetail> {
  bool _loading = false;

  Future<void> _accept() async {
    final driverId = ref.read(driverSessionControllerProvider).valueOrNull;
    if (driverId == null) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(rideRepositoryProvider)
          .updateStatus(widget.ride.id, RideStatus.accepted, driverId: driverId);

      // Marca notificações relacionadas a esta corrida como lidas
      final notifications = ref.read(demandPollerProvider).valueOrNull ?? [];
      for (final n in notifications.where((n) => n.rideId == widget.ride.id)) {
        await ref.read(demandPollerProvider.notifier).markRead(n.id);
      }

      await ref.read(availableRidesControllerProvider.notifier).refresh();
      await ref.read(activeRidesControllerProvider.notifier).refresh();

      if (mounted) context.go('/active');
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

  void _refuse() {
    // Recusa é client-side: a corrida permanece PENDING no backend para outros motoristas.
    ref.read(availableRidesControllerProvider.notifier).refresh();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    final ride = widget.ride;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(status: ride.status),
          const SizedBox(height: 24),
          _InfoRow(label: 'Origem', value: ride.origin, icon: Icons.trip_origin),
          const Divider(height: 24),
          _InfoRow(label: 'Destino', value: ride.destination, icon: Icons.location_on),
          const Divider(height: 24),
          _InfoRow(
            label: 'Agendado para',
            value: fmt.format(ride.scheduledAt.toLocal()),
            icon: Icons.schedule,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _loading ? null : _accept,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Aceitar corrida'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : _refuse,
            child: const Text('Recusar'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
