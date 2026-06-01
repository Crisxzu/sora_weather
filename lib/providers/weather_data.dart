import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/controller/weather_cache.dart';
import 'package:weather_app/controller/weather_data.dart';
import 'package:weather_app/model/location_preference.dart';
import 'package:weather_app/model/weather_data.dart';

import '../common/app_logger.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherData? _data;
  WeatherData? get data => _data;

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  Object? _error;
  Object? get error => _error;

  final WeatherDataController _controller = WeatherDataController();
  final WeatherCacheController _cache = WeatherCacheController();
  Position? userPosition;

  Future<void> getData(
    String languageCode,
    TempUnit tempUnit,
    LocationPreference activeLocation,
    int updateLimitMinutes,
  ) async {
    _error = null;

    final String cacheKey = activeLocation.isGps
        ? 'gps_${userPosition?.latitude.toStringAsFixed(2)}_${userPosition?.longitude.toStringAsFixed(2)}'
        : 'city_${activeLocation.cityName?.toLowerCase()}';

    final cached = _cache.getIfValid(cacheKey, updateLimitMinutes);
    if (cached != null) {
      _data = cached;
      notifyListeners();
      return;
    }

    _isFetching = true;
    notifyListeners();

    try {
      Map<String, String?> params = {'lang_iso': languageCode};

      if (activeLocation.isGps) {
        userPosition = await Utils.determinePosition();
        if (userPosition != null) {
          params['position'] = '${userPosition!.latitude},${userPosition!.longitude}';
        }
      } else {
        params['city'] = activeLocation.cityName;
      }

      _data = await _controller.fetchWeatherData(params);
      await _cache.save(cacheKey, _data!);

      _controller.saveWidgetData(
        _data!,
        tempUnit,
        position: params['position'],
        city: params['city'],
        langIso: languageCode,
      );
    } catch (e, stackTrace) {
      AppLogger.instance.e("Error in WeatherDataProvider.getData : $e");
      AppLogger.instance.e("Stack trace: $stackTrace");
      _error = e;
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
