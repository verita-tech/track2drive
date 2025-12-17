import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:track2drive/features/auth/domain/entities/user_entity.dart';
import 'package:track2drive/l10n/app_localizations.dart';
import 'firebase_options_dev.dart' as dev;
import 'package:track2drive/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:track2drive/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:track2drive/features/auth/domain/usecases/login_usecase.dart';
import 'package:track2drive/features/auth/domain/usecases/logout_usecase.dart';
import 'package:track2drive/features/auth/domain/usecases/register_usecase.dart';
import 'package:track2drive/features/auth/domain/usecases/send_reset_email_usecase.dart';
import 'package:track2drive/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:track2drive/features/auth/presentation/pages/auth_gate.dart';

enum AppEnv { dev, staging, prod }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final firebaseOptions = _getFirebaseOptions(flavor);
  await Firebase.initializeApp(options: firebaseOptions);

  final firebaseAuth = FirebaseAuth.instance;
  final dataSource = FirebaseAuthDataSourceImpl(firebaseAuth);
  final authRepository = AuthRepositoryImpl(dataSource);

  final loginUsecase = LoginUseCase(authRepository);
  final registerUsecase = RegisterUseCase(authRepository);
  final sendResetUsecase = SendResetEmailUseCase(authRepository);
  final logoutUsecase = LogoutUseCase(authRepository);

  final authStateStream = authRepository.authStateChanges();

  runApp(
    MainApp(
      flavor: flavor,
      loginUseCase: loginUsecase,
      registerUseCase: registerUsecase,
      sendResetEmailUseCase: sendResetUsecase,
      logoutUseCase: logoutUsecase,
      authStateStream: authStateStream,
    ),
  );
}

class MainApp extends StatelessWidget {
  final String flavor;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SendResetEmailUseCase sendResetEmailUseCase;
  final LogoutUseCase logoutUseCase;
  final Stream<UserEntity?> authStateStream;

  const MainApp({
    super.key,
    required this.flavor,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendResetEmailUseCase,
    required this.logoutUseCase,
    required this.authStateStream,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        login: loginUseCase,
        register: registerUseCase,
        sendReset: sendResetEmailUseCase,
        logout: logoutUseCase,
        authStateStream: authStateStream,
      ),
      child: MaterialApp(
        title: 'Track2Drive $flavor',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const AuthGate(),
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
