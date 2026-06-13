import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/rides_controller.dart';
import '../../application/notifications_poller.dart';
import '../../application/session_controller.dart';
import '../widgets/ride_card.dart';
import '../widgets/async_value_view.dart';
import '../widgets/notifications_bottom_sheet.dart';

class RidesListScreen extends ConsumerWidget {
  const RidesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesState = ref.watch(ridesControllerProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final session = ref.watch(sessionControllerProvider);

    // Quando chega notificação nova, rebusca a lista de corridas automaticamente
    ref.listen<int>(unreadCountProvider, (previous, next) {
      if (next > (previous ?? 0)) {
        ref.read(ridesControllerProvider.notifier).refresh();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Corridas'),
        actions: [
          IconButton(
            tooltip: 'Notificações',
            onPressed: () => showNotificationsBottomSheet(context),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications),
                if (unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await ref.read(sessionControllerProvider.notifier).clearSession();
              if (context.mounted) context.go('/'); // ignore: use_build_context_synchronously
            },
          ),
        ],
      ),
      body: session.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Erro ao carregar sessão')),
        data: (userId) => RefreshIndicator(
          onRefresh: () => ref.read(ridesControllerProvider.notifier).refresh(),
          child: AsyncValueView(
            value: ridesState,
            emptyMessage: 'Você ainda não tem corridas.',
            isEmpty: (list) => list.isEmpty,
            builder: (rides) => ListView.builder(
              itemCount: rides.length,
              itemBuilder: (_, i) => RideCard(
                ride: rides[i],
                onTap: () async {
                  await context.push('/rides/${rides[i].id}');
                  ref.read(ridesControllerProvider.notifier).refresh();
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/rides/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nova corrida'),
      ),
    );
  }
}
