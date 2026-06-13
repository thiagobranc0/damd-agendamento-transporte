import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/ride.dart';
import 'status_badge.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;

  const RideCard({super.key, required this.ride, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(ride.scheduledAt.toLocal());

    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trip_origin, size: 14, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.origin,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: SizedBox(
                  height: 12,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.place, size: 14, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.destination,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: ride.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
