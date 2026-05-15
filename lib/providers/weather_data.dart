import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/controller/weather_data.dart';
import 'package:weather_app/model/location_preference.dart';
import 'package:weather_app/model/weather_data.dart';

import '../common/app_logger.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherData? _data;
  WeatherData? get data => _data;
  final WeatherDataController _controller = WeatherDataController();
  Position? userPosition;

  Future<WeatherData> getData(
    String languageCode,
    TempUnit tempUnit,
    LocationPreference activeLocation,
  ) async {
    try {
      Map<String, String?> params = {'lang_iso': languageCode};

      if (activeLocation.isGps) {
        userPosition = await Utils.determinePosition();
        if (userPosition != null) {
          params['position'] = '${userPosition!.latitude},${userPosition!.longitude}';
        }
        // If GPS unavailable, omit position — API falls back to IP
      } else {
        params['city'] = activeLocation.cityName;
      }

      _data = await _controller.fetchWeatherData(params);

      notifyListeners();
      _controller.saveWidgetData(
        _data!,
        tempUnit,
        position: params['position'],
        city: params['city'],
        langIso: languageCode,
      );

      return _data!;
    } catch (e, stackTrace) {
      AppLogger.instance.e("Error in WeatherDataProvider.getData : $e");
      AppLogger.instance.e("Stack trace: $stackTrace");
      rethrow;
    }
  }
}
