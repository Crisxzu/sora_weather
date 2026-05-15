import 'package:hive/hive.dart';

part 'location_preference.g.dart';

enum LocationType { gps, city }

@HiveType(typeId: 1)
class LocationPreference extends HiveObject {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final String? cityName;

  @HiveField(2)
  final String? countryName;

  @HiveField(3)
  final String? stateName;

  @HiveField(4)
  final String? countryEmoji;

  LocationPreference({
    required this.type,
    this.cityName,
    this.countryName,
    this.stateName,
    this.countryEmoji,
  });

  bool get isGps => type == 'gps';

  String get displayName {
    if (isGps) return 'GPS';
    final parts = [cityName, stateName, countryName].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(', ');
  }

  static LocationPreference get gpsDefault => LocationPreference(type: 'gps');

  static LocationPreference fromCity({
    required String cityName,
    required String countryName,
    String? stateName,
    String? countryEmoji,
  }) =>
      LocationPreference(
        type: 'city',
        cityName: cityName,
        countryName: countryName,
        stateName: stateName,
        countryEmoji: countryEmoji,
      );
}
