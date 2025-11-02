import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/utils.dart';
import '../../../controller/params.dart';
import '../../../model/weather_data.dart';
import 'link_button.dart';

class Footer extends StatelessWidget {
  const Footer({
    super.key,
    required this.data
  });

  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    final ParamsController paramsController = Get.find();
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: LinkButton(
        urlStr: data.sourceLink,
        child: Row(
          mainAxisAlignment : MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.source,
              style: textStyle['bodyHighlight'],
            ),
            Obx(() =>
              Text(
                Utils.getDate(data.lastUpdated, paramsController.locale!),
                style: textStyle['bodyHighlight'],
              )
            ),
          ],
        ),
      ),
    );
  }
}
