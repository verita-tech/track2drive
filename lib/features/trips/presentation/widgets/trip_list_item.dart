import 'package:flutter/material.dart';
import 'package:track2drive/features/trips/domain/entities/trip_entity.dart';

class TripListItem extends StatelessWidget {
  const TripListItem({
    super.key,
    required this.trip,
    this.onTap,
    this.onDelete,
  });

  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateString = '${trip.date.day}.${trip.date.month}.${trip.date.year}';

    return ListTile(
      title: Text('${trip.start} → ${trip.destination}'),
      subtitle: Text('$dateString • ${trip.distanceKm.toStringAsFixed(1)} km'),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        color: theme.colorScheme.error,
        onPressed: onDelete,
      ),
    );
  }
}
