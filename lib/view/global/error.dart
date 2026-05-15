import 'package:flutter/material.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/view/home/widgets/link_button.dart';

import '../../common/utils.dart';
import '../../env/env.dart';
import '../../main.dart';

class ErrorMessage extends StatelessWidget
{
  const ErrorMessage({
    super.key,
    this.message,
    this.statusCode,
    this.textColor = Utils.white,
  });
  final String? message;
  final int? statusCode;
  final Color textColor;

  String _localizedMessage(AppLocalizations l10n) {
    if (statusCode != null) {
      if (statusCode == 400 || statusCode == 404) return l10n.apiErrorLocationNotFound;
      if (statusCode == 401 || statusCode == 403) return l10n.apiErrorAuth;
      if (statusCode == 429) return l10n.apiErrorTooManyRequests;
      if (statusCode == 503) return l10n.apiErrorServiceUnavailable;
      if (statusCode! >= 500) return l10n.apiErrorServer;
    }
    return l10n.apiErrorDefault;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.dataErrorTitle,
            textAlign: TextAlign.center,
            style: textStyle['title2'],
          ),
          Text(
            _localizedMessage(l10n),
            textAlign: TextAlign.center,
            style: textStyle['body'],
          ),
          Text(
            l10n.dataErrorContact,
            textAlign: TextAlign.center,
            style: textStyle['body'],
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: (){},
                  child: LinkButton(
                    urlStr: Uri.encodeFull("mailto:${Env().devEmail}?subject=App Issue"),
                    child: Text(
                        l10n.mailContact,
                        style: textStyle['bodyHighlight']
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: (){},
                  child: LinkButton(
                    urlStr: Env().githubLink,
                    child: Text(
                      l10n.github,
                      style: textStyle['bodyHighlight'],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Main()),
                );
              },
              child: const Icon(Icons.refresh)
          )
        ],
      ),
    );
  }
}
