import 'package:flutter/material.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../model/weather_data.dart';
import '../../../providers/params.dart';
import 'link_button.dart';

class Footer extends StatelessWidget {
  const Footer({
    super.key,
    required this.data
  });

  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    final paramsProvider = Provider.of<ParamsProvider>(context);
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
            Text(
              Utils.getDate(data.lastUpdated, paramsProvider.locale!),
              style: textStyle['bodyHighlight'],
            ),
          ],
        ),
      ),
    );
  }
}
