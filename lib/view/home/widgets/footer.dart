import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/utils.dart';
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
    Locale currentLocale = Utils.getUserLanguage(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: LinkButton(
        urlStr: data.sourceLink,
        child: Row(
          mainAxisAlignment : MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.source,
              style: Utils.mobileTextStyle['title2'],
            ),
            Text(
              "${AppLocalizations.of(context)!.updated} ${Utils.getDate(data.lastUpdated, currentLocale)}",
              style: Utils.mobileTextStyle['bodyHighlight'],
            ),
          ],
        ),
      ),
    );
  }
}
