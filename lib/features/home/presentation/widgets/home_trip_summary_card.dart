import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/trips/presentation/bloc/trip_bloc.dart';

class HomeTripSummaryCard extends StatelessWidget {
  const HomeTripSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state.trips.isEmpty) {
          return Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Noch keine Fahrten erfasst',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        final totalTrips = state.trips.length;
        final totalKm = state.trips.fold<double>(
          0,
          (sum, t) => sum + t.distanceKm,
        );

        return Card(
          elevation: 0,
          color: theme.colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatTile(label: 'Fahrten', value: '$totalTrips'),
                      _StatTile(
                        label: 'Kilometer',
                        value: '${totalKm.toStringAsFixed(1)} km',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer.withValues(
              alpha: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
}
