import 'package:weather_app/common/fuzzy_search.dart';

class GeoState {
  GeoState({
    required this.id,
    required this.name,
    required this.countryIso2,
    this.iso2,
    this.type,
    required this.translations,
  });

  factory GeoState.fromJson(Map<String, dynamic> json, {required String countryIso2}) =>
      GeoState(
        id: json['id'] as int,
        name: json['name'] as String,
        countryIso2: countryIso2,
        iso2: json['iso2'] as String?,
        type: json['type'] as String?,
        translations: Map<String, String>.from(json['translations'] as Map? ?? {}),
      );

  final int id;
  final String name;
  final String countryIso2;
  final String? iso2;
  final String? type;
  final Map<String, String> translations;

  late final String normalizedName = FuzzySearch.normalize(name);

  String localizedName(String languageCode) =>
      translations[languageCode] ?? translations[languageCode.split('-').first] ?? name;

  @override
  bool operator ==(Object other) => other is GeoState && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
