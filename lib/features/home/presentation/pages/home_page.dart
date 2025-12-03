import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final email = state.user?.email ?? 'Unbekannt';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track2Drive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            }, // Triggert Logout über BLoC.[web:14][web:109]
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Angemeldet als: $email'),
            const SizedBox(height: 16),
            const Text('Willkommen bei Track2Drive!'),
          ],
        ),
      ),
    );
  }
}
