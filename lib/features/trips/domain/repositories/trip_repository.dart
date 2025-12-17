import '../entities/trip_entity.dart';

abstract class TripRepository {
  Stream<List<Trip>> watchTrips(String userId);

  Future<void> createTrip(String userId, Trip trip);

  Future<void> updateTrip(String userId, Trip trip);

  Future<void> deleteTrip(String userId, String tripId);
}
