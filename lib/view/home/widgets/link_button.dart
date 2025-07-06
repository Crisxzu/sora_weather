import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_app/l10n/app_localizations.dart';

import '../../../common/app_logger.dart';

class LinkButton extends StatelessWidget {
  const LinkButton({
    super.key,
    required this.urlStr,
    this.child
  });
  final String urlStr;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(urlStr);
        try {
          if (!await launchUrl(url)) {
            AppLogger.instance.i("Cannot open link: $urlStr");

            // Prevent snackbar to be shown if widget not mounted (on page change for example)
            if(!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.linkError)),
            );
          }
        }
        catch(e) {
          // Prevent snackbar to be shown if widget not mounted (on page change for example)
          if(!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.linkError)),
          );
        }
      },
      child: child,
    );
  }
}