import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:track2drive/features/trips/domain/entities/trip_entity.dart';

class TripListItem extends StatelessWidget {
  const TripListItem({
    super.key,
    required this.trip,
    this.onEdit,
    this.onDelete,
  });

  final Trip trip;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateString = '${trip.date.day}.${trip.date.month}.${trip.date.year}';

    return Slidable(
      key: ValueKey(trip.id),

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Bearbeiten',
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Löschen',
          ),
        ],
      ),

      child: ListTile(
        title: Text('${trip.start} → ${trip.destination}'),
        subtitle: Text(
          '$dateString • ${trip.distanceKm.toStringAsFixed(1)} km',
        ),
      ),
    );
  }
}
