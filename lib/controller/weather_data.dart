import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:weather_app/common/app_logger.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/common/weather_icons_cache.dart';
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
    catch(e, stackTrace) {
      AppLogger.instance.e("Error in fetchApiWeatherData: $e");
      AppLogger.instance.e("Stack trace: $stackTrace");
      throw Exception("Unable to fetch weather data");
    }
  }

  Future<void> saveWidgetData(
    WeatherData data,
    TempUnit tempUnit, {
    String? position,
    String langIso = 'en',
  }) async {
    try {
      final iconCode = data.current.condition.iconCode;
      final isDay = data.current.isDay;
      final dayStr = isDay ? 'day' : 'night';

      await WeatherIconsCache().getWeatherIcon(iconCode.toString(), isDay: isDay);

      final directory = await getApplicationDocumentsDirectory();
      final iconPath = '${directory.path}/weather_icons/${iconCode}_$dayStr.png';
      final iconUrl = '${Env.baseIconUrl}/$dayStr/$iconCode.png';

      await HomeWidget.saveWidgetData<String>('widget_temp', tempUnit.toStr(data.current.temp));
      await HomeWidget.saveWidgetData<String>('widget_city', data.location.name);
      await HomeWidget.saveWidgetData<String>('widget_condition', data.current.condition.text);
      await HomeWidget.saveWidgetData<String>('widget_min_temp', tempUnit.toStr(data.current.minTemp));
      await HomeWidget.saveWidgetData<String>('widget_max_temp', tempUnit.toStr(data.current.maxTemp));
      await HomeWidget.saveWidgetData<String>('widget_icon_path', iconPath);
      await HomeWidget.saveWidgetData<String>('widget_icon_url', iconUrl);
      await HomeWidget.saveWidgetData<String>('widget_lang_iso', langIso);
      await HomeWidget.saveWidgetData<String>('widget_unit_name', tempUnit.name);
      if (position != null) {
        await HomeWidget.saveWidgetData<String>('widget_last_position', position);
      }
      await HomeWidget.saveWidgetData<bool>('widget_loading', false);
      await HomeWidget.updateWidget(
        androidName: 'WeatherWidgetProvider',
        iOSName: 'WeatherWidgetProvider',
      );
    } catch (e) {
      AppLogger.instance.e('Error saving widget data: $e');
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