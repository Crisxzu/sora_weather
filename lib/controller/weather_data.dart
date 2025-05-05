import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/model/weather_data.dart';

import '../env/env.dart';

class WeatherDataController {
  Future<WeatherData> fetchWeatherData(String position, String languageCode) async {
    if(Env.debugMode == '1') {
      print("USE TEST DATA");
      return fetchTestWeatherData(position, languageCode);
    }
    else {
      return fetchApiWeatherData(position, languageCode);
    }
  }

  Future<WeatherData> fetchApiWeatherData(String position, String languageCode) async {
    try{
      final http.Response response = await http.get(
        Uri.parse('${Env.apiLink}/weather?position=$position&lang_iso=$languageCode'),
        headers: {
          'Authorization': 'Api-Key ${Env.apiKey}',
        },
      );

      if(response.statusCode != 200) {
        print(jsonDecode(response.body));
        throw Exception("Failed to fetch weather data from API");
      }

      return WeatherData.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    }
    catch(e) {
      print(e);
      throw Exception("Unable to fetch weather data");
    }
  }

  Future<WeatherData> fetchTestWeatherData(String position, String languageCode) async {
    try{
      final String response = await rootBundle.loadString('assets/json/weather_data.json');

      return WeatherData.fromJson(json.decode(response));
    }
    catch(e) {
      print(e);
      throw Exception("Unable to load weather data");
    }
  }
}