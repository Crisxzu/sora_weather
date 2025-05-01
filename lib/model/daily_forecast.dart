import 'condition.dart';

class DailyForecast {
  final int minTemp;
  final int maxTemp;
  final int humidity;
  final int timestamp;
  final Condition condition;
  final bool isDay;

  DailyForecast({
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.timestamp,
    required this.condition,
    required this.isDay
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      minTemp: json['min_temp'].toDouble().round(),
      maxTemp: json['max_temp'].toDouble().round(),
      humidity: json['humidity'].toDouble().round(),
      timestamp: json['timestamp'],
      condition: Condition.fromJson(json['condition']),
      isDay: json['is_day']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'humidity': humidity,
      'timestamp': timestamp,
      'condition': condition.toJson(),
      'is_day': isDay
    };
  }
}