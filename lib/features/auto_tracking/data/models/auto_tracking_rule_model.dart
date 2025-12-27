import 'package:flutter/material.dart';
import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';

class AutoTrackingRuleModel {
  final String id;
  final String? bluetoothDeviceId;
  final String? bluetoothDeviceName;
  final List<int> weekdays;
  final int startMinutes;
  final int endMinutes;
  final bool enabled;

  AutoTrackingRuleModel({
    required this.id,
    required this.bluetoothDeviceId,
    required this.bluetoothDeviceName,
    required this.weekdays,
    required this.startMinutes,
    required this.endMinutes,
    required this.enabled,
  });

  factory AutoTrackingRuleModel.fromJson(Map<String, dynamic> json, String id) {
    return AutoTrackingRuleModel(
      id: id,
      bluetoothDeviceId: json['bluetoothDeviceId'] as String?,
      bluetoothDeviceName: json['bluetoothDeviceName'] as String?,
      weekdays: List<int>.from(json['weekdays'] ?? const <int>[]),
      startMinutes: json['startMinutes'] as int? ?? 8 * 60,
      endMinutes: json['endMinutes'] as int? ?? 18 * 60,
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bluetoothDeviceId': bluetoothDeviceId,
      'bluetoothDeviceName': bluetoothDeviceName,
      'weekdays': weekdays,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'enabled': enabled,
    };
  }

  AutoTrackingRule toEntity() {
    TimeOfDay fromMinutes(int m) => TimeOfDay(hour: m ~/ 60, minute: m % 60);

    return AutoTrackingRule(
      id: id,
      bluetoothDeviceId: bluetoothDeviceId,
      bluetoothDeviceName: bluetoothDeviceName,
      weekdays: weekdays.toSet(),
      startTime: fromMinutes(startMinutes),
      endTime: fromMinutes(endMinutes),
      enabled: enabled,
    );
  }

  static AutoTrackingRuleModel fromEntity(AutoTrackingRule e) {
    int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

    return AutoTrackingRuleModel(
      id: e.id,
      bluetoothDeviceId: e.bluetoothDeviceId,
      bluetoothDeviceName: e.bluetoothDeviceName,
      weekdays: e.weekdays.toList(),
      startMinutes: toMinutes(e.startTime),
      endMinutes: toMinutes(e.endTime),
      enabled: e.enabled,
    );
  }
}
