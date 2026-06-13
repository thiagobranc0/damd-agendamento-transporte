import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final String? emptyMessage;
  final bool Function(T)? isEmpty;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.emptyMessage,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                err.toString().replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  emptyMessage ?? 'Nenhum item encontrado.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        return builder(data);
      },
    );
  }
}
