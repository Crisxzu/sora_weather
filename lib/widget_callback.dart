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
    await HomeWidget.updateWidget(androidName: 'WeatherWidgetProvider');

    final position = await HomeWidget.getWidgetData<String>('widget_last_position');
    final langIso = await HomeWidget.getWidgetData<String>('widget_lang_iso') ?? 'en';
    final unitName = await HomeWidget.getWidgetData<String>('widget_unit_name') ?? 'celsius';
    final tempUnit = Utils.tempUnits[unitName] ?? Utils.tempUnits['celsius']!;

    debugPrint('[WidgetCallback] Fetching data (position: $position, lang: $langIso)');

    AppLogger.initialize();

    final controller = WeatherDataController();
    final data = await controller.fetchApiWeatherData({
      'lang_iso': langIso,
      if (position != null) 'position': position,
    });

    // saveWidgetData remet widget_loading à false et met à jour le widget
    await controller.saveWidgetData(data, tempUnit, position: position, langIso: langIso);

    debugPrint('[WidgetCallback] Widget updated successfully');
  } catch (e) {
    debugPrint('[WidgetCallback] Error: $e');
    // Masquer l'overlay même en cas d'erreur
    await HomeWidget.saveWidgetData<bool>('widget_loading', false);
    await HomeWidget.updateWidget(androidName: 'WeatherWidgetProvider');
  }
}
