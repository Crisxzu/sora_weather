import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/controller/weather_data.dart';
import 'package:weather_app/model/weather_data.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherData? _data;
  WeatherData? get data => _data;
  final WeatherDataController _controller = WeatherDataController();
  Position? userPosition;


  void updateData(String position, String languageCode) {
    _controller.fetchWeatherData(position, languageCode).then((value) {
      _data = value;
      notifyListeners();
    });
  }

  Future<WeatherData> getData(String languageCode) async {
    try {
      userPosition = await Utils.determinePosition();

      _data = await _controller.fetchWeatherData("${userPosition!.latitude},${userPosition!.longitude}", languageCode);

      notifyListeners();

      return _data!;
    }
    catch(e) {
      print("$e");
      throw Exception("Unable to get weather data");
    }
  }
}