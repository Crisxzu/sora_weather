import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/model/hourly_forecast.dart';
import 'package:weather_app/model/weather_data.dart';
import 'package:weather_app/providers/weather_data.dart';
import 'package:weather_app/view/global/error.dart';
import 'package:weather_app/view/global/loading_indicator.dart';
import 'package:weather_app/view/home/widgets/current_weather.dart';
import 'package:weather_app/view/home/widgets/humidity.dart';
import 'package:weather_app/view/home/widgets/weather_icon.dart';


import '../../common/utils.dart';
import '../global/gradient_background.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final appBarHeight = kToolbarHeight;
  Future<WeatherData>? _weatherData;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final weatherDataProvider = Provider.of<WeatherDataProvider>(context, listen: false);
    setState(() {
      _weatherData = weatherDataProvider.getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const GradientBackground(),
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: appBarHeight,),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<WeatherData>(
                    future: _weatherData,
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CurrentWeatherView(data: snapshot.data!.current),
                            HourlyForecastView(data: snapshot.data!.next24h)
                          ],
                        );
                      }
                      else if(snapshot.hasError) {
                        print("Error when fetching weather data: ${snapshot.error}");

                        return const ErrorMessage(message: null,);
                      }
                      else {
                        return const LoadingIndicator();
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        )

      ],
    );
  }
}

class HourlyForecastView extends StatelessWidget {
  const HourlyForecastView({
    super.key,
    required this.data
  });

  final List<HourlyForecast> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 175,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          color: Utils.darkBlue.withOpacity(0.53)
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            HourlyForecast forecast = data[index];
            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(forecast.timestamp * 1000);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: Column(
                children: [
                  Text(
                    '${dateTime.hour}:00',
                    style: Utils.mobileTextStyle['body']!.copyWith(color: Utils.gray),
                  ),
                  WeatherIcon(
                      iconCode: "${forecast.condition.iconCode}"
                  ),
                  Text(
                    '${forecast.temp}º',
                    style: Utils.mobileTextStyle['bodyHighlight'],
                  ),
                  HumidityView(humidity: forecast.humidity)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

