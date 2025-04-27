import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:weather_app/model/weather_data.dart';

class WeatherDataController {
  Future<WeatherData> fetchWeatherData(String position) async {
    try{
      final String response = await rootBundle.loadString('assets/jsone/weather_data.json');

      return WeatherData.fromJson(json.decode(response));
    }
    catch(e) {
      print(e);
      throw Exception("Unable to load weather data");
    }
  }
}