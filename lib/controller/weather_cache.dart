import 'package:hive/hive.dart';
import 'package:weather_app/model/weather_data.dart';

class WeatherCacheController {
  static const _boxName = 'appWeatherCache';

  WeatherData? getIfValid(String key, int limitMinutes) {
    final box = Hive.box(_boxName);
    final entry = box.get(key) as Map?;
    if (entry == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - (entry['fetchedAt'] as int);
    if (age > limitMinutes * 60 * 1000) return null;
    return WeatherData.fromJson(Map<String, dynamic>.from(entry['data'] as Map));
  }

  Future<void> save(String key, WeatherData data) async {
    final box = Hive.box(_boxName);
    await box.put(key, {
      'fetchedAt': DateTime.now().millisecondsSinceEpoch,
      'data': data.toJson(),
    });
  }
}
