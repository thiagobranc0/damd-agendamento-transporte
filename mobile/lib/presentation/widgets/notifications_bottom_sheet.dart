import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/notifications_poller.dart';
import '../../domain/entities/notification.dart';

void showNotificationsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends ConsumerStatefulWidget {
  const _NotificationsSheet();

  @override
  ConsumerState<_NotificationsSheet> createState() =>
      _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<_NotificationsSheet> {
  @override
  void initState() {
    super.initState();
    // Marca não lidas como lidas e recarrega após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _markAllRead());
  }

  Future<void> _markAllRead() async {
    final notifications =
        ref.read(notificationsPollerProvider).valueOrNull ?? [];
    final poller = ref.read(notificationsPollerProvider.notifier);
    for (final n in notifications.where((n) => !n.read)) {
      await poller.markRead(n.id);
    }
    // Rebusca a lista completa após marcar como lidas
    ref.invalidate(allNotificationsProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Usa allNotificationsProvider para mostrar TODAS (lidas + não lidas)
    final notificationsState = ref.watch(allNotificationsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Notificações',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: notificationsState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Erro ao carregar notificações',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 48,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhuma notificação',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  itemCount: notifications.length,
                  separatorBuilder: (_, i) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (_, i) =>
                      _NotificationTile(notification: notifications[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        DateFormat('dd/MM HH:mm').format(notification.createdAt.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.directions_car,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight:
              notification.read ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(notification.message),
      trailing: Text(
        timeStr,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
