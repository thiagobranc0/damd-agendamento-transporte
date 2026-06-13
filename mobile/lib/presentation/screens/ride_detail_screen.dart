import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/ride_detail_controller.dart';
import '../../application/notifications_poller.dart';
import '../../domain/entities/ride.dart';
import '../widgets/status_badge.dart';
import '../widgets/async_value_view.dart';

class RideDetailScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideDetailScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends ConsumerState<RideDetailScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final currentState =
          ref.read(rideDetailControllerProvider(widget.rideId));
      final ride = currentState.valueOrNull;
      if (ride == null || !ride.status.isTerminal) {
        ref
            .read(rideDetailControllerProvider(widget.rideId).notifier)
            .refresh();
      } else {
        _pollingTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(rideDetailControllerProvider(widget.rideId));

    // Mark related notifications as read when user views detail
    ref.listen(notificationsPollerProvider, (_, next) {
      next.whenData((notifications) {
        for (final n in notifications.where((n) => n.rideId == widget.rideId && !n.read)) {
          ref.read(notificationsPollerProvider.notifier).markRead(n.id);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da Corrida'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(rideDetailControllerProvider(widget.rideId).notifier)
                .refresh(),
          ),
        ],
      ),
      body: AsyncValueView(
        value: rideState,
        builder: (ride) => _RideDetailBody(ride: ride),
      ),
    );
  }
}

class _RideDetailBody extends StatelessWidget {
  final Ride ride;

  const _RideDetailBody({required this.ride});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(ride.scheduledAt.toLocal());

    final allStatuses = [
      RideStatus.pending,
      RideStatus.accepted,
      RideStatus.inProgress,
      RideStatus.completed,
    ];

    final currentIndex = allStatuses.indexOf(ride.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: StatusBadge(status: ride.status)),
          const SizedBox(height: 24),
          _InfoRow(icon: Icons.trip_origin, color: const Color(0xFF059669), label: 'Origem', value: ride.origin),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.place, color: const Color(0xFFDC2626), label: 'Destino', value: ride.destination),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.schedule,
            color: Theme.of(context).colorScheme.primary,
            label: 'Agendada para',
            value: dateStr,
          ),
          if (ride.driverId != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person_outline,
              color: const Color(0xFF7C3AED),
              label: 'Motorista',
              value: ride.driverId!,
            ),
          ],
          const SizedBox(height: 32),
          Text(
            'Progresso',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (ride.status != RideStatus.cancelled)
            _StatusTimeline(
              statuses: allStatuses,
              currentIndex: currentIndex,
            )
          else
            const Center(
              child: Chip(
                label: Text('Corrida cancelada'),
                backgroundColor: Colors.redAccent,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
          if (!ride.status.isTerminal) ...[
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Atualizando automaticamente...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final List<RideStatus> statuses;
  final int currentIndex;

  const _StatusTimeline({required this.statuses, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isDone = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: isCurrent
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (index < statuses.length - 1)
                  Container(
                    width: 2,
                    height: 28,
                    color: index < currentIndex
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                status.label,
                style: TextStyle(
                  fontWeight:
                      isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isDone
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
