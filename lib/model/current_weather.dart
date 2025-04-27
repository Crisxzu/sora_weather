import 'condition.dart';

class CurrentWeather {
  final double temp;
  final double minTemp;
  final double maxTemp;
  final bool isDay;
  final double feelsLike;
  final Condition condition;

  CurrentWeather({
    required this.temp,
    required this.minTemp,
    required this.maxTemp,
    required this.isDay,
    required this.feelsLike,
    required this.condition,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: json['temp'].toDouble(),
      minTemp: json['min_temp'].toDouble(),
      maxTemp: json['max_temp'].toDouble(),
      isDay: json['is_day'],
      feelsLike: json['feels_like'].toDouble(),
      condition: Condition.fromJson(json['condition']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'is_day': isDay,
      'feels_like': feelsLike,
      'condition': condition.toJson(),
    };
  }
}