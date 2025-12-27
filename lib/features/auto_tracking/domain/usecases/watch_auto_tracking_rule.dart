import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/domain/repositories/auto_tracking_repository.dart';

class WatchAutoTrackingRule {
  final AutoTrackingRepository _repository;

  WatchAutoTrackingRule(this._repository);

  Stream<AutoTrackingRule?> call(String userId) {
    return _repository.watchRule(userId);
  }
}
