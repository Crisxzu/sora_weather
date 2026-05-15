import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/controller/weather_data.dart';

import 'common/app_logger.dart';

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri?.host != 'refresh') return;

  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint('[WidgetCallback] Refresh triggered');

    // Afficher l'overlay de chargement immédiatement
    await HomeWidget.saveWidgetData<bool>('widget_loading', true);
    await HomeWidget.updateWidget(
      androidName: 'WeatherWidgetProvider',
      iOSName: 'WeatherWidgetProvider',
    );

    final position = await HomeWidget.getWidgetData<String>('widget_last_position');
    final cityQuery = await HomeWidget.getWidgetData<String>('widget_city_query');
    final langIso = await HomeWidget.getWidgetData<String>('widget_lang_iso') ?? 'en';
    final unitName = await HomeWidget.getWidgetData<String>('widget_unit_name') ?? 'celsius';
    final tempUnit = Utils.tempUnits[unitName] ?? Utils.tempUnits['celsius']!;

    debugPrint('[WidgetCallback] Fetching data (city: $cityQuery, position: $position, lang: $langIso)');

    await AppLogger.initialize();

    final controller = WeatherDataController();
    final data = await controller.fetchApiWeatherData({
      'lang_iso': langIso,
      if (cityQuery != null) 'city': cityQuery
      else if (position != null) 'position': position,
    });

    await controller.saveWidgetData(data, tempUnit, position: position, city: cityQuery, langIso: langIso);

    debugPrint('[WidgetCallback] Widget updated successfully');
  } catch (e) {
    debugPrint('[WidgetCallback] Error: $e');
    // Masquer l'overlay même en cas d'erreur
    await HomeWidget.saveWidgetData<bool>('widget_loading', false);
    await HomeWidget.updateWidget(
      androidName: 'WeatherWidgetProvider',
      iOSName: 'WeatherWidgetProvider',
    );
  }
}
