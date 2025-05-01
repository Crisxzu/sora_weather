import 'package:flutter/material.dart';

import '../../../common/utils.dart';
import '../../../model/hourly_forecast.dart';
import 'humidity.dart';
import 'weather_icon.dart';

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
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white,
                Colors.white,
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.0, 0.1, 0.9, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
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
                      iconCode: "${forecast.condition.iconCode}",
                      isDay: forecast.isDay,
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
      ),
    );
  }
}
