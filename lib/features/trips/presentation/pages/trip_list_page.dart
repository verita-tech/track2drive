import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/trips/domain/entities/trip_entity.dart';

import '../bloc/trip_bloc.dart';
import '../widgets/trip_list_item.dart';
import '../widgets/trip_form.dart';

class TripListPage extends StatelessWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fahrten')),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state.status == TripStatus.loading ||
              state.status == TripStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TripStatus.failure) {
            return const Center(child: Text('Fehler beim Laden der Fahrten'));
          }

          if (state.trips.isEmpty) {
            return const Center(child: Text('Noch keine Fahrten erfasst'));
          }

          return ListView.builder(
            itemCount: state.trips.length,
            itemBuilder: (context, index) {
              final trip = state.trips[index];
              return TripListItem(
                trip: trip,
                onTap: () => _openEdit(context, trip),
                onDelete: () =>
                    context.read<TripBloc>().add(TripDeleted(trip.id)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return TripForm(
          onSubmit: (trip) {
            context.read<TripBloc>().add(
              TripSubmitted(trip: trip.copyWith(id: ''), isEdit: false),
            );
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _openEdit(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return TripForm(
          initialTrip: trip,
          onSubmit: (updated) {
            context.read<TripBloc>().add(
              TripSubmitted(trip: updated, isEdit: true),
            );
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
