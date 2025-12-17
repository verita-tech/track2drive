import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class UpdateTripUsecase {
  UpdateTripUsecase(this._repository);

  final TripRepository _repository;

  Future<void> call(String userId, Trip trip) {
    return _repository.updateTrip(userId, trip);
  }
}
