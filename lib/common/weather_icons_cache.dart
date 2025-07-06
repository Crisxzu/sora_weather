import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:weather_app/common/app_logger.dart';

import '../env/env.dart';

class WeatherIconsCache {
  static final WeatherIconsCache _instance = WeatherIconsCache._internal();
  factory WeatherIconsCache() => _instance;
  WeatherIconsCache._internal();

  final Map<String, Image> _memoryCache = {};
  final String baseIconUrl = Env.baseIconUrl;

  Future<Image> getWeatherIcon(String iconCode, {bool isDay = true}) async {
    final String cacheKey = '${iconCode}_${isDay ? 'day' : 'night'}';

    // Vérifier si l'icône est déjà en mémoire
    if (_memoryCache.containsKey(cacheKey)) {
      AppLogger.instance.i('Use icon from memory cache: $cacheKey');
      return _memoryCache[cacheKey]!;
    }

    // Si pas en cache, récupérer l'icône
    return await _fetchAndCacheIcon(iconCode, isDay, cacheKey);
  }

  // Obtenir l'icône et la mettre en cache
  Future<Image> _fetchAndCacheIcon(String iconCode, bool isDay, String cacheKey) async {
    try {
      // Construire l'URL
      final String timeOfDay = isDay ? 'day' : 'night';
      final String url = '$baseIconUrl/$timeOfDay/$iconCode.png';

      if(!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/weather_icons/$cacheKey.png';
        final file = File(filePath);

        if(!await file.exists())
        {
          AppLogger.instance.i('Download icon : $url');

          // Télécharger l'image
          final response = await http.get(Uri.parse(url));

          if (response.statusCode != 200) {
            throw Exception('Download of icon failed: ${response.statusCode}');
          }

          // Créer le dossier si nécessaire
          final iconDir = Directory('${directory.path}/weather_icons');
          if (!await iconDir.exists()) {
            await iconDir.create(recursive: true);
          }

          await file.writeAsBytes(response.bodyBytes);
        }

        for(int i = 0; i < 3; i++) {
          try {
            // Mettre à jour le cache
            final image = Image.file(file);
            _memoryCache[cacheKey] = image;

            AppLogger.instance.i('Icon fetched and cached: $cacheKey');
            return image;
          }
          on StateError catch(e) {
            AppLogger.instance.e('Exception when getting icon : $e');
            await Future.delayed(const Duration(seconds: 3));
            continue;
          }
        }

        return Future.error('Image file cannot be fetched');
      }
      else {
        AppLogger.instance.i("Web version detected ");
        AppLogger.instance.i("Fetch icon from: $url");
        return Image.network(url);
      }
    } catch (e) {
      AppLogger.instance.e('Error when fetching icon: $e');

      return Image.asset('assets/images/default_weather_icon.png');
    }
  }

  Future<void> clearCache() async {
    _memoryCache.clear();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final iconDir = Directory('${directory.path}/weather_icons');

      if (await iconDir.exists()) {
        await iconDir.delete(recursive: true);
        AppLogger.instance.i('Icons cache deleted');
      }

    } catch (e) {
      AppLogger.instance.e('Error when clearing icons cache: $e');
    }
  }

  Future<void> preloadIcons(List<String> iconCodes, {bool isDay = true}) async {
    for (final iconCode in iconCodes) {
      await getWeatherIcon(iconCode, isDay: isDay);
    }
    AppLogger.instance.i('${iconCodes.length} icônes préchargées');
  }
}