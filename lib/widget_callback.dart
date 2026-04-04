import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:weather_app/common/app_logger.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/controller/weather_data.dart';

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri?.host != 'refresh') return;

  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint('[WidgetCallback] Refresh triggered');

    // Feedback immédiat : passer la temp à "..." le temps du fetch
    await HomeWidget.saveWidgetData<String>('widget_temp', '...');
    await HomeWidget.updateWidget(
      androidName: 'WeatherWidgetProvider',
    );

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

    await controller.saveWidgetData(data, tempUnit, position: position, langIso: langIso);

    debugPrint('[WidgetCallback] Widget updated successfully');
  } catch (e) {
    debugPrint('[WidgetCallback] Error: $e');
    // Remettre la dernière température connue
    await HomeWidget.updateWidget(
      androidName: 'WeatherWidgetProvider',
    );
  }
}
