# Sora Weather ☀️

A beautiful, feature-rich weather application built with Flutter, following MVC architecture.

<div align="center">
  <img src="assets/images/logo.png" alt="Sora Weather Logo" width="180"/>
</div>

Design of app available [here](https://www.figma.com/design/fMr1nPU6FOMlqOAwUdCog3/Application-M%C3%A9t%C3%A9o?m=auto&t=iZYpI7RJz56kmtNq-1)

## 🔧 Configuration

### API Setup

This application uses a custom API that I've developed to communicate with Weather API. The API code is available in a [separate repository](https://github.com/Crisxzu/weather-api). You can:

- Deploy your own instance of the API using your Weather API key
- Use the default API endpoint that comes with the APK release (which uses my hosted instance)

### Debug Mode

The application includes a debug mode that can be activated through the `.env` file:

- When `DEBUG_MODE = 0` (default): The app connects to the actual API
- When `DEBUG_MODE = 1`: The app uses test data from `assets/json/weather_data.json`

This is useful for development and testing without consuming API requests.

### Environment Variables

The app uses the `envied` package to securely manage environment variables. After creating your `.env` file, you need to generate the configuration file:

```bash
dart run build_runner build
```

Example `.env` file:
```
WEATHER_API_KEY = your_weather_api_key
WEATHER_API_LINK = your_api_url
BASE_ICON_URL = "https://cdn.weatherapi.com/weather/64x64"
PORTFOLIO_LINK = "https://dazu.fr"
DEBUG_MODE = 0
```

## 📱 Availability

- ✅ **Android**: Available via APK download
- 🚧 **iOS**: Coming soon
- 🚧 **Web**: Coming soon
- 🚧 **Windows**: Coming soon
- 🚧 **macOS**: Coming soon

## 📺 Tutorial Series

This application was built as part of my step-by-step tutorial series on creating a complete application from scratch. Watch the series to learn how each feature was implemented:

| Episode | Topic                                    | Link                         |
|---------|------------------------------------------|------------------------------|
| 01      | On design notre App Météo avec Figma     | https://youtu.be/Z-Tla0dGWxs |
| 02      | On code notre propre API météo en Python | https://youtu.be/0cWW8Nz1gUI |
| 03      | On code notre App Météo (Android)        | [Coming Soon]                |
| ...     | ...                                      | ...                          |

## ✨ Features

- **Real-time Weather Data**: Current conditions and forecasts powered by Weather API
- **Hourly Forecasts**: 24-hour forecast with scrollable timeline
- **Daily Forecasts**: 3-day weather outlook (free plan limitations)
- **Location Detection**: Automatic location detection with permission handling
- **Multi-language Support**: Application automatically adapts to your device language
- **Temperature Units**: Choose between Celsius and Fahrenheit
- **Auto-refresh**: Configurable auto-refresh intervals (5-15 minutes)
- **Icon Caching**: Efficient caching system for weather icons
- **Beautiful UI**: Clean, modern interface with custom gradients

## 🏗️ Architecture

The project follows a clean MVC (Model-View-Controller) architecture:

- **Models**: Data structures for weather information
- **Views**: UI components and screens
- **Controllers**: Business logic and API communication
- **Providers**: State management and data synchronization
- **Common**: Utility functions and shared code

## 📦 Dependencies

- `provider`: State management
- `http`: API requests
- `path_provider`: Local data access
- `google_fonts`: Custom typography
- `intl` & `flutter_localizations`: Internationalization
- `url_launcher`: Opening external links
- `hive` & `hive_flutter`: Local data storage
- `flutter_launcher_icons`: App icon management
- `geolocator`: Location services
- `envied`: Environment variables management

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.24.1)
- Android Studio / VS Code with Flutter extensions
- Basic understanding of Dart and Flutter

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Crisxzu/sora_weather.git
```

2. Navigate to the project directory:
```bash
cd sora_weather
```

3. Install dependencies:
```bash
flutter pub get
```

4. Create an `.env` file in the root directory with:
```
WEATHER_API_KEY = your_weather_api_key
WEATHER_API_LINK = your_api_url
BASE_ICON_URL = "https://cdn.weatherapi.com/weather/64x64"
PORTFOLIO_LINK = "https://dazu.fr"
DEBUG_MODE = 0
```

5. Generate the environment configuration:
```bash
dart run build_runner build
```

6. Run the app:
```bash
flutter run
```

## 📥 Download

- Android APK: [Download Link](https://link-to-your-apk.com)
- Other platforms: Coming soon

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Crisxzu/sora_weather/issues).

## 📋 License

This project is licensed under the [MIT License](LICENSE).

## 🙏 Acknowledgements

- Weather data provided by [Weather API](https://www.weatherapi.com/)
- Icons from WeatherAPI

## 📞 Contact

- GitHub: [@Crisxzu](https://github.com/Crisxzu)
- Youtube channel : [@dazu-zara](https://www.youtube.com/@dazu-zara)
- Website: [dazu.fr](https://dazu.fr)

