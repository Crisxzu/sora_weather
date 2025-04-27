import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../model/current_weather.dart';

class CurrentWeatherView extends StatelessWidget {
  const CurrentWeatherView({
    super.key,
    required this.data
  });
  final CurrentWeather data;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${data.temp}º",
                style: Utils.mobileTextStyle['header'],
              ),
              Text(
                data.condition.text,
                style: Utils.mobileTextStyle['title2'],
              )
            ],
          ),
          const SizedBox(height: 16,),
          Text(
            "${data.maxTemp}º/${data.minTemp}º Feels like ${data.feelsLike}º",
            style: Utils.mobileTextStyle['title2'],
          )
        ],
      ),
    );
  }
}