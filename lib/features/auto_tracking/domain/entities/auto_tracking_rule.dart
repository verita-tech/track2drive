import 'package:flutter/material.dart';

class AutoTrackingRule {
  final String id;
  final String? bluetoothDeviceId;
  final String? bluetoothDeviceName;

  final Set<int> weekdays;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool enabled;

  const AutoTrackingRule({
    required this.id,
    required this.bluetoothDeviceId,
    required this.bluetoothDeviceName,
    required this.weekdays,
    required this.startTime,
    required this.endTime,
    required this.enabled,
  });

  AutoTrackingRule copyWith({
    String? id,
    String? bluetoothDeviceId,
    String? bluetoothDeviceName,
    Set<int>? weekdays,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? enabled,
  }) {
    return AutoTrackingRule(
      id: id ?? this.id,
      bluetoothDeviceId: bluetoothDeviceId ?? this.bluetoothDeviceId,
      bluetoothDeviceName: bluetoothDeviceName ?? this.bluetoothDeviceName,
      weekdays: weekdays ?? this.weekdays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enabled: enabled ?? this.enabled,
    );
  }

  bool isActiveNow(DateTime now, {required bool bluetoothConnected}) {
    if (!enabled || !bluetoothConnected) return false;
    if (!weekdays.contains(now.weekday)) return false;

    int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
    final minutes = now.hour * 60 + now.minute;
    final start = toMinutes(startTime);
    final end = toMinutes(endTime);

    return minutes >= start && minutes <= end;
  }
}
