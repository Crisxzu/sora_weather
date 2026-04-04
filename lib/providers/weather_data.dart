import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/controller/weather_data.dart';
import 'package:weather_app/model/weather_data.dart';

import '../common/app_logger.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherData? _data;
  WeatherData? get data => _data;
  final WeatherDataController _controller = WeatherDataController();
  Position? userPosition;

  Future<WeatherData> getData(String languageCode, TempUnit tempUnit) async {
    try {
      userPosition = await Utils.determinePosition();

      final position = userPosition != null
          ? '${userPosition!.latitude},${userPosition!.longitude}'
          : null;

      _data = await _controller.fetchWeatherData({
        'position': position,
        'lang_iso': languageCode,
      });

      notifyListeners();
      _controller.saveWidgetData(_data!, tempUnit, position: position, langIso: languageCode);

      return _data!;
    } catch (e, stackTrace) {
      AppLogger.instance.e("Error in WeatherDataProvider.getData : $e");
      AppLogger.instance.e("Stack trace: $stackTrace");
      throw Exception("Unable to get weather data");
    }
  }
}
