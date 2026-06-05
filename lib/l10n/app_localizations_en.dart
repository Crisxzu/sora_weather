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
  String get dataErrorMessage => 'Please check your Internet connection.';

  @override
  String get dataErrorContact =>
      'If the problem persists, please contact the developers on the app store or Github.';

  @override
  String get mailContact => 'Contact by mail';

  @override
  String get github => 'Go to Github';

  @override
  String get loading => 'Loading...';

  @override
  String get logsNotFound => 'No logs found.';

  @override
  String get logsCopied => 'Logs copied on clipboard !';

  @override
  String get logsCleared => 'Logs cleared !';

  @override
  String get logsUnavailable => 'No logs to share';

  @override
  String get appVersion => 'Version';

  @override
  String get appLogs => 'App logs';

  @override
  String get appDevMode =>
      'Welcome to the intricacies of the 🧑‍💻 application. But hush 🤫.';

  @override
  String get copyLogs => 'Copy logs';

  @override
  String get shareLogs => 'Share logs';

  @override
  String get clearLogs => 'Clear logs';

  @override
  String get refreshLogs => 'Refresh logs';

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
  String get locationDialogTitle => 'Location 📍';

  @override
  String get locationProvided => 'Data provided from your precise location 😎.';

  @override
  String get locationNotProvided =>
      'Data provided from the position deduced from your IP address, so potentially inaccurate 😓.\nFor better accuracy, please enable location services, give access to the app and reload the page 😉.';

  @override
  String get closeDialog => 'Close';

  @override
  String get goToLocationSettings => 'Go to Settings';

  @override
  String get credits => 'Made with ❤️ by Dazu';

  @override
  String locationCityMode(String city) {
    return 'Data provided for $city, as selected in your locations.';
  }

  @override
  String get country => 'Country';

  @override
  String get state => 'State / Region';

  @override
  String get city => 'City';

  @override
  String get myLocations => 'My locations';

  @override
  String get addCity => 'Add a city';

  @override
  String get myPosition => 'My position';

  @override
  String get myPositionSubtitle => 'Determined automatically via GPS';

  @override
  String get apiErrorLocationNotFound =>
      'Location not found. Please check the city name or your GPS settings.';

  @override
  String get apiErrorAuth =>
      'Authentication error. Please contact the developer.';

  @override
  String get apiErrorServiceUnavailable =>
      'Weather service temporarily unavailable. Please try again later.';

  @override
  String get apiErrorTooManyRequests =>
      'Too many requests. Please wait a moment before retrying.';

  @override
  String get apiErrorServer =>
      'A server error occurred. Please try again later.';

  @override
  String get apiErrorDefault =>
      'Unable to retrieve weather data. Please check your Internet connection.';

  @override
  String get typeToSearch => 'Type to search...';

  @override
  String get noResults => 'No results found.';
}
