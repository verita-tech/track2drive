import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/auth/domain/entities/user_entity.dart';
import 'package:track2drive/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:track2drive/features/home/presentation/widgets/home_header.dart';
import 'package:track2drive/features/home/presentation/widgets/home_recent_trips.dart';
import 'package:track2drive/features/home/presentation/widgets/home_trip_summary_card.dart';
import 'package:track2drive/features/trips/presentation/bloc/trip_bloc.dart';
import 'package:track2drive/features/trips/presentation/pages/trip_list_page.dart';

import 'package:track2drive/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:track2drive/features/trips/domain/usecases/update_trip_usecase.dart';
import 'package:track2drive/features/trips/domain/usecases/delete_trip_usecase.dart';
import 'package:track2drive/features/trips/domain/usecases/watch_trips_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});
  final UserEntity user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final email = widget.user.email;

    return BlocProvider(
      create: (context) => TripBloc(
        userId: widget.user.id,
        watchTrips: context.read<WatchTripsUsecase>(),
        createTrip: context.read<CreateTripUsecase>(),
        updateTrip: context.read<UpdateTripUsecase>(),
        deleteTrip: context.read<DeleteTripUsecase>(),
      )..add(const TripSubscriptionRequested()),
      child: _HomeScaffold(email: email),
    );
  }
}

class _HomeScaffold extends StatefulWidget {
  const _HomeScaffold({required this.email});
  final String email;

  @override
  State<_HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<_HomeScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeDashboard(
        // ohne Unterstrich, siehe Klasse unten
        email: widget.email,
        onShowAllTrips: () {
          setState(() => _selectedIndex = 1);
        },
      ),
      const TripListPage(),
      const Center(child: Text('Kostenstellenverwaltung (coming soon)')),
      const Center(child: Text('Fahrzeugverwaltung (coming soon)')),
      const Center(child: Text('Einstellungen (coming soon)')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track2Drive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Fahrten',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree),
            label: 'Kosten',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus_outlined),
            selectedIcon: Icon(Icons.directions_bus),
            label: 'Fahrzeuge',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.email,
    required this.onShowAllTrips,
  });

  final String email;
  final VoidCallback onShowAllTrips;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(email: email),
          const SizedBox(height: 16),
          const HomeTripSummaryCard(),
          const SizedBox(height: 24),
          Expanded(child: HomeRecentTrips(onShowAll: onShowAllTrips)),
        ],
      ),
    );
  }
}
