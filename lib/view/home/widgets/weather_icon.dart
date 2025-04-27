import 'package:flutter/material.dart';

import '../../../common/weather_icons_cache.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final bool isDay;
  final double size;

  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.isDay = true,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: WeatherIconsCache().getWeatherIcon(iconCode, isDay: isDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return SizedBox(
            width: size,
            height: size,
            child: snapshot.data,
          );
        } else {
          // Afficher un placeholder pendant le chargement
          return SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}