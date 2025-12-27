import 'package:equatable/equatable.dart';
import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';

abstract class AutoTrackingEvent extends Equatable {
  const AutoTrackingEvent();

  @override
  List<Object?> get props => [];
}

class AutoTrackingSubscribeEvent extends AutoTrackingEvent {
  final String userId;

  const AutoTrackingSubscribeEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AutoTrackingSaveRuleEvent extends AutoTrackingEvent {
  final String userId;
  final AutoTrackingRule rule;

  const AutoTrackingSaveRuleEvent({required this.userId, required this.rule});

  @override
  List<Object?> get props => [userId, rule];
}
