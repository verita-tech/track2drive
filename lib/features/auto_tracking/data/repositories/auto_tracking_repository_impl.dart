import 'package:track2drive/features/auto_tracking/data/datasources/auto_tracking_remote_datasource.dart';
import 'package:track2drive/features/auto_tracking/data/models/auto_tracking_rule_model.dart';
import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/domain/repositories/auto_tracking_repository.dart';

class AutoTrackingRepositoryImpl implements AutoTrackingRepository {
  AutoTrackingRepositoryImpl(this._remoteDataSource);

  final AutoTrackingRemoteDataSource _remoteDataSource;

  @override
  Stream<AutoTrackingRule?> watchRule(String userId) {
    return _remoteDataSource
        .watchRule(userId)
        .map((model) => model?.toEntity());
  }

  @override
  Future<void> saveRule(String userId, AutoTrackingRule rule) async {
    final model = AutoTrackingRuleModel.fromEntity(rule);
    await _remoteDataSource.saveRule(userId, model);
  }
}
