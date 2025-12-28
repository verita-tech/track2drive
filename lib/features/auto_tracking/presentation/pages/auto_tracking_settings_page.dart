import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_bloc.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_event.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_state.dart';
import 'package:track2drive/features/auto_tracking/presentation/widgets/bluetooth_device_selector.dart';
import 'package:track2drive/features/auto_tracking/presentation/widgets/time_range_picker.dart';
import 'package:track2drive/features/auto_tracking/presentation/widgets/weekday_selector.dart';

class AutoTrackingSettingsPage extends StatefulWidget {
  const AutoTrackingSettingsPage({super.key});

  @override
  State<AutoTrackingSettingsPage> createState() =>
      _AutoTrackingSettingsPageState();
}

class _AutoTrackingSettingsPageState extends State<AutoTrackingSettingsPage> {
  AutoTrackingRule? _editingRule;
  bool _isEnabled = false;
  bool _bluetoothMode = false;

  AutoTrackingRule _defaultRule() => AutoTrackingRule(
    id: 'default',
    bluetoothDeviceId: null,
    bluetoothDeviceName: null,
    weekdays: {
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    },
    startTime: const TimeOfDay(hour: 8, minute: 0),
    endTime: const TimeOfDay(hour: 18, minute: 0),
    enabled: false,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AutoTrackingBloc, AutoTrackingState>(
      listener: (context, state) {
        if (state.rule != null) {
          setState(() {
            _editingRule = state.rule;
            _isEnabled = state.rule!.enabled;
            _bluetoothMode = state.rule!.bluetoothDeviceId != null;
          });
        }
        if (state.status == AutoTrackingStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Einstellungen gespeichert')),
          );
        } else if (state.status == AutoTrackingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: ${state.errorMessage}')),
          );
        }
      },
      builder: (context, state) {
        final rule = _editingRule ?? state.rule ?? _defaultRule();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Automatisches Tracking'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSwitchCard(_isEnabled, rule),
              if (_isEnabled) ...[
                const SizedBox(height: 16),
                _buildTriggerModeSelector(rule),
                if (!_bluetoothMode) ...[
                  const SizedBox(height: 16),
                  WeekdaySelector(
                    selectedWeekdays: rule.weekdays,
                    onWeekdaysChanged: (weekdays) {
                      setState(() {
                        _editingRule = rule.copyWith(weekdays: weekdays);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TimeRangePicker(
                    startTime: rule.startTime,
                    endTime: rule.endTime,
                    onStartTimeChanged: (time) {
                      setState(() {
                        _editingRule = rule.copyWith(startTime: time);
                      });
                    },
                    onEndTimeChanged: (time) {
                      setState(() {
                        _editingRule = rule.copyWith(endTime: time);
                      });
                    },
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  BluetoothDeviceSelector(
                    currentDeviceId: rule.bluetoothDeviceId,
                    currentDeviceName: rule.bluetoothDeviceName,
                    onDeviceSelected: (deviceId, deviceName) {
                      setState(() {
                        _editingRule = rule.copyWith(
                          bluetoothDeviceId: deviceId,
                          bluetoothDeviceName: deviceName,
                        );
                      });
                    },
                  ),
                ],
              ],
            ],
          ),
          floatingActionButton: _isEnabled
              ? FloatingActionButton.extended(
                  onPressed: () {
                    final userId = FirebaseAuth.instance.currentUser!.uid;
                    context.read<AutoTrackingBloc>().add(
                      AutoTrackingSaveRuleEvent(
                        userId: userId,
                        rule: _editingRule ?? rule,
                      ),
                    );
                  },
                  label: const Text('Speichern'),
                  icon: const Icon(Icons.save),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSwitchCard(bool isEnabled, AutoTrackingRule rule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Automatisches Tracking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() => _isEnabled = value);
                    _editingRule = _defaultRule().copyWith(enabled: value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isEnabled ? _getTriggerDescription(rule) : 'Deaktiviert',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerModeSelector(AutoTrackingRule rule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trigger-Modus',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TriggerModeChip(
                    label: 'Zeit + Bewegung',
                    icon: Icons.schedule,
                    isSelected: !_bluetoothMode,
                    description: 'Mo-Fr 08-18 + Auto-Geschwindigkeit',
                    onSelected: () => _switchToTimeMode(rule),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TriggerModeChip(
                    label: 'Bluetooth-Gerät',
                    icon: Icons.bluetooth,
                    isSelected: _bluetoothMode,
                    description: rule.bluetoothDeviceId != null
                        ? '${rule.bluetoothDeviceName ?? 'Gerät'} verbunden'
                        : 'Gerät auswählen',
                    onSelected: () => _switchToBluetoothMode(rule),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _switchToTimeMode(AutoTrackingRule rule) {
    setState(() {
      _bluetoothMode = false;
      _editingRule = rule.copyWith(
        bluetoothDeviceId: null,
        bluetoothDeviceName: null,
        weekdays: {
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        },
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      );
    });
  }

  void _switchToBluetoothMode(AutoTrackingRule rule) {
    setState(() {
      _bluetoothMode = true;
      _editingRule = rule.copyWith(
        weekdays: {},
        startTime: const TimeOfDay(hour: 0, minute: 0),
        endTime: const TimeOfDay(hour: 23, minute: 59),
      );
    });
  }

  String _getTriggerDescription(AutoTrackingRule rule) {
    if (rule.bluetoothDeviceId != null) {
      return 'Fährt automatisch bei ${rule.bluetoothDeviceName ?? 'Bluetooth-Gerät'} Verbindung';
    } else {
      return 'Fährt Mo-Fr ${rule.startTime.format(context)}-${rule.endTime.format(context)} bei Auto-Geschwindigkeit';
    }
  }
}

class _TriggerModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final String description;
  final VoidCallback onSelected;

  const _TriggerModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.description,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? null : Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? null : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? null : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
