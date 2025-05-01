import 'package:flutter/material.dart';
import 'package:weather_app/view/home/widgets/humidity.dart';
import 'package:weather_app/view/home/widgets/panel.dart';
import 'package:weather_app/view/home/widgets/weather_icon.dart';

import '../../../common/utils.dart';
import '../../../model/daily_forecast.dart';

class DailyForecastView extends StatelessWidget {
  const DailyForecastView({
    super.key,
    required this.data,
  });
  final List<DailyForecast> data;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          ...[
            for(int i = 0; i < data.length; i++)
              DayForecastView(data: data[i])
          ]
        ],
      ),
    );
  }
}

class DayForecastView extends StatelessWidget {
  const DayForecastView({
    super.key,
    required this.data,
  });

  final DailyForecast data;

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Utils.getUserLanguage(context);
    String day = Utils.getDayOfWeek(data.timestamp, currentLocale);


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              Utils.makeTitle(day),
              style: Utils.mobileTextStyle['bodyHighlight'],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HumidityView(humidity: data.humidity),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: WeatherIcon(
                  iconCode: "${data.condition.iconCode}",
                  isDay: data.isDay,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16,),
              Row(
                children: [
                  Text(
                    "${data.maxTemp}º",
                    style: Utils.mobileTextStyle['bodyHighlight'],
                  ),
                  const SizedBox(width: 12,),
                  Text(
                    "${data.minTemp}º",
                    style: Utils.mobileTextStyle['bodyHighlight'],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}