import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/common/app_logger.dart';
import 'package:weather_app/model/weather_data.dart';

import '../env/env.dart';

class WeatherDataController {
  Future<WeatherData> fetchWeatherData(Map<String, String?> params) async {
    params.removeWhere((key, value) => value == null);

    if(Env.debugMode == '1') {
      AppLogger.instance.i("USE TEST DATA");
      return fetchTestWeatherData(params);
    }
    else {
      return fetchApiWeatherData(params);
    }
  }

  Future<WeatherData> fetchApiWeatherData(Map<String, String?> params) async {
    try{
      String paramsStr = '';

      if(params.keys.isNotEmpty) {
        paramsStr = '?${params.keys.map((key) => "$key=${params[key]}").join('&')}';
      }

      final String apiLink = Uri.encodeFull('${Env.apiLink}/weather$paramsStr');
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

  Future<WeatherData> fetchTestWeatherData(Map<String, String?> params) async {
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