part of 'trip_bloc.dart';

enum TripStatus { initial, loading, success, failure }

class TripState extends Equatable {
  const TripState({required this.status, required this.trips});

  const TripState.initial() : status = TripStatus.initial, trips = const [];

  final TripStatus status;
  final List<Trip> trips;

  TripState copyWith({TripStatus? status, List<Trip>? trips}) {
    return TripState(status: status ?? this.status, trips: trips ?? this.trips);
  }

  @override
  List<Object?> get props => [status, trips];
}
