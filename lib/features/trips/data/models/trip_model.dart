import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final DateTime date;
  final String start;
  final String destination;
  final double distanceKm;
  final String purpose;
  final String? vehicleId;
  final String? costCenterId;

  const TripModel({
    required this.id,
    required this.date,
    required this.start,
    required this.destination,
    required this.distanceKm,
    required this.purpose,
    this.vehicleId,
    this.costCenterId,
  });

  factory TripModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TripModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      start: data['start'] as String,
      destination: data['destination'] as String,
      distanceKm: (data['distanceKm'] as num).toDouble(),
      purpose: data['purpose'] as String,
      vehicleId: data['vehicleId'] as String?,
      costCenterId: data['costCenterId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'start': start,
      'destination': destination,
      'distanceKm': distanceKm,
      'purpose': purpose,
      'vehicleId': vehicleId,
      'costCenterId': costCenterId,
    };
  }

  TripModel copyWith({
    String? id,
    DateTime? date,
    String? start,
    String? destination,
    double? distanceKm,
    String? purpose,
    String? vehicleId,
    String? costCenterId,
  }) {
    return TripModel(
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
