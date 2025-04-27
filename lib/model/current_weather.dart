import 'condition.dart';

class CurrentWeather {
  final int temp;
  final int minTemp;
  final int maxTemp;
  final bool isDay;
  final int feelsLike;
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
      temp: json['temp'].toDouble().round(),
      minTemp: json['min_temp'].toDouble().round(),
      maxTemp: json['max_temp'].toDouble().round(),
      isDay: json['is_day'],
      feelsLike: json['feels_like'].toDouble().round(),
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