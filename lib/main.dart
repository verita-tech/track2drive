import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:track2drive/l10n/app_localizations.dart';
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
    return MaterialApp(
      title: 'Track2Drive',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(body: Center(child: Text(l10n.welcome)));
        },
      ),
    );
  }
}

FirebaseOptions _getFirebaseOptions() {
  if (kDebugMode) {
    return dev.DefaultFirebaseOptions.currentPlatform;
  }
  throw UnimplementedError('No FirebaseOptions for this platform');
}
