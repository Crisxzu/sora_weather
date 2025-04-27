import 'package:flutter/material.dart';

class Utils {
  static Color blue = const Color.fromRGBO(41, 75, 121, 1);
  static Color gray = const Color.fromRGBO(198, 206, 216, 1);
  static Color darkBlue = const Color.fromRGBO(28, 49, 104, 1);
  static Color white = Colors.white;
  static List<Color> blueGradientColors = [
    darkBlue,
    blue.withBlue(122).withGreen(73),
    blue
  ];

}