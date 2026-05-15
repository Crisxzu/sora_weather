import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/providers/location.dart';

import '../../../common/utils.dart';
import '../../../providers/weather_data.dart';

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

    final weatherProvider = Provider.of<WeatherDataProvider>(context, listen: false);

    if (_controller.isAnimating || weatherProvider.data == null) {
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
    final weatherProvider = Provider.of<WeatherDataProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);
    final l10n = AppLocalizations.of(context)!;
    final activeLocation = locationProvider.activeLocation;
    final isGpsMode = activeLocation.isGps;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final String message;
        final bool showLocationSettings;

        if (!isGpsMode) {
          message = l10n.locationCityMode(activeLocation.displayName);
          showLocationSettings = false;
        } else if (weatherProvider.userPosition != null) {
          message = l10n.locationProvided;
          showLocationSettings = false;
        } else {
          message = l10n.locationNotProvided;
          showLocationSettings = true;
        }

        return AlertDialog(
          title: Text(l10n.locationDialogTitle, style: textStyle['title2']),
          content: Text(message, style: textStyle['body']),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.closeDialog, style: textStyle['body']),
            ),
            if (showLocationSettings)
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openAppSettings();
                },
                child: Text(l10n.goToLocationSettings, style: textStyle['body']),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherDataProvider>(context);
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    if(weatherProvider.data == null) {
      return Container();
    }

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _handlePositionTap,
        child: Row(
          children: [
            Flexible(
              child: Text(
                weatherProvider.data!.location.name,
                overflow: TextOverflow.ellipsis,
                style: textStyle['title2'],
              ),
            ),
            const SizedBox(width: 10,),
            ...[
              if(weatherProvider.userPosition == null)
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
