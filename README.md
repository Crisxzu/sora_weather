# Sora Weather ☀️

Une application météo magnifique et riche en fonctionnalités, construite avec Flutter, suivant l'architecture MVC.

<div align="center">
  <img src="assets/images/logo.png" alt="Logo de Sora Weather" width="180"/>
</div>

Le design de l'application est disponible [ici](https://www.figma.com/design/fMr1nPU6FOMlqOAwUdCog3/Application-M%C3%A9t%C3%A9o?m=auto&t=iZYpI7RJ56kmtNq-1)

## 🔧 Configuration

### Configuration de l'API

Cette application utilise une API personnalisée que j'ai développée pour communiquer avec Weather API. Le code de l'API est disponible dans un [dépôt séparé](https://github.com/Crisxzu/weather-api). Vous pouvez :

- Déployer votre propre instance de l'API en utilisant votre clé Weather API
- Utiliser le point de terminaison API par défaut fourni avec la version APK (qui utilise mon instance hébergée)

### Mode Debug

L'application inclut un mode debug qui peut être activé via le fichier `.env` :

- Lorsque `DEBUG_MODE = 0` (par défaut) : L'application se connecte à l'API réelle
- Lorsque `DEBUG_MODE = 1` : L'application utilise des données de test provenant de `assets/json/weather_data.json`

C'est utile pour le développement et les tests sans consommer de requêtes API.

### Variables d'environnement

L'application utilise le package `envied` pour gérer les variables d'environnement en toute sécurité. Après avoir créé votre fichier `.env`, vous devez générer le fichier de configuration :

```bash
dart run build_runner build
```

Exemple de fichier `.env` :
```
WEATHER_API_KEY = votre_clé_api_météo
WEATHER_API_LINK = votre_url_api
BASE_ICON_URL = "https://cdn.weatherapi.com/weather/64x64"
PORTFOLIO_LINK = "https://dazu.fr"
DEBUG_MODE = 0
```

## 📱 Disponibilité

- ✅ **Android** : Disponible via APK et sur le [Play Store](https://play.google.com/store/apps/details?id=fr.dazu.sora_weather) sous le nom **Kumi** (renommage imposé pour des raisons de droits)
- ✅ **iOS** : Fichier archive disponible et sur [App Store](https://apps.apple.com/app/sora/id6748250805)
- ✅ **macOS** : Fichier app disponible et sur [App Store](https://apps.apple.com/app/sora/id6748250805)
- ✅ **Windows** : Exécutable EXE disponible ! Aussi dispo sur [Microsoft Store](https://apps.microsoft.com/detail/9n5bv4lcr3gx)
- ✅ **Web** : Accédez directement au [site](https://sora-weather.dazu.fr) depuis votre navigateur !

## 📺 Série de tutoriels

Cette application a été construite dans le cadre de ma série de tutoriels étape par étape sur la création d'une application complète à partir de zéro. Regardez la série pour apprendre comment chaque fonctionnalité a été implémentée :

| Épisode | Sujet                                                       | Lien                         |
|---------|-------------------------------------------------------------|------------------------------|
| 01      | On design notre App Météo avec Figma                        | https://youtu.be/Z-Tla0dGWxs |
| 02      | On code notre propre API météo en Python                    | https://youtu.be/0cWW8Nz1gUI |
| 03      | On code notre App Météo (Android)                           | https://youtu.be/sOW1gINQxF0 |
| 04      | Rendre notre App Météo fonctionnelle partout                | https://youtu.be/YSFwwXcVbwI |
| 05      | On tente de déployer sur Play Store (ça s'est mal passé 😅) | https://youtu.be/ZA40PPwi29I |
| ...     | ...                                                         | ...                          |

## ✨ Fonctionnalités

- **Données météo en temps réel** : Conditions actuelles et prévisions fournies par Weather API
- **Prévisions horaires** : Prévisions sur 24 heures avec timeline défilante
- **Prévisions quotidiennes** : Aperçu météo sur 3 jours (limitations du plan gratuit)
- **Détection de localisation** : Détection automatique de la localisation avec gestion des permissions
- **Support multilingue** : L'application s'adapte automatiquement à la langue de votre appareil
- **Unités de température** : Choisissez entre Celsius et Fahrenheit
- **Rafraîchissement automatique** : Intervalles de rafraîchissement automatique configurables (5-15 minutes)
- **Mise en cache des icônes** : Système de mise en cache efficace pour les icônes météo
- **Belle interface utilisateur** : Interface propre et moderne avec des dégradés personnalisés

## 🏗️ Architecture

Le projet suit une architecture MVC (Model-View-Controller) propre :

- **Models** : Structures de données pour les informations météorologiques
- **Views** : Composants UI et écrans
- **Controllers** : Logique métier et communication API
- **Providers** : Gestion de l'état et synchronisation des données
- **Common** : Fonctions utilitaires et code partagé

## 📦 Dépendances

- `provider` : Gestion de l'état
- `http` : Requêtes API
- `path_provider` : Accès aux données locales
- `google_fonts` : Typographie personnalisée
- `intl` & `flutter_localizations` : Internationalisation
- `url_launcher` : Ouverture de liens externes
- `hive` & `hive_flutter` : Stockage de données locales
- `flutter_launcher_icons` : Gestion des icônes d'application
- `geolocator` : Services de localisation
- `envied` : Gestion des variables d'environnement
- `logger` : Système de logs
- `share_plus` : Partage de données
- `package_info_plus` : Informations de l'application (version etc...)

## 📝 Logs

Un système de logs a été mis en place pour faciliter le déboguage avec les fonctionnalités suivantes :

- **Enregistrement des logs dans différents fichiers**
- **Création d'un nouveau fichier si les logs sont trop imposants (>= 5MB)**
- **Suppression automatique des anciens logs (pas plus de 10 fichiers sauvegardés)**

Vous pouvez accéder aux logs en allant dans les paramètres de l'application puis en tapant 7 fois de suite <br/>
sur la version de l'application.<br/>
À partir de là, vous pouvez choisir de copier-coller les logs, les partager, les nettoyer.

**P.S : Sur web, il faut juste regarder la console (impossible de garder des fichiers de logs)**

## 🚀 Démarrer

### Prérequis

- Flutter SDK (3.32.3)
- Android Studio / VS Code avec les extensions Flutter
- Compréhension de base de Dart et Flutter

### Installation

1. Clonez le dépôt :
```bash
git clone https://github.com/Crisxzu/sora_weather.git
```

2. Naviguez vers le répertoire du projet :
```bash
cd sora_weather
```

3. Installez les dépendances :
```bash
flutter pub get
```

4. Créez un fichier `.env` à la racine du répertoire avec :
```
WEATHER_API_KEY = votre_clé_api_météo
WEATHER_API_LINK = votre_url_api
BASE_ICON_URL = "https://cdn.weatherapi.com/weather/64x64"
PORTFOLIO_LINK = "https://dazu.fr"
DEBUG_MODE = 0
```

5. Générez la configuration de l'environnement :
```bash
dart run build_runner build
```

6. Lancez l'application :
```bash
flutter run
```

## 📥 Téléchargement

- APK Android : [Lien de téléchargement](https://github.com/Crisxzu/sora_weather/releases/download/v.1.2.0/app-release.apk)
- App MacOS : [Lien de téléchargement](https://github.com/Crisxzu/sora_weather/releases/download/v.1.2.0/weather_app_mac.zip)
- Archive IOS : [Lien de téléchargement](https://github.com/Crisxzu/sora_weather/releases/download/v.1.2.0/weather_app_ios.zip)
- Exécutable Windows : [Lien de téléchargement](https://github.com/Crisxzu/sora_weather/releases/download/v.1.2.0/weather_app_windows.zip)

## 🤝 Contribution

Les contributions, les problèmes et les demandes de fonctionnalités sont les bienvenus ! N'hésitez pas à consulter la [page des problèmes](https://github.com/Crisxzu/sora_weather/issues).

## 📋 Licence

Ce projet est sous licence [MIT](LICENSE).

## 🙏 Remerciements

- Données météo fournies par [Weather API](https://www.weatherapi.com/)
- Icônes de WeatherAPI

## 📞 Contact

- GitHub : [@Crisxzu](https://github.com/Crisxzu)
- Chaîne Youtube : [@dazu-zara](https://www.youtube.com/@dazu-zara)
- Site web : [dazu.fr](https://dazu.fr)