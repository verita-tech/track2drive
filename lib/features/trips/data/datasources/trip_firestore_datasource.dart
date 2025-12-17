import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

abstract class TripFirestoreDatasource {
  Stream<List<TripModel>> watchTrips(String userId);
  Future<void> createTrip(String userId, TripModel trip);
  Future<void> updateTrip(String userId, TripModel trip);
  Future<void> deleteTrip(String userId, String tripId);
}

class TripFirestoreDatasourceImpl implements TripFirestoreDatasource {
  TripFirestoreDatasourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tripsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('trips');
  }

  @override
  Stream<List<TripModel>> watchTrips(String userId) {
    return _tripsRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TripModel.fromDoc).toList());
  }

  @override
  Future<void> createTrip(String userId, TripModel trip) async {
    await _tripsRef(userId).add(trip.toMap());
  }

  @override
  Future<void> updateTrip(String userId, TripModel trip) async {
    await _tripsRef(userId).doc(trip.id).update(trip.toMap());
  }

  @override
  Future<void> deleteTrip(String userId, String tripId) async {
    await _tripsRef(userId).doc(tripId).delete();
  }
}
