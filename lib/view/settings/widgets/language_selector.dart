import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/utils.dart';
import '../../../controller/params.dart';
import '../../../l10n/l10n.dart';
import 'package:weather_app/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final ParamsController paramsController = Get.find();
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return DropdownButtonFormField<String>(
      value: paramsController.isSystemLocal ? 'system' : paramsController.locale!.languageCode,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      hint: Text(
        AppLocalizations.of(context)!.selectLanguage,
        style: textStyle['body'],
      ),
      isExpanded: true,
      onChanged: (String? languageCode) async {
        if (languageCode != null) {
          Locale? newLocale;
          if (languageCode == 'system') {
            // Réinitialiser à la langue du système
            newLocale = await paramsController.useSystemLocale();
          } else {
            newLocale = Locale(languageCode);
            paramsController.isSystemLocal = false;
          }
          paramsController.locale = newLocale;
          paramsController.refreshIndicatorKey!.currentState!.show();
        }
      },
      style: textStyle['body']!.copyWith(color: Utils.white),
      items: [
        DropdownMenuItem<String>(
          value: "system",
          child: Text(
            AppLocalizations.of(context)!.systemLocale,
          ),
        ),
        ...L10n.supportedLocales.map((Locale locale) {
          return DropdownMenuItem<String>(
            value: locale.languageCode,
            child: Text(
              Utils.makeTitle(Utils.getLanguageName(context, locale)),
            ),
          );
        })
      ],
    );
  }
}
