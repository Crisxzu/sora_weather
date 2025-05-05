import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/l10n/l10n.dart';


class ParamsProvider extends ChangeNotifier with WidgetsBindingObserver {
  TempUnit? _tempUnit;
  int? _updateTimeLimit;
  Locale? _locale;
  bool _useSystemLocale = true;
  Timer? _timer;
  TempUnit? get tempUnit => _tempUnit;
  int? get updateTimeLimit => _updateTimeLimit;
  Locale? get locale => _locale;
  bool get isSystemLocal => _useSystemLocale;
  final paramsData = Hive.box("appParams");
  GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  ParamsProvider() {
    var unit = paramsData.get('tempUnit');

    if(unit == null || !Utils.tempUnits.containsKey(unit)) {
      print("Cannot find unit $unit in supported units. Celsius selected by default");
      tempUnit = Utils.tempUnits['celsius'];
    }
    else {
      tempUnit = Utils.tempUnits[unit];
    }

    var timeLimitIndex = paramsData.get("updateTimeLimit");


    if(timeLimitIndex == null || !(timeLimitIndex >= 0 && timeLimitIndex < Utils.supportedUpdateTimeLimit.length)) {
      print("Cannot get update time limit");
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
    // Se désinscrire quand le provider est disposé
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    print("System change locale");
    print(_useSystemLocale);
    print(locales);
    // Cette méthode est appelée quand la locale système change
    if (_useSystemLocale && locales != null && locales.isNotEmpty) {
      _updateToSystemLocale(locales.first);
    }
  }

  void _updateToSystemLocale(Locale systemLocale) {
    if (_isSupported(systemLocale)) {
      locale = systemLocale;
      paramsData.put('locale', 'system');
      notifyListeners();
      refreshIndicatorKey!.currentState!.show();
    }
  }

  void initializeLocale({bool forceSystem = false}) {
    var languageCode = paramsData.get("locale");
    print(languageCode);

    if(languageCode == null || forceSystem || languageCode == 'system') {
      print("Cannot get saved locale or system language use.");
      _useSystemLocale = true;
      final List<Locale> systemLocales = WidgetsBinding.instance.platformDispatcher.locales;

      if (systemLocales.isNotEmpty) {
        // Vérifier si la langue du système est supportée
        final systemLocale = systemLocales.first;
        if (_isSupported(systemLocale)) {
          locale = systemLocale;
          paramsData.put('locale', 'system');
          notifyListeners();
        } else {
          // Si la langue système n'est pas supportée, utiliser le français par défaut
          locale = const Locale('en');
        }
      } else {
        // Fallback sur le français si aucune locale système n'est disponible
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
    _timer = Timer.periodic(
      Duration(minutes: Utils.supportedUpdateTimeLimit[_updateTimeLimit!]),
          (_) => _onTimerTick(),
    );
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  void _onTimerTick() {
    // Notifier les listeners qu'une mise à jour est nécessaire
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer() {
    if (_timer == null || !_timer!.isActive) {
      _startTimer();
      notifyListeners();
    }
  }

  set updateTimeLimit(int? index) {
    _updateTimeLimit = index;
    paramsData.put('updateTimeLimit', index);
    _restartTimer();
    notifyListeners();
  }

  set tempUnit(TempUnit? newValue) {
    _tempUnit = newValue;
    paramsData.put('tempUnit', newValue!.name);
    notifyListeners();
  }

  set locale(Locale? newValue) {
    print("new value $newValue");
    _locale = newValue;
    paramsData.put('locale', newValue!.languageCode);
    notifyListeners();
  }

  set isSystemLocal(bool newValue) {
    _useSystemLocale = newValue;
  }
}
