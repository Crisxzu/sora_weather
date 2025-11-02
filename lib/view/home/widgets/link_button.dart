import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

            if(!context.mounted) {
              return;
            }

            Get.snackbar(
                AppLocalizations.of(context)!.messageForYou,
                AppLocalizations.of(context)!.linkError
            );
          }
        }
        catch(e) {
          AppLogger.instance.e("Error happened when try to launch link: $urlStr");
          AppLogger.instance.e("Exception details : $e");

          if(!context.mounted) {
            return;
          }

          Get.snackbar(
              AppLocalizations.of(context)!.messageForYou,
              AppLocalizations.of(context)!.linkError
          );
        }
      },
      child: child,
    );
  }
}