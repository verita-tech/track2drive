import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_firestore_datasource.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(this._datasource);

  final TripFirestoreDatasource _datasource;

  @override
  Stream<List<Trip>> watchTrips(String userId) {
    return _datasource
        .watchTrips(userId)
        .map(
          (models) => models
              .map(
                (m) => Trip(
                  id: m.id,
                  date: m.date,
                  start: m.start,
                  destination: m.destination,
                  distanceKm: m.distanceKm,
                  purpose: m.purpose,
                  vehicleId: m.vehicleId,
                  costCenterId: m.costCenterId,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> createTrip(String userId, Trip trip) {
    final model = TripModel(
      id: trip.id,
      date: trip.date,
      start: trip.start,
      destination: trip.destination,
      distanceKm: trip.distanceKm,
      purpose: trip.purpose,
      vehicleId: trip.vehicleId,
      costCenterId: trip.costCenterId,
    );
    return _datasource.createTrip(userId, model);
  }

  @override
  Future<void> updateTrip(String userId, Trip trip) {
    final model = TripModel(
      id: trip.id,
      date: trip.date,
      start: trip.start,
      destination: trip.destination,
      distanceKm: trip.distanceKm,
      purpose: trip.purpose,
      vehicleId: trip.vehicleId,
      costCenterId: trip.costCenterId,
    );
    return _datasource.updateTrip(userId, model);
  }

  @override
  Future<void> deleteTrip(String userId, String tripId) {
    return _datasource.deleteTrip(userId, tripId);
  }
}
