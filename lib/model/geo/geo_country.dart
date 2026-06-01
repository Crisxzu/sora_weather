class GeoCountry {
  const GeoCountry({
    required this.id,
    required this.name,
    required this.iso2,
    required this.emoji,
    required this.translations,
  });

  factory GeoCountry.fromJson(Map<String, dynamic> json) => GeoCountry(
        id: json['id'] as int,
        name: json['name'] as String,
        iso2: json['iso2'] as String,
        emoji: json['emoji'] as String? ?? '',
        translations: Map<String, String>.from(json['translations'] as Map? ?? {}),
      );

  final int id;
  final String name;
  final String iso2;
  final String emoji;
  final Map<String, String> translations;

  String localizedName(String languageCode) =>
      translations[languageCode] ?? translations[languageCode.split('-').first] ?? name;

  @override
  bool operator ==(Object other) => other is GeoCountry && other.iso2 == iso2;

  @override
  int get hashCode => iso2.hashCode;
}
