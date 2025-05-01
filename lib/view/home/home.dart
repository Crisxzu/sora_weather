import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/model/daily_forecast.dart';
import 'package:weather_app/model/hourly_forecast.dart';
import 'package:weather_app/model/weather_data.dart';
import 'package:weather_app/providers/weather_data.dart';
import 'package:weather_app/view/global/error.dart';
import 'package:weather_app/view/global/loading_indicator.dart';
import 'package:weather_app/view/home/widgets/current_weather.dart';
import 'package:weather_app/view/home/widgets/daily_forecast.dart';
import 'package:weather_app/view/home/widgets/humidity.dart';
import 'package:weather_app/view/home/widgets/weather_icon.dart';


import '../../common/utils.dart';
import '../global/gradient_background.dart';
import 'widgets/hourly_forecast.dart';

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final weatherDataProvider = Provider.of<WeatherDataProvider>(context, listen: false);

    setState(() {
      Locale currentLocale = Utils.getUserLanguage(context);
      _weatherData = weatherDataProvider.getData("7.370945,-3.752885", currentLocale.languageCode);
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
                            HourlyForecastView(data: snapshot.data!.next24h),
                            DailyForecastView(data: snapshot.data!.nextDays),
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








