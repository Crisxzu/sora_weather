import 'package:flutter/cupertino.dart';
import 'package:weather_app/controller/weather_data.dart';
import 'package:weather_app/model/weather_data.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherData? _data;
  WeatherData? get data => _data;
  final WeatherDataController _controller = WeatherDataController();
  
  void updateData() {
    _controller.fetchWeatherData("7.370945,-3.752885").then((value) {
      _data = value;
      notifyListeners();
    });
  }

  Future<WeatherData> getData() async {
    try {
      _data ??= await _controller.fetchWeatherData("7.370945,-3.752885");

      return _data!;
    }
    catch(e) {
      print("$e");
      throw Exception("Unable to get weather data");
    }
  }
}