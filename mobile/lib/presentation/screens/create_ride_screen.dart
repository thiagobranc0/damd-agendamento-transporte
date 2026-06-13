import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/rides_controller.dart';
import '../../application/session_controller.dart';

class CreateRideScreen extends ConsumerStatefulWidget {
  const CreateRideScreen({super.key});

  @override
  ConsumerState<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends ConsumerState<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  DateTime? _scheduledAt;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _originCtrl.dispose();
    _destinationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledAt == null) {
      setState(() => _error = 'Selecione a data e hora.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = await ref.read(sessionControllerProvider.future);
      if (userId == null) {
        if (mounted) context.go('/');
        return;
      }

      final ride = await ref.read(ridesControllerProvider.notifier).createRide(
            userId: userId,
            origin: _originCtrl.text.trim(),
            destination: _destinationCtrl.text.trim(),
            scheduledAt: _scheduledAt!,
          );

      if (mounted) context.pushReplacement('/rides/${ride.id}');
    } catch (_) {
      setState(() => _error = 'Erro ao criar corrida. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _scheduledAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(_scheduledAt!)
        : 'Selecionar data e hora';

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Corrida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _originCtrl,
                decoration: const InputDecoration(
                  labelText: 'Origem',
                  prefixIcon: Icon(Icons.trip_origin, color: Color(0xFF059669)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a origem' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  prefixIcon: Icon(Icons.place, color: Color(0xFFDC2626)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o destino' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today),
                label: Text(dateLabel),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Solicitar corrida'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
