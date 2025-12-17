import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:track2drive/features/trips/domain/entities/trip_entity.dart';

import '../bloc/trip_bloc.dart';
import '../widgets/trip_list_item.dart';
import '../widgets/trip_form.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  DateTimeRange? _range;
  int? _filterYear;
  int? _filterMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _filterYear = now.year;
    _filterMonth = now.month;
  }

  String get _filterLabel {
    if (_range != null) {
      final s = _range!.start;
      final e = _range!.end;
      return '${s.day}.${s.month}.${s.year} – ${e.day}.${e.month}.${e.year}';
    }
    if (_filterYear != null && _filterMonth != null) {
      return '${_filterMonth!.toString().padLeft(2, '0')}.$_filterYear';
    }
    return 'Alle Fahrten';
  }

  List<Trip> _getFilteredTrips(TripState state) {
    var trips = state.trips;

    if (_filterYear != null && _filterMonth != null && _range == null) {
      trips = trips
          .where(
            (t) => t.date.year == _filterYear && t.date.month == _filterMonth,
          )
          .toList();
    }

    if (_range != null) {
      final start = DateTime(
        _range!.start.year,
        _range!.start.month,
        _range!.start.day,
      );
      final end = DateTime(
        _range!.end.year,
        _range!.end.month,
        _range!.end.day,
        23,
        59,
      );

      trips = trips
          .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
          .toList();
    }

    return trips;
  }

  Future<void> _exportTrips(BuildContext context, TripState state) async {
    final trips = _getFilteredTrips(state);
    if (trips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Fahrten im gewählten Zeitraum')),
      );
      return;
    }

    String fileName;
    if (_range != null) {
      final s = _range!.start;
      final e = _range!.end;
      fileName =
          'fahrten_${s.year}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}_'
          '${e.year}-${e.month.toString().padLeft(2, '0')}-${e.day.toString().padLeft(2, '0')}.csv';
    } else if (_filterYear != null && _filterMonth != null) {
      fileName =
          'fahrten_$_filterYear-${_filterMonth!.toString().padLeft(2, '0')}.csv';
    } else {
      fileName = 'fahrten_alle.csv';
    }

    final double totalKm = trips.fold<double>(
      0,
      (sum, t) => sum + t.distanceKm,
    );

    final buffer = StringBuffer();
    buffer.writeln('Datum;Kilometer;Ziel/Begründung');
    for (final t in trips) {
      buffer.writeln(
        '${t.date.toIso8601String()};'
        '${t.distanceKm.toStringAsFixed(1)};'
        '${t.destination} ${t.purpose}',
      );
    }

    buffer.writeln();
    buffer.writeln('Summe;${totalKm.toStringAsFixed(1)};');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(buffer.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, name: fileName)],
        subject: 'Fahrtenexport',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fahrten'),
        actions: [
          BlocBuilder<TripBloc, TripState>(
            builder: (context, state) {
              final disabled =
                  state.status == TripStatus.loading || state.trips.isEmpty;
              return IconButton(
                icon: const Icon(Icons.ios_share),
                tooltip: 'Exportieren',
                onPressed: disabled ? null : () => _exportTrips(context, state),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            child: InkWell(
              onTap: _openFilterDialog,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _filterLabel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TripBloc, TripState>(
              builder: (context, state) {
                if (state.status == TripStatus.loading ||
                    state.status == TripStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == TripStatus.failure) {
                  return const Center(
                    child: Text('Fehler beim Laden der Fahrten'),
                  );
                }

                final trips = _getFilteredTrips(state);

                if (trips.isEmpty) {
                  return const Center(
                    child: Text('Keine Fahrten im gewählten Zeitraum'),
                  );
                }

                return ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return TripListItem(
                      trip: trip,
                      onEdit: () => _openEdit(context, trip),
                      onDelete: () =>
                          context.read<TripBloc>().add(TripDeleted(trip.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openFilterDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        int? tempYear = _filterYear;
        int? tempMonth = _filterMonth;
        DateTimeRange? tempRange = _range;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fahrten filtern',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      DropdownButton<int>(
                        hint: const Text('Monat'),
                        value: tempMonth,
                        items: List.generate(12, (i) => i + 1)
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.toString().padLeft(2, '0')),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setModalState(() => tempMonth = value);
                          setModalState(() => tempRange = null);
                        },
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        hint: const Text('Jahr'),
                        value: tempYear,
                        items: List.generate(5, (i) => DateTime.now().year - i)
                            .map(
                              (y) =>
                                  DropdownMenuItem(value: y, child: Text('$y')),
                            )
                            .toList(),
                        onChanged: (value) {
                          setModalState(() => tempYear = value);
                          setModalState(() => tempRange = null);
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Monat/Jahr löschen',
                        onPressed: () {
                          setModalState(() {
                            tempMonth = null;
                            tempYear = null;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          tempRange == null
                              ? 'Von/Bis wählen'
                              : '${tempRange!.start.day}.${tempRange!.start.month}.${tempRange!.start.year}'
                                    ' – ${tempRange!.end.day}.${tempRange!.end.month}.${tempRange!.end.year}',
                        ),
                        onPressed: () async {
                          final result = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020, 1, 1),
                            lastDate: DateTime(2100, 12, 31),
                            initialDateRange: tempRange,
                          );
                          if (result != null) {
                            setModalState(() => tempRange = result);
                            setModalState(() {
                              tempMonth = null;
                              tempYear = null;
                            });
                          }
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Von/Bis löschen',
                        onPressed: () {
                          setModalState(() => tempRange = null);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Abbrechen'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _filterYear = tempYear;
                            _filterMonth = tempMonth;
                            _range = tempRange;
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Übernehmen'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _openCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: TripForm(
            onSubmit: (trip) {
              context.read<TripBloc>().add(
                TripSubmitted(trip: trip, isEdit: false),
              );
              Navigator.of(sheetContext).pop();
            },
          ),
        );
      },
    );
  }

  void _openEdit(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: TripForm(
            initialTrip: trip,
            onSubmit: (updated) {
              context.read<TripBloc>().add(
                TripSubmitted(trip: updated, isEdit: true),
              );
              Navigator.of(sheetContext).pop();
            },
          ),
        );
      },
    );
  }
}
