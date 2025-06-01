// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get feelsLike => 'Feels like';

  @override
  String get source => 'Source';

  @override
  String get updated => 'Updated:';

  @override
  String get linkError => 'Cannot open the link';

  @override
  String get dataErrorTitle => 'Oops, an error has occurred. 😥';

  @override
  String get dataErrorMessage =>
      'Please check your Internet connection, and make sure that location services and related features (GPS, Wi-Fi) are enabled.';

  @override
  String get dataErrorContact =>
      'If the problem persists, please contact the developers via the Play Store.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get appLanguage => 'App language';

  @override
  String get systemLocale => 'System language';

  @override
  String get tempUnit => 'Temperature unit';

  @override
  String get updateTimeLimit => 'Update every';

  @override
  String get credits => 'Made with ❤️ by Dazu';
}
