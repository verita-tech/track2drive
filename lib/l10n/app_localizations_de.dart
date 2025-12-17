// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Track2Drive';

  @override
  String get welcome => 'Willkommen bei Track2Drive';

  @override
  String get loginTitle => 'Login';

  @override
  String get eMail => 'E-Mail';

  @override
  String get enterEMail => 'E-Mail eingeben';

  @override
  String get invalidEMail => 'Ungültige E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get enterPassword => 'Passwort eingeben';

  @override
  String get passwordSecurity => 'Mindestens 10 Zeichen, Sonderzeichen, Zahl, Groß- und Kleinbuchstaben';

  @override
  String get forgotPassword => 'Passwort vergessen';

  @override
  String get login => 'Login';

  @override
  String get noAccountRegister => 'Keinen Account? Registrieren.';

  @override
  String get register => 'Registrieren';

  @override
  String get repeatPassword => 'Passwort wiederholen';

  @override
  String get passwordsNotMatching => 'Passwörter stimmen nicht überein';

  @override
  String get createAccount => 'Account erstellen';

  @override
  String get enterEmailForReset => 'Geben Sie Ihre E-Mail ein, um einen Link zum Zurücksetzen zu erhalten.';

  @override
  String get sendResetLink => 'Link senden';

  @override
  String get resetEmailSentMessage => 'An email to reset the settings has been sent.';
}
