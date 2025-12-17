import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/trips/domain/entities/trip_entity.dart';
import 'package:track2drive/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:track2drive/features/trips/domain/usecases/delete_trip_usecase.dart';
import 'package:track2drive/features/trips/domain/usecases/update_trip_usecase.dart';
import 'package:track2drive/features/trips/domain/usecases/watch_trips_usecase.dart';

part 'trip_event.dart';
part 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc({
    required this.userId,
    required WatchTripsUsecase watchTrips,
    required CreateTripUsecase createTrip,
    required UpdateTripUsecase updateTrip,
    required DeleteTripUsecase deleteTrip,
  }) : _watchTrips = watchTrips,
       _createTrip = createTrip,
       _updateTrip = updateTrip,
       _deleteTrip = deleteTrip,
       super(const TripState.initial()) {
    on<TripSubscriptionRequested>(_onSubscriptionRequested);
    on<TripSubmitted>(_onSubmitted);
    on<TripDeleted>(_onDeleted);
  }

  final String userId;
  final WatchTripsUsecase _watchTrips;
  final CreateTripUsecase _createTrip;
  final UpdateTripUsecase _updateTrip;
  final DeleteTripUsecase _deleteTrip;

  Future<void> _onSubscriptionRequested(
    TripSubscriptionRequested event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripStatus.loading));

    await emit.forEach<List<Trip>>(
      _watchTrips(userId),
      onData: (trips) =>
          state.copyWith(status: TripStatus.success, trips: trips),
      onError: (_, _) => state.copyWith(status: TripStatus.failure),
    );
  }

  Future<void> _onSubmitted(
    TripSubmitted event,
    Emitter<TripState> emit,
  ) async {
    try {
      if (event.isEdit) {
        await _updateTrip(userId, event.trip);
      } else {
        await _createTrip(userId, event.trip);
      }
    } catch (_) {
      emit(state.copyWith(status: TripStatus.failure));
    }
  }

  Future<void> _onDeleted(TripDeleted event, Emitter<TripState> emit) async {
    try {
      await _deleteTrip(userId, event.tripId);
    } catch (_) {
      emit(state.copyWith(status: TripStatus.failure));
    }
  }
}
