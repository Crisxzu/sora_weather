import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

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
      print('Use icon from memory cache: $cacheKey');
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
          print('Download icon : $url');

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

        // Mettre à jour le cache
        final image = Image.file(file);
        _memoryCache[cacheKey] = image;

        print('Icon fetched and cached: $cacheKey');
        return image;
      }
      else {
        print("Web version detected ");
        print("Fetch icon from: $url");
        return Image.network(url);
      }
    } catch (e) {
      print('Error when fetching icon: $e');
      // Retourner une icône par défaut en cas d'erreur
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
        print('Icons cache deleted');
      }

    } catch (e) {
      print('Error when clearing icons cache: $e');
    }
  }

  Future<void> preloadIcons(List<String> iconCodes, {bool isDay = true}) async {
    for (final iconCode in iconCodes) {
      await getWeatherIcon(iconCode, isDay: isDay);
    }
    print('${iconCodes.length} icônes préchargées');
  }
}