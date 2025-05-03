import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../providers/params.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final paramsProvider = Provider.of<ParamsProvider>(context);

    return DropdownButtonFormField<String>(
      value: paramsProvider.isSystemLocal ? 'system' : paramsProvider.locale!.languageCode,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      hint: Text(AppLocalizations.of(context)!.selectLanguage),
      onChanged: (String? languageCode) {
        if (languageCode != null) {
          if (languageCode == 'system') {
            // Réinitialiser à la langue du système
            paramsProvider.useSystemLocale();
          } else {
            paramsProvider.locale = Locale(languageCode);
          }
        }
      },
      items: [
        DropdownMenuItem<String>(
          value: "system",
          child: Text(
            AppLocalizations.of(context)!.systemLocale,
            style: Utils.mobileTextStyle['body'],
          ),
        ),
        ...L10n.supportedLocales.map((Locale locale) {
          return DropdownMenuItem<String>(
            value: locale.languageCode,
            child: Text(
              Utils.makeTitle(Utils.getLanguageName(context, locale)),
              style: Utils.mobileTextStyle['body'],
            ),
          );
        })
      ],
    );
  }
}
