import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options_dev.dart' as dev;

enum AppEnv { dev, staging, prod }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseOptions = _getFirebaseOptions();
  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}

FirebaseOptions _getFirebaseOptions() {
  if (kDebugMode || kProfileMode) {
    return dev.DefaultFirebaseOptions.currentPlatform;
  }
  throw UnimplementedError('No FirebaseOptions for this platform');
}
