import '../repositories/trip_repository.dart';

class DeleteTripUsecase {
  DeleteTripUsecase(this._repository);

  final TripRepository _repository;

  Future<void> call(String userId, String tripId) {
    return _repository.deleteTrip(userId, tripId);
  }
}
