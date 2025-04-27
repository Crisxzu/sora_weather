import 'location.dart';
import 'current_weather.dart';
import 'hourly_forecast.dart';
import 'daily_forecast.dart';

class WeatherData {
  final int lastUpdated;
  final String source;
  final String sourceLink;
  final Location location;
  final CurrentWeather current;
  final List<HourlyForecast> next24h;
  final List<DailyForecast> nextDays;

  WeatherData({
    required this.lastUpdated,
    required this.source,
    required this.sourceLink,
    required this.location,
    required this.current,
    required this.next24h,
    required this.nextDays,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      lastUpdated: json['last_updated'],
      source: json['source'],
      sourceLink: json['source_link'],
      location: Location.fromJson(json['location']),
      current: CurrentWeather.fromJson(json['current']),
      next24h: (json['next_24h'] as List)
          .map((item) => HourlyForecast.fromJson(item))
          .toList(),
      nextDays: (json['next_days'] as List)
          .map((item) => DailyForecast.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_updated': lastUpdated,
      'source': source,
      'source_link': sourceLink,
      'location': location.toJson(),
      'current': current.toJson(),
      'next_24h': next24h.map((item) => item.toJson()).toList(),
      'next_days': nextDays.map((item) => item.toJson()).toList(),
    };
  }
}