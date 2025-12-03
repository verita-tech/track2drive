// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Track2Drive';

  @override
  String get welcome => 'Welcome to Track2Drive';

  @override
  String get loginTitle => 'Login';

  @override
  String get eMail => 'Email';

  @override
  String get enterEMail => 'Enter email';

  @override
  String get invalidEMail => 'Invalid email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get passwordSecurity => 'Minimum 10 characters, special character, number, uppercase and lowercase letters';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get login => 'Login';

  @override
  String get noAccountRegister => 'No account? Register';
}
