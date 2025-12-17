part of 'trip_bloc.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class TripSubscriptionRequested extends TripEvent {
  const TripSubscriptionRequested();
}

class TripSubmitted extends TripEvent {
  const TripSubmitted({required this.trip, this.isEdit = false});

  final Trip trip;
  final bool isEdit;

  @override
  List<Object?> get props => [trip, isEdit];
}

class TripDeleted extends TripEvent {
  const TripDeleted(this.tripId);

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}
