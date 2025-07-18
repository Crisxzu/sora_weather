import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_logger.dart';

class Utils {
  static const Color blue = const Color.fromRGBO(41, 75, 121, 1);
  static const Color gray = const Color.fromRGBO(198, 206, 216, 1);
  static const Color darkBlue = const Color.fromRGBO(28, 49, 104, 1);
  static Color fadeDarkBlue = darkBlue.withValues(alpha: 0.53);
  static const Color white = Colors.white;
  static List<Color> blueGradientColors = [
    darkBlue,
    blue.withBlue(122).withGreen(73),
    blue
  ];
  static const lgBreakpoint = 1024;
  static const xlBreakpoint = 1280;
  static const twoXlBreakpoint = 1536;

  static Map<String, TempUnit> tempUnits = {
    'celsius': TempUnit(unit: "ºC", name: 'celsius', convert: (value) => value),
    'fahrenheit': TempUnit(unit: "ºF", name: 'fahrenheit', convert: (value) => ((value * 1.8) + 32).round())
  };

  static List<int> supportedUpdateTimeLimit = [
    15,
    30,
    60,
  ];


  static Map<String, TextStyle> mobileTextStyle = {
    'header': GoogleFonts.roboto(
        fontSize: 64,
        fontWeight: FontWeight.bold
    ),
    'title1': GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold
    ),
    'title2': GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold
    ),
    'bodyHighlight': GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.bold
    ),
    'body': GoogleFonts.roboto(
        fontSize: 16
    )
  };


  static Map<String, TextStyle> desktopTextStyle = {
    'header': GoogleFonts.roboto(
        fontSize: 72,
        fontWeight: FontWeight.bold
    ),
    'title1': GoogleFonts.roboto(
        fontSize: 40,
        fontWeight: FontWeight.bold
    ),
    'title2': GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold
    ),
    'bodyHighlight': GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold
    ),
    'body': GoogleFonts.roboto(
        fontSize: 24
    )
  };

  static Map<String, TextStyle> getTextStyle(double screenWidth) {
    if(screenWidth < lgBreakpoint) {
      return mobileTextStyle;
    }
    else {
      return desktopTextStyle;
    }
  }

  static Locale getUserLanguage(BuildContext context) {
    return Localizations.localeOf(context);
  }

  static String getDayOfWeek(int timestamp, Locale locale) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    final formatter = DateFormat('EEEE', locale.toString());
    return formatter.format(dateTime);
  }

  static String getHour(int timestamp, Locale locale) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    final formatter = DateFormat('jm', locale.toString());
    return formatter.format(dateTime);
  }

  static String getDate(int timestamp, Locale locale) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    final formatter = DateFormat.yMd(locale.toString()).add_jm();
    return formatter.format(dateTime);
  }

  static String makeTitle(String text) {
    if(text.length < 2) {
      return text.toUpperCase();
    }

    return "${text.substring(0, 1).toUpperCase()}${text.substring(1)}";
  }

  static String getLanguageName(BuildContext context, Locale locale) {
    return LocaleNames.of(context)!.nameOf(locale.toString())!;
  }

  static Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      AppLogger.instance.e('Location services are disabled.');

      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        AppLogger.instance.e('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      AppLogger.instance.e('Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static bool checkIfDesktop() {
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows) {
      return true;
    } else {
      return false;
    }
  }
}

class TempUnit {
  TempUnit({
    required this.unit,
    required this.name,
    required this.convert,
  });

  final String unit;
  final String name;
  int Function(int) convert;

  String toStr(int value) {
    return "${convert(value)}º";
  }
}