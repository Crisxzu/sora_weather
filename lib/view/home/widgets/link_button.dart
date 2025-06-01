import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_app/l10n/app_localizations.dart';

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
            print("Cannot open link: ${urlStr}");
            // Gérer le cas où l'URL ne peut pas être ouverte
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.linkError)),
            );
          }
        }
        catch(e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.linkError)),
          );
        }
      },
      child: child,
    );
  }
}