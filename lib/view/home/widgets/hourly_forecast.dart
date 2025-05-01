import 'package:flutter/material.dart';
import 'package:weather_app/view/home/widgets/panel.dart';

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
    return Panel(
      height: 175,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              HourlyForecast forecast = data[index];
              Locale currentLocale = Utils.getUserLanguage(context);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      Utils.getHour(forecast.timestamp, currentLocale),
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
