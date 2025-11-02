import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/l10n/app_localizations.dart';

import '../../../common/utils.dart';
import '../../../controller/params.dart';
import '../../../model/current_weather.dart';

class CurrentWeatherView extends StatelessWidget {
  const CurrentWeatherView({
    super.key,
    required this.data
  });
  final CurrentWeather data;

  @override
  Widget build(BuildContext context) {
    final ParamsController paramsController = Get.find();
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                paramsController.tempUnit!.toStr(data.temp),
                style: textStyle['header'],
              )),
              Text(
                data.condition.text,
                style: textStyle['title2'],
              )
            ],
          ),
          const SizedBox(height: 16,),
          Obx(() => Text(
              "${paramsController.tempUnit!.toStr(data.maxTemp)}/${paramsController.tempUnit!.toStr(data.minTemp)}, ${AppLocalizations.of(context)!.feelsLike} ${paramsController.tempUnit!.toStr(data.feelsLike)}",
              style: textStyle['title2'],
            )
          )
        ],
      ),
    );
  }
}