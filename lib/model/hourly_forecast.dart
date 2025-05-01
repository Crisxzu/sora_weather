import 'condition.dart';

class HourlyForecast {
  final int temp;
  final int humidity;
  final int timestamp;
  final Condition condition;
  final bool isDay;

  HourlyForecast({
    required this.temp,
    required this.humidity,
    required this.timestamp,
    required this.condition,
    required this.isDay
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      temp: json['temp'].toDouble().round(),
      humidity: json['humidity'].toDouble().round(),
      timestamp: json['timestamp'],
      condition: Condition.fromJson(json['condition']),
      isDay: json['is_day']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'humidity': humidity,
      'timestamp': timestamp,
      'condition': condition.toJson(),
      'is_day': isDay
    };
  }
}