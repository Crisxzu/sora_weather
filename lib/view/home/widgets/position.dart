import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:weather_app/l10n/app_localizations.dart';

import '../../../common/utils.dart';
import '../../../controller/weather_data.dart';

class PositionView extends StatefulWidget {
  const PositionView({
    super.key,
  });

  @override
  State<PositionView> createState() => _PositionViewState();
}

class _PositionViewState extends State<PositionView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this, // Sync animation with the refresh of the screen
      duration: const Duration(milliseconds: 500),
    );

    // Icon opacity animation
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    _startBlinking();
  }

  Future<void> _startBlinking() async {
    await Future.delayed(const Duration(seconds: 2));

    // Prevent use of context if widget not mounted (on page change for example)
    if(!mounted) {
      return;
    }
    final WeatherDataController weatherDataController = Get.find();
    
    if (_controller.isAnimating || weatherDataController.data == null) {
      return;
    }

    _controller.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reset();
      }
    });
  }

  void _blinkIcon() {
    _controller.reset();
    _controller.forward();
  }

  void _handlePositionTap() {
    final WeatherDataController weatherDataController = Get.find();
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            style: textStyle['title2'],
            AppLocalizations.of(context)!.locationDialogTitle
          ),
          content: Obx(() => Text(
              style: textStyle['body'],
              weatherDataController.userPosition != null
                  ? AppLocalizations.of(context)!.locationProvided
                  : AppLocalizations.of(context)!.locationNotProvided
          )),
          actions: <Widget>[
            TextButton(
              child: Text(
                  style: textStyle['body'],
                  AppLocalizations.of(context)!.closeDialog
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                  style: textStyle['body'],
                  AppLocalizations.of(context)!.goToLocationSettings
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                // Redirect to app settings to set location permission
                await Geolocator.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final WeatherDataController weatherDataController = Get.find();
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Obx(() {
        if(weatherDataController.data == null) {
          return Container();
        }

        return SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: _handlePositionTap,
            child: Row(
              children: [
                Text(
                  weatherDataController.data!.location.name,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle['title2'],
                ),
                const SizedBox(width: 10,),
                ...[
                  if(weatherDataController.userPosition == null)
                    AnimatedBuilder(
                      animation: _opacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: const Icon(
                            Icons.location_disabled,
                          ),
                        );
                      },
                    )
                ],
              ],
            ),
          ),
        );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
