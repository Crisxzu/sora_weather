import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:weather_app/view/settings/widgets/update_time_selector.dart';

import '../../common/utils.dart';
import 'widgets/language_selector.dart';
import 'widgets/section.dart';
import 'widgets/temp_unit_selector.dart';

class Settings extends StatefulWidget {
  const Settings({
    super.key,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: Utils.mobileTextStyle['title2'],
        ),
      ),
      body: ListView(
        children: [
          ParamSection(
              title: AppLocalizations.of(context)!.appLanguage,
              child: const LanguageSelector()
          ),
          ParamSection(
              title: AppLocalizations.of(context)!.tempUnit,
              child: const TempUnitSelector()
          ),
          ParamSection(
              title: AppLocalizations.of(context)!.updateTimeLimit,
              child: const UpdateTimeSelector()
          )
        ],
      ),
    );
  }
}


