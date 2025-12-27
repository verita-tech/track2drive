import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:track2drive/features/auto_tracking/data/models/auto_tracking_rule_model.dart';

abstract class AutoTrackingRemoteDataSource {
  Stream<AutoTrackingRuleModel?> watchRule(String userId);
  Future<void> saveRule(String userId, AutoTrackingRuleModel model);
}

class AutoTrackingRemoteDataSourceImpl implements AutoTrackingRemoteDataSource {
  AutoTrackingRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('settings');
  }

  @override
  Stream<AutoTrackingRuleModel?> watchRule(String userId) {
    final docRef = _collection(userId).doc('auto_tracking_rule');
    return docRef.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AutoTrackingRuleModel.fromJson(snap.data()!, snap.id);
    });
  }

  @override
  Future<void> saveRule(String userId, AutoTrackingRuleModel model) async {
    final docRef = _collection(userId).doc('auto_tracking_rule');
    await docRef.set(model.toJson(), SetOptions(merge: true));
  }
}
