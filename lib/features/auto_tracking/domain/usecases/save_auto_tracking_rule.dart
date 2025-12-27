import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/domain/repositories/auto_tracking_repository.dart';

class SaveAutoTrackingRule {
  final AutoTrackingRepository _repository;

  SaveAutoTrackingRule(this._repository);

  Future<void> call(String userId, AutoTrackingRule rule) {
    return _repository.saveRule(userId, rule);
  }
}
