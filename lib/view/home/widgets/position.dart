import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/providers/params.dart';

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
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            style: textStyle['title2'],
            AppLocalizations.of(context)!.locationDialogTitle
          ),
          content: Text(
              style: textStyle['body'],
              weatherProvider.userPosition != null
                  ? AppLocalizations.of(context)!.locationProvided
                  : AppLocalizations.of(context)!.locationNotProvided
          ),
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
            Text(
              weatherProvider.data!.location.name,
              overflow: TextOverflow.ellipsis,
              style: textStyle['title2'],
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
