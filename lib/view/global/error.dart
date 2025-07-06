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
    this.textColor = Utils.white,
  });
  final String? message;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.dataErrorTitle,
            textAlign: TextAlign.center,
            style: textStyle['title2'],
          ),
          ...[
            if(message != null)
              Text(message!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
          ],
          Text(
            AppLocalizations.of(context)!.dataErrorMessage,
            textAlign: TextAlign.center,
            style: textStyle['body'],
          ),
          Text(
            AppLocalizations.of(context)!.dataErrorContact,
            textAlign: TextAlign.center,
            style: textStyle['body']
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: (){},
                  child: LinkButton(
                    urlStr: Uri.encodeFull("mailto:${Env.devEmail}?subject=App Issue"),
                    child: Text(
                        AppLocalizations.of(context)!.mailContact,
                        style: textStyle['bodyHighlight']
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: (){},
                  child: LinkButton(
                    urlStr: Env.githubLink,
                    child: Text(
                      AppLocalizations.of(context)!.github,
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
