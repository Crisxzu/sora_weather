import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/utils.dart';
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
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.dataErrorTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: textColor
            ),
          ),
          ...[
            if(message != null)
              Text(message!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
          ],
          Text(
            AppLocalizations.of(context)!.dataErrorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: textColor
            ),
          ),
          Text(
              AppLocalizations.of(context)!.dataErrorContact,
            textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: textColor
              )
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
