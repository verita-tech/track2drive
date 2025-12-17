import 'package:flutter/material.dart';
import 'package:track2drive/features/trips/domain/entities/trip_entity.dart';

class TripForm extends StatefulWidget {
  const TripForm({super.key, this.initialTrip, required this.onSubmit});

  final Trip? initialTrip;
  final void Function(Trip trip) onSubmit;

  @override
  State<TripForm> createState() => _TripFormState();
}

class _TripFormState extends State<TripForm> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  final _startCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final t = widget.initialTrip;
    _date = t?.date ?? DateTime.now();
    _startCtrl.text = t?.start ?? '';
    _destCtrl.text = t?.destination ?? '';
    _kmCtrl.text = t?.distanceKm.toString() ?? '';
    _purposeCtrl.text = t?.purpose ?? '';
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _destCtrl.dispose();
    _kmCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final km = double.tryParse(_kmCtrl.text) ?? 0;

    final trip = Trip(
      id: widget.initialTrip?.id ?? '',
      date: _date,
      start: _startCtrl.text.trim(),
      destination: _destCtrl.text.trim(),
      distanceKm: km,
      purpose: _purposeCtrl.text.trim(),
      vehicleId: widget.initialTrip?.vehicleId,
      costCenterId: widget.initialTrip?.costCenterId,
    );

    widget.onSubmit(trip);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '${_date.day}.${_date.month}.${_date.year}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _pickDate,
                  child: const Text('Datum wählen'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _startCtrl,
              decoration: const InputDecoration(labelText: 'Start'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Pflichtfeld' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _destCtrl,
              decoration: const InputDecoration(labelText: 'Ziel'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Pflichtfeld' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _kmCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kilometer'),
              validator: (value) {
                final v = double.tryParse(value ?? '');
                if (v == null || v <= 0) {
                  return 'Bitte gültige Kilometerzahl eingeben';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _purposeCtrl,
              decoration: const InputDecoration(labelText: 'Zweck'),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Speichern')),
          ],
        ),
      ),
    );
  }
}
