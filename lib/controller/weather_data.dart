import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:weather_app/common/app_logger.dart';
import 'package:weather_app/model/weather_data.dart';

import '../common/utils.dart';
import '../env/env.dart';

class WeatherDataController extends GetxController {
  final Rx<WeatherData?> _data = Rx<WeatherData?>(null);
  final Rx<Position?> _userPosition = Rx<Position?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  WeatherData? get data => _data.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  Position? get userPosition => _userPosition.value;


  Future<void> fetchData(String languageCode) async {
    try {
      _isLoading.value = true;
      _userPosition.value = await Utils.determinePosition();
      Map<String, String?> params = {
        'position': _userPosition.value != null ? "${_userPosition.value!.latitude},${_userPosition.value!.longitude}" : null,
        'lang_iso': languageCode
      };

      params.removeWhere((key, value) => value == null);

      if(Env.debugMode == '1') {
        AppLogger.instance.i("USE TEST DATA");
        _data.value = await fetchTestWeatherData(params);
      }
      else {
        _data.value = await fetchApiWeatherData(params);
      }
    }
    catch(e, stackTrace) {
      AppLogger.instance.e("Error in WeatherDataProvider.getData : $e");
      AppLogger.instance.e("Stack trace: $stackTrace");
      _error.value = "Unable to get weather data";
    }
    finally {
      _isLoading.value = false;
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
    catch(e, stackTrace) {
      AppLogger.instance.e("Error in fetchApiWeatherData: $e");
      AppLogger.instance.e("Stack trace: $stackTrace");
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