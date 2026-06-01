class GeoCity {
  const GeoCity({
    required this.id,
    required this.name,
    required this.stateId,
  });

  factory GeoCity.fromJson(Map<String, dynamic> json) => GeoCity(
        id: json['id'] as int,
        name: json['name'] as String,
        stateId: json['state_id'] as int,
      );

  final int id;
  final String name;
  final int stateId;

  @override
  bool operator ==(Object other) => other is GeoCity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
