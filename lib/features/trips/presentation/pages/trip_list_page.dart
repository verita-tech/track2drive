import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:track2drive/features/trips/domain/entities/trip_entity.dart';
import '../bloc/trip_bloc.dart';
import '../widgets/trip_list_item.dart';
import '../widgets/trip_form.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage>
    with SingleTickerProviderStateMixin {
  int? _filterYear;
  int? _filterMonth;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _filterYear = now.year;
    _filterMonth = now.month;

    _tabController = TabController(length: 13, vsync: this);
    _tabController.index = now.month - 1;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            _filterMonth = null;
            _filterYear = null;
          } else {
            _filterMonth = _tabController.index;
            _filterYear = DateTime.now().year;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _filterLabel {
    if (_filterYear == null && _filterMonth == null) {
      return 'Alle Fahrten';
    }
    if (_filterYear != null && _filterMonth != null) {
      const monthNames = [
        '',
        'Januar',
        'Februar',
        'März',
        'April',
        'Mai',
        'Juni',
        'Juli',
        'August',
        'September',
        'Oktober',
        'November',
        'Dezember',
      ];
      return '${monthNames[_filterMonth!]} $_filterYear';
    }
    return 'Alle Fahrten';
  }

  List<Trip> _getFilteredTrips(TripState state) {
    var trips = state.trips;
    if (_filterYear != null && _filterMonth != null) {
      trips = trips
          .where(
            (t) => t.date.year == _filterYear! && t.date.month == _filterMonth!,
          )
          .toList();
    }
    return trips;
  }

  Future<void> _exportTrips(BuildContext context, TripState state) async {
    final trips = _getFilteredTrips(state);
    if (trips.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keine Fahrten im gewählten Zeitraum')),
        );
      }
      return;
    }

    String fileName;
    if (_filterYear != null && _filterMonth != null) {
      fileName =
          'fahrten_$_filterYear-${_filterMonth!.toString().padLeft(2, '0')}.csv';
    } else {
      fileName = 'fahrten_alle.csv';
    }

    final double totalKm = trips.fold(0.0, (sum, t) => sum + t.distanceKm);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.all_inclusive, size: 18),
                      SizedBox(width: 4),
                      Text('Alle'),
                    ],
                  ),
                ),
                ...List.generate(
                  12,
                  (index) => Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        DateFormat(
                          'MMM',
                          'de_DE',
                        ).format(DateTime(2025, index + 1)),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          BlocBuilder<TripBloc, TripState>(
            builder: (context, state) {
              final filteredTrips = _getFilteredTrips(state);
              final hasTrips = filteredTrips.isNotEmpty;
              return AnimatedScale(
                scale: hasTrips ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: state.status == TripStatus.loading || !hasTrips
                        ? null
                        : () => _exportTrips(context, state),
                  ),
                ),
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zeitraum',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _filterLabel,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fehler beim Laden der Fahrten',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () => context.read<TripBloc>().add(
                            TripSubscriptionRequested(),
                          ),
                          child: const Text('Erneut laden'),
                        ),
                      ],
                    ),
                  );
                }

                final trips = _getFilteredTrips(state);
                if (trips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.drive_eta_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _filterMonth == null
                              ? 'Keine Fahrten vorhanden'
                              : 'Keine Fahrten gefunden',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _filterMonth == null
                              ? 'Erfassen Sie Ihre erste Fahrt'
                              : 'in $_filterLabel',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          icon: const Icon(Icons.add),
                          onPressed: () => _openCreate(context),
                          label: Text(
                            _filterMonth == null
                                ? 'Erste Fahrt erfassen'
                                : 'Fahrt hinzufügen',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: _openFilterDialog,
                          label: const Text('Anderen Monat wählen'),
                        ),
                      ],
                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Neue Fahrt'),
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _openFilterDialog() async {
    final now = DateTime.now();
    int? tempYear = _filterYear ?? now.year;
    int? tempMonth = _filterMonth;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Monat & Jahr wählen',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Monat
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Monat',
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            border: InputBorder.none,
                          ),
                          initialValue: tempMonth,
                          items: [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text(
                                'Alle Monate',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            ...List.generate(12, (i) => i + 1).map(
                              (m) => DropdownMenuItem<int>(
                                value: m,
                                child: Text(
                                  '${DateFormat('MMM', 'de_DE').format(DateTime(2025, m))} (${m.toString().padLeft(2, '0')})',
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() => tempMonth = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Jahr
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Jahr',
                            prefixIcon: Icon(
                              Icons.date_range,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            border: InputBorder.none,
                          ),
                          initialValue: tempYear,
                          items: List.generate(10, (i) => now.year - i)
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text('$y'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() => tempYear = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.close),
                            label: const Text('Abbrechen'),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text('Übernehmen'),
                            onPressed: () {
                              setState(() {
                                _filterYear = tempYear;
                                _filterMonth = tempMonth;
                                final targetIndex = tempMonth == null
                                    ? 0
                                    : tempMonth! - 1;
                                _tabController.animateTo(targetIndex);
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: TripForm(
          onSubmit: (trip) {
            context.read<TripBloc>().add(
              TripSubmitted(trip: trip, isEdit: false),
            );
            Navigator.of(sheetContext).pop();
          },
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
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
      ),
    );
  }
}
