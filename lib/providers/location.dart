import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/common/app_logger.dart';
import 'package:weather_app/model/location_preference.dart';

class LocationProvider extends ChangeNotifier {
  static const String _boxName = 'appLocations';
  static const String _activeKey = 'activeIndex';

  late Box _box;
  final List<LocationPreference> _locations = [LocationPreference.gpsDefault];
  int _activeIndex = 0;
  bool _isReady = false;

  List<LocationPreference> get locations => List.unmodifiable(_locations);
  LocationPreference get activeLocation => _locations[_activeIndex];
  int get activeIndex => _activeIndex;
  bool get isReady => _isReady;

  LocationProvider() {
    _init();
  }

  Future<void> _init() async {
    Hive.registerAdapter(LocationPreferenceAdapter());
    _box = await Hive.openBox(_boxName);
    _load();
  }

  void _load() {
    _locations.clear();

    final stored = _box.get('locations');
    if (stored != null && stored is List && stored.isNotEmpty) {
      for (final item in stored) {
        if (item is LocationPreference) {
          _locations.add(item);
        }
      }
    }

    // Always ensure GPS entry exists as first item
    if (_locations.isEmpty || !_locations.first.isGps) {
      _locations.insert(0, LocationPreference.gpsDefault);
    }

    _activeIndex = (_box.get(_activeKey) as int?) ?? 0;
    if (_activeIndex >= _locations.length) _activeIndex = 0;

    _isReady = true;
    _save();
    notifyListeners();
  }

  void _save() {
    _box.put('locations', _locations.toList());
    _box.put(_activeKey, _activeIndex);
  }

  void setActive(int index) {
    if (index < 0 || index >= _locations.length) return;
    _activeIndex = index;
    _save();
    notifyListeners();
  }

  void addCity({
    required String cityName,
    required String countryName,
    String? stateName,
    String? countryEmoji,
    String? countryIso2,
  }) {
    final exists = _locations.any((l) =>
        !l.isGps &&
        l.cityName == cityName &&
        l.countryName == countryName);
    if (exists) return;

    _locations.add(LocationPreference.fromCity(
      cityName: cityName,
      countryName: countryName,
      stateName: stateName,
      countryEmoji: countryEmoji,
      countryIso2: countryIso2,
    ));
    _save();
    notifyListeners();
    AppLogger.instance.i('Added city: $cityName, $countryName');
  }

  void removeAt(int index) {
    // GPS entry (index 0) is not removable
    if (index <= 0 || index >= _locations.length) return;

    _locations.removeAt(index);

    if (_activeIndex >= _locations.length) {
      _activeIndex = _locations.length - 1;
    } else if (_activeIndex == index) {
      _activeIndex = 0;
    }

    _save();
    notifyListeners();
    AppLogger.instance.i('Removed location at index $index');
  }
}
