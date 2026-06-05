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
  String get dataErrorMessage => 'Veuillez vérifier votre connexion Internet.';

  @override
  String get dataErrorContact =>
      'Si le problème persiste, merci de contacter les développeurs via le store de l\'application ou Github.';

  @override
  String get mailContact => 'Contacter par mail';

  @override
  String get github => 'Aller au Github';

  @override
  String get loading => 'Chargement...';

  @override
  String get logsNotFound => 'Aucun logs trouvé';

  @override
  String get logsCopied => 'Logs copié dans le presse-papier';

  @override
  String get logsCleared => 'Logs effacé !';

  @override
  String get logsUnavailable => 'Aucun log à partager';

  @override
  String get appVersion => 'Version';

  @override
  String get appLogs => 'Logs de l\'application';

  @override
  String get appDevMode =>
      'Bienvenue dans les méandres de l\'application 🧑‍💻. Mais attention chut 🤫.';

  @override
  String get copyLogs => 'Copier les logs';

  @override
  String get shareLogs => 'Partager les logs';

  @override
  String get clearLogs => 'Effacer les logs';

  @override
  String get refreshLogs => 'Rafraîchir les logs';

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
  String get locationDialogTitle => 'Localisation 📍';

  @override
  String get locationProvided =>
      'Données fournies à partir de votre localisation précise 😎.';

  @override
  String get locationNotProvided =>
      'Données fournies à partir de la position déduite de votre adresse IP, donc potentiellement inexacte 😓.\nPour plus de précision, activez les services de localisation, accorder la permission à l\'application et recharger la page 😉.';

  @override
  String get closeDialog => 'Fermer';

  @override
  String get goToLocationSettings => 'Aller aux Paramètres';

  @override
  String get credits => 'Fait avec ❤️ par Dazu';

  @override
  String locationCityMode(String city) {
    return 'Données fournies pour $city, tel que sélectionné dans vos villes.';
  }

  @override
  String get country => 'Pays';

  @override
  String get state => 'État / Région';

  @override
  String get city => 'Ville';

  @override
  String get myLocations => 'Mes villes';

  @override
  String get addCity => 'Ajouter une ville';

  @override
  String get myPosition => 'Ma position';

  @override
  String get myPositionSubtitle => 'Déterminée automatiquement via le GPS';

  @override
  String get apiErrorLocationNotFound =>
      'Localisation introuvable. Vérifiez le nom de la ville ou vos paramètres GPS.';

  @override
  String get apiErrorAuth =>
      'Erreur d\'authentification. Merci de contacter le développeur.';

  @override
  String get apiErrorServiceUnavailable =>
      'Le service météo est temporairement indisponible. Réessayez plus tard.';

  @override
  String get apiErrorTooManyRequests =>
      'Trop de requêtes. Attendez un moment avant de réessayer.';

  @override
  String get apiErrorServer =>
      'Une erreur serveur est survenue. Réessayez plus tard.';

  @override
  String get apiErrorDefault =>
      'Impossible de récupérer les données météo. Vérifiez votre connexion Internet.';

  @override
  String get typeToSearch => 'Tapez pour rechercher...';

  @override
  String get noResults => 'Aucun résultat trouvé.';
}
