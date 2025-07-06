import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/common/app_logger.dart';
import 'package:weather_app/model/weather_data.dart';

import '../env/env.dart';

class WeatherDataController {
  Future<WeatherData> fetchWeatherData(String position, String languageCode) async {
    if(Env.debugMode == '1') {
      AppLogger.instance.i("USE TEST DATA");
      return fetchTestWeatherData(position, languageCode);
    }
    else {
      return fetchApiWeatherData(position, languageCode);
    }
  }

  Future<WeatherData> fetchApiWeatherData(String position, String languageCode) async {
    try{
      final String apiLink = Uri.encodeFull('${Env.apiLink}/weather?position=$position&lang_iso=$languageCode');
      final http.Response response = await http.get(
        Uri.parse(apiLink),
        headers: {
          'Authorization': 'Api-Key ${Env.apiKey}',
        },
      );

      if(response.statusCode != 200) {
        throw Exception("Failed to fetch weather data from API. Link: $apiLink. Status code : ${response.statusCode}");
      }

      return WeatherData.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    }
    catch(e) {
      AppLogger.instance.e(e);
      throw Exception("Unable to fetch weather data");
    }
  }

  Future<WeatherData> fetchTestWeatherData(String position, String languageCode) async {
    try{
      final String response = await rootBundle.loadString('assets/json/weather_data.json');

      return WeatherData.fromJson(json.decode(response));
    }
    catch(e) {
      AppLogger.instance.e(e);
      throw Exception("Unable to load weather data");
    }
  }
}