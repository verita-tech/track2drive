import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';

abstract class AutoTrackingRepository {
  Stream<AutoTrackingRule?> watchRule(String userId);

  Future<void> saveRule(String userId, AutoTrackingRule rule);
}
