import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options_dev.dart' as dev;

enum AppEnv { dev, staging, prod }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final firebaseOptions = _getFirebaseOptions(flavor);
  await Firebase.initializeApp(options: firebaseOptions);

  runApp(MainApp(flavor: flavor));
}

class MainApp extends StatelessWidget {
  final String flavor;

  const MainApp({super.key, required this.flavor});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track2Drive $flavor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Track2Drive [$flavor]'),
          backgroundColor: _getFlavorColor(flavor),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello World!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Environment: $flavor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Firebase Project: ${_getFirebaseProjectName(flavor)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

FirebaseOptions _getFirebaseOptions(String flavor) {
  switch (flavor) {
    case 'dev':
      return dev.DefaultFirebaseOptions.currentPlatform;
    case 'staging':
      return dev.DefaultFirebaseOptions.currentPlatform;
    case 'prod':
      return dev.DefaultFirebaseOptions.currentPlatform;
    default:
      if (kDebugMode) {
        return dev.DefaultFirebaseOptions.currentPlatform;
      }
      throw UnimplementedError('No FirebaseOptions for flavor: $flavor');
  }
}

Color _getFlavorColor(String flavor) {
  switch (flavor) {
    case 'dev':
      return Colors.blue;
    case 'staging':
      return Colors.orange;
    case 'prod':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

String _getFirebaseProjectName(String flavor) {
  switch (flavor) {
    case 'dev':
      return 'track2drive-dev';
    case 'staging':
      return 'track2drive-staging';
    case 'prod':
      return 'track2drive-prod';
    default:
      return 'unknown';
  }
}
