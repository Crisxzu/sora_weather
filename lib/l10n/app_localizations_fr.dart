// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get feelsLike => 'Ressenti';

  @override
  String get source => 'Source';

  @override
  String get updated => 'Mis à jour le:';

  @override
  String get linkError => 'Impossible d\'ouvrir le lien';

  @override
  String get dataErrorTitle => 'Oups, une erreur est survenue. 😥';

  @override
  String get dataErrorMessage =>
      'Veuillez vérifier votre connexion Internet, ainsi que l’activation de la localisation et des services associés (GPS, Wi-Fi).';

  @override
  String get dataErrorContact =>
      'Si le problème persiste, merci de contacter les développeurs via le Play Store.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get selectLanguage => 'Sélectionner une langue';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get systemLocale => 'Langue du système';

  @override
  String get tempUnit => 'Unité de température';

  @override
  String get updateTimeLimit => 'Mettre à jour toutes les';

  @override
  String get credits => 'Fait avec ❤️ par Dazu';
}
