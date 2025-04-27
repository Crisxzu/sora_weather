import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/model/weather_data.dart';
import 'package:weather_app/providers/weather_data.dart';
import 'package:weather_app/view/global/error.dart';
import 'package:weather_app/view/global/loading_indicator.dart';


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
        Column(
          children: [
            SizedBox(height: appBarHeight,),
            Expanded(
              child: FutureBuilder<WeatherData>(
                future: _weatherData,
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return Text("Prêt");
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
            )
          ],
        )

      ],
    );
  }
}