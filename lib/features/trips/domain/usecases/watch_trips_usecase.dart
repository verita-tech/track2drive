import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class WatchTripsUsecase {
  WatchTripsUsecase(this._repository);

  final TripRepository _repository;

  Stream<List<Trip>> call(String userId) {
    return _repository.watchTrips(userId);
  }
}
