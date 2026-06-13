import 'package:flutter/material.dart';
import '../../domain/entities/ride.dart';

class StatusBadge extends StatelessWidget {
  final RideStatus status;

  const StatusBadge({super.key, required this.status});

  Color _resolveColor(BuildContext context) {
    switch (status) {
      case RideStatus.pending:
        return const Color(0xFFD97706);
      case RideStatus.accepted:
        return Theme.of(context).colorScheme.primary;
      case RideStatus.inProgress:
        return const Color(0xFF7C3AED);
      case RideStatus.completed:
        return const Color(0xFF059669);
      case RideStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
