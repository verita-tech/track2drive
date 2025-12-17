class Trip {
  final String id;
  final DateTime date;
  final String start;
  final String destination;
  final double distanceKm;
  final String purpose;
  final String? vehicleId;
  final String? costCenterId;

  const Trip({
    required this.id,
    required this.date,
    required this.start,
    required this.destination,
    required this.distanceKm,
    required this.purpose,
    this.vehicleId,
    this.costCenterId,
  });

  Trip copyWith({
    String? id,
    DateTime? date,
    String? start,
    String? destination,
    double? distanceKm,
    String? purpose,
    String? vehicleId,
    String? costCenterId,
  }) {
    return Trip(
      id: id ?? this.id,
      date: date ?? this.date,
      start: start ?? this.start,
      destination: destination ?? this.destination,
      distanceKm: distanceKm ?? this.distanceKm,
      purpose: purpose ?? this.purpose,
      vehicleId: vehicleId ?? this.vehicleId,
      costCenterId: costCenterId ?? this.costCenterId,
    );
  }
}
