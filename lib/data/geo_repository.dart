import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:weather_app/model/geo/geo_city.dart';
import 'package:weather_app/model/geo/geo_country.dart';
import 'package:weather_app/model/geo/geo_state.dart';

class GeoRepository {
  GeoRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static final GeoRepository instance = GeoRepository();

  final AssetBundle _bundle;

  List<GeoCountry>? _countries;
  final Map<String, List<GeoState>> _statesCache = {};
  final Map<String, List<GeoCity>> _citiesCache = {};
  final Map<String, Future<List<GeoState>>> _statesInflight = {};
  final Map<String, Future<List<GeoCity>>> _citiesInflight = {};

  Future<List<GeoCountry>> countries() async {
    if (_countries != null) return _countries!;
    final raw = await _bundle.loadString('assets/geo/countries.json');
    _countries = (jsonDecode(raw) as List)
        .map((e) => GeoCountry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
    return _countries!;
  }

  Future<List<GeoState>> statesOf(String iso2) {
    final key = iso2.toUpperCase();
    final cached = _statesCache[key];
    if (cached != null) return Future.value(cached);
    return _statesInflight.putIfAbsent(key, () async {
      try {
        final raw = await _bundle.loadString('assets/geo/states/$key.json');
        final list = (jsonDecode(raw) as List)
            .map((e) => GeoState.fromJson(Map<String, dynamic>.from(e as Map), countryIso2: key))
            .toList(growable: false);
        _statesCache[key] = list;
        return list;
      } catch (_) {
        _statesCache[key] = const [];
        return const [];
      } finally {
        _statesInflight.remove(key);
      }
    });
  }

  Future<List<GeoCity>> citiesOf(String iso2) {
    final key = iso2.toUpperCase();
    final cached = _citiesCache[key];
    if (cached != null) return Future.value(cached);
    return _citiesInflight.putIfAbsent(key, () async {
      try {
        final raw = await _bundle.loadString('assets/geo/cities/$key.json');
        final list = (jsonDecode(raw) as List)
            .map((e) => GeoCity.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false);
        _citiesCache[key] = list;
        return list;
      } catch (_) {
        _citiesCache[key] = const [];
        return const [];
      } finally {
        _citiesInflight.remove(key);
      }
    });
  }

  /// Searches cities across the whole country. Returns matches capped at [limit],
  /// prefix matches first, then contains, each group alphabetical.
  Future<List<({GeoCity city, GeoState state})>> searchCities({
    required String iso2,
    required String query,
    int limit = 30,
  }) async {
    if (query.isEmpty) return const [];
    final q = query.toLowerCase();

    final states = await statesOf(iso2);
    final cities = await citiesOf(iso2);
    if (cities.isEmpty) return const [];

    final stateById = {for (final s in states) s.id: s};

    final results = <({GeoCity city, GeoState state})>[];
    for (final city in cities) {
      if (city.name.toLowerCase().contains(q)) {
        final state = stateById[city.stateId];
        if (state != null) results.add((city: city, state: state));
      }
      if (results.length >= limit * 2) break;
    }

    results.sort((a, b) {
      final aN = a.city.name.toLowerCase();
      final bN = b.city.name.toLowerCase();
      final aP = aN.startsWith(q);
      final bP = bN.startsWith(q);
      if (aP != bP) return aP ? -1 : 1;
      return a.city.name.compareTo(b.city.name);
    });

    return results.length > limit ? results.sublist(0, limit) : results;
  }

  void clearCache() {
    _countries = null;
    _statesCache.clear();
    _citiesCache.clear();
  }
}
