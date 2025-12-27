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
              _buildSwitchCard(_isEnabled),
              if (_isEnabled) ...[
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

  Widget _buildSwitchCard(bool isEnabled) {
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
              _isEnabled
                  ? 'Fahrtenbuch wird automatisch gestartet, wenn dein Bluetooth-Gerät verbunden ist'
                  : 'Deaktiviert',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
