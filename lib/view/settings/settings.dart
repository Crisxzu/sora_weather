import 'package:flutter/material.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/view/home/widgets/link_button.dart';
import 'package:weather_app/view/settings/widgets/update_time_selector.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../common/utils.dart';
import '../../env/env.dart';
import 'logs.dart';
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
  int _tapCount = 0;
  DateTime? _lastTapTime;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  void _handleVersionTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!).inSeconds > 5) {
      // Reset timer if intervall too long
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount >= 7) {
      _tapCount = 0; // Reset for next access
      _lastTapTime = null;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Logs()),
      );
    }
  }

  Future<void> _getAppInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: textStyle['title2'],
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
          ),
          LinkButton(
            urlStr: Env.githubLink,
            child: ListTile(
              leading: const Icon(Icons.code),
              title: Text(
                "Github",
                style: textStyle['body'],
              )
            ),
          ),
          GestureDetector(
            onTap: _handleVersionTap,
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                AppLocalizations.of(context)!.appVersion,
                style: textStyle['body'],
              ),
              subtitle: Text(
                'v$_version'
              ),
            ),
          ),
        ],
      ),
    );
  }
}


