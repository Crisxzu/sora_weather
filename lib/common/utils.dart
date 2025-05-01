import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/model/condition.dart';

class Utils {
  static const Color blue = const Color.fromRGBO(41, 75, 121, 1);
  static const Color gray = const Color.fromRGBO(198, 206, 216, 1);
  static const Color darkBlue = const Color.fromRGBO(28, 49, 104, 1);
  static Color fadeDarkBlue = darkBlue.withOpacity(0.53);
  static const Color white = Colors.white;
  static List<Color> blueGradientColors = [
    darkBlue,
    blue.withBlue(122).withGreen(73),
    blue
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

  static Locale getUserLanguage(BuildContext context) {
    return Localizations.localeOf(context);
  }

  static String getDayOfWeek(int timestamp, Locale locale) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    print(locale.languageCode);

    final formatter = DateFormat('EEEE', locale.toString());
    return formatter.format(dateTime);
  }

  static String getHour(int timestamp, Locale locale) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    final formatter = DateFormat('jm', locale.toString());
    return formatter.format(dateTime);
  }

  static String makeTitle(String text) {
    if(text.length < 2) {
      return text.toUpperCase();
    }

    return "${text.substring(0, 1).toUpperCase()}${text.substring(1)}";
  }
}