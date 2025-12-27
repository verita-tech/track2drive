import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/auto_tracking/domain/usecases/watch_auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/domain/usecases/save_auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_bloc.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_event.dart';
import 'package:track2drive/features/auto_tracking/presentation/pages/auto_tracking_settings_page.dart';

class SettingsPage extends StatefulWidget {
  final String userId;
  const SettingsPage({super.key, required this.userId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_mode, color: Colors.blue),
            title: const Text('Automatisches Tracking'),
            subtitle: const Text('Bluetooth-Gerät + Zeitfenster'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToAutoTracking(context),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Profil'),
            subtitle: Text('E-Mail: ${widget.userId}'),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  void _navigateToAutoTracking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => AutoTrackingBloc(
            watchRule: context.read<WatchAutoTrackingRule>(),
            saveRule: context.read<SaveAutoTrackingRule>(),
          )..add(AutoTrackingSubscribeEvent(widget.userId)),
          child: const AutoTrackingSettingsPage(),
        ),
      ),
    );
  }
}
