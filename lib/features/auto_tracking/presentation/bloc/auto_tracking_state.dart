import 'package:equatable/equatable.dart';
import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';

enum AutoTrackingStatus { initial, loading, success, failure }

class AutoTrackingState extends Equatable {
  final AutoTrackingStatus status;
  final AutoTrackingRule? rule;
  final String? errorMessage;

  const AutoTrackingState({
    required this.status,
    required this.rule,
    this.errorMessage,
  });

  const AutoTrackingState.initial()
    : status = AutoTrackingStatus.initial,
      rule = null,
      errorMessage = null;

  AutoTrackingState copyWith({
    AutoTrackingStatus? status,
    AutoTrackingRule? rule,
    String? errorMessage,
  }) {
    return AutoTrackingState(
      status: status ?? this.status,
      rule: rule ?? this.rule,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, rule, errorMessage];
}
