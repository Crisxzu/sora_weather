import 'package:hive/hive.dart';
import 'package:weather_app/model/weather_data.dart';

Map<String, dynamic> _deepCast(Map m) {
  return m.map((k, v) {
    if (v is Map) return MapEntry(k.toString(), _deepCast(v));
    if (v is List) return MapEntry(k.toString(), _deepCastList(v));
    return MapEntry(k.toString(), v);
  });
}

List _deepCastList(List l) {
  return l.map((v) {
    if (v is Map) return _deepCast(v);
    if (v is List) return _deepCastList(v);
    return v;
  }).toList();
}

class WeatherCacheController {
  static const _boxName = 'appWeatherCache';

  WeatherData? getIfValid(String key, int limitMinutes) {
    final box = Hive.box(_boxName);
    final entry = box.get(key) as Map?;
    if (entry == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - (entry['fetchedAt'] as int);
    if (age > limitMinutes * 60 * 1000) return null;
    return WeatherData.fromJson(_deepCast(entry['data'] as Map));
  }

  Future<void> save(String key, WeatherData data) async {
    final box = Hive.box(_boxName);
    await box.put(key, {
      'fetchedAt': DateTime.now().millisecondsSinceEpoch,
      'data': data.toJson(),
    });
  }
}
