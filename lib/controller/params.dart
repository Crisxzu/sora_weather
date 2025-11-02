import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../common/app_logger.dart';
import '../common/utils.dart';
import '../l10n/l10n.dart';
import 'weather_data.dart';

class ParamsController extends GetxController with WidgetsBindingObserver {
  final Rx<TempUnit?> _tempUnit = Rx<TempUnit?>(null);
  final Rx<int?> _updateTimeLimit = Rx<int?>(null);
  final Rx<Locale?> _locale = Rx<Locale?>(null);
  bool _useSystemLocale = true;
  final Rx<Timer?> _timer = Rx<Timer?>(null);
  TempUnit? get tempUnit => _tempUnit.value;
  int? get updateTimeLimit => _updateTimeLimit.value;
  Locale? get locale => _locale.value;
  bool get isSystemLocal => _useSystemLocale;
  final paramsData = Hive.box("appParams");
  GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  ParamsController() {
    var unit = paramsData.get('tempUnit');

    if(unit == null || !Utils.tempUnits.containsKey(unit)) {
      AppLogger.instance.i("Cannot find unit $unit in supported units. Celsius selected by default");
      tempUnit = Utils.tempUnits['celsius'];
    }
    else {
      tempUnit = Utils.tempUnits[unit];
    }

    var timeLimitIndex = paramsData.get("updateTimeLimit");


    if(timeLimitIndex == null || !(timeLimitIndex >= 0 && timeLimitIndex < Utils.supportedUpdateTimeLimit.length)) {
      AppLogger.instance.i("Cannot get update time limit");
      updateTimeLimit = 0;
    }
    else {
      updateTimeLimit = timeLimitIndex;
    }

    initializeLocale();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    // Remove observer when provider disposed
    WidgetsBinding.instance.removeObserver(this);
    _timer.value?.cancel();
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    AppLogger.instance.d("System change locale");
    AppLogger.instance.d(_useSystemLocale);
    AppLogger.instance.d(locales.toString());

    // Call when locale language change
    if (_useSystemLocale && locales != null && locales.isNotEmpty) {
      _updateToSystemLocale(locales.first);
    }
  }

  void _updateToSystemLocale(Locale systemLocale) {
    if (_isSupported(systemLocale)) {
      locale = systemLocale;
      paramsData.put('locale', 'system');
      //notifyListeners();
      refreshIndicatorKey?.currentState!.show();
    }
  }

  void initializeLocale({bool forceSystem = false}) {
    var languageCode = paramsData.get("locale");
    AppLogger.instance.d(languageCode);

    if(languageCode == null || forceSystem || languageCode == 'system') {
      AppLogger.instance.i("Cannot get saved locale or system language use.");
      _useSystemLocale = true;
      final List<Locale> systemLocales = WidgetsBinding.instance.platformDispatcher.locales;

      if (systemLocales.isNotEmpty) {
        // Check if system language is supported
        final systemLocale = systemLocales.first;
        if (_isSupported(systemLocale)) {
          locale = systemLocale;
          paramsData.put('locale', 'system');
          //notifyListeners();
        } else {
          // If not supported, use english
          locale = const Locale('en');
        }
      } else {
        // Fallback on english, if no system language available
        locale = const Locale('en');
      }
    }
    else {
      _useSystemLocale = false;
      locale = Locale(languageCode);
    }
  }

  bool _isSupported(Locale locale) {
    return L10n.supportedLocales
        .map((e) => e.languageCode)
        .contains(locale.languageCode);
  }

  Future<Locale> useSystemLocale() async {
    _useSystemLocale = true;
    final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
    if (systemLocales.isNotEmpty) {
      _updateToSystemLocale(systemLocales.first);
      return systemLocales.first;
    }

    return locale!;
  }


  void _startTimer() {
    _timer.value = Timer.periodic(
      Duration(minutes: Utils.supportedUpdateTimeLimit[_updateTimeLimit.value!]),
          (_) => _onTimerTick(),
    );
  }

  void _restartTimer() {
    _timer.value?.cancel();
    _startTimer();
  }

  void _onTimerTick() async {
    // Notify listeners if update necessary
    WeatherDataController weatherData = Get.find();
    await weatherData.fetchData(locale!.languageCode);
    //notifyListeners();
  }

  void pauseTimer() {
    _timer.value?.cancel();
    _timer.refresh();
    //notifyListeners();
  }

  void resumeTimer() {
    if (_timer.value == null || !_timer.value!.isActive) {
      _startTimer();
      //notifyListeners();
    }
  }

  set updateTimeLimit(int? index) {
    paramsData.put('updateTimeLimit', index);
    _updateTimeLimit.value = index;
    _restartTimer();
    //notifyListeners();
  }

  set tempUnit(TempUnit? newValue) {
    paramsData.put('tempUnit', newValue!.name);
    _tempUnit.value = newValue;
    //notifyListeners();
  }

  set locale(Locale? newValue) {
    AppLogger.instance.d("new value $newValue");
    paramsData.put('locale', newValue!.languageCode);
    _locale.value = newValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(newValue);
    });
    //notifyListeners();
  }

  set isSystemLocal(bool newValue) {
    _useSystemLocale = newValue;
  }
}