import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/trips/presentation/bloc/trip_bloc.dart';
import 'package:track2drive/features/trips/presentation/widgets/trip_list_item.dart';

class HomeRecentTrips extends StatelessWidget {
  const HomeRecentTrips({super.key, required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Letzte Fahrten', style: theme.textTheme.titleMedium),
            TextButton(
              onPressed: onShowAll,
              child: const Text('Alle anzeigen'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<TripBloc, TripState>(
            builder: (context, state) {
              if (state.status == TripStatus.loading ||
                  state.status == TripStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.trips.isEmpty) {
                return const Center(child: Text('Noch keine Fahrten erfasst'));
              }

              final lastTrips = state.trips.take(3).toList();

              return ListView.separated(
                itemCount: lastTrips.length,
                separatorBuilder: (_, _) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final trip = lastTrips[index];
                  return TripListItem(trip: trip);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
