import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envied(path: '.env', name: 'DebugEnv', obfuscate: true)
abstract class _DebugEnv {
  @EnviedField(varName: 'WEATHER_API_KEY')
  static String apiKey = _DebugEnv.apiKey;

  @EnviedField(varName: 'WEATHER_API_LINK')
  static String apiLink = _DebugEnv.apiLink;

  @EnviedField(varName: 'BASE_ICON_URL', obfuscate: false)
  static const String baseIconUrl = _DebugEnv.baseIconUrl;

  @EnviedField(varName: 'PORTFOLIO_LINK', obfuscate: false)
  static const String portfolioLink = _DebugEnv.portfolioLink;

  @EnviedField(varName: 'DEBUG_MODE', obfuscate: false)
  static const String debugMode = _DebugEnv.debugMode;

  @EnviedField(varName: 'DEV_EMAIL', obfuscate: false)
  static const String devEmail = _DebugEnv.devEmail;

  @EnviedField(varName: 'GITHUB_LINK', obfuscate: false)
  static const String githubLink = _DebugEnv.githubLink;
}

@Envied(path: '.env.prod', name: 'ProdEnv', obfuscate: true)
abstract class _ProdEnv {
  @EnviedField(varName: 'WEATHER_API_KEY')
  static String apiKey = _ProdEnv.apiKey;

  @EnviedField(varName: 'WEATHER_API_LINK')
  static String apiLink = _ProdEnv.apiLink;

  @EnviedField(varName: 'BASE_ICON_URL', obfuscate: false)
  static const String baseIconUrl = _ProdEnv.baseIconUrl;

  @EnviedField(varName: 'PORTFOLIO_LINK', obfuscate: false)
  static const String portfolioLink = _ProdEnv.portfolioLink;

  @EnviedField(varName: 'DEBUG_MODE', obfuscate: false)
  static const String debugMode = _ProdEnv.debugMode;

  @EnviedField(varName: 'DEV_EMAIL', obfuscate: false)
  static const String devEmail = _ProdEnv.devEmail;

  @EnviedField(varName: 'GITHUB_LINK', obfuscate: false)
  static const String githubLink = _ProdEnv.githubLink;
}

abstract class Env {
  static String get apiKey => kReleaseMode ? _ProdEnv.apiKey : _DebugEnv.apiKey;
  static String get apiLink => kReleaseMode ? _ProdEnv.apiLink : _DebugEnv.apiLink;
  static String get baseIconUrl => kReleaseMode ? _ProdEnv.baseIconUrl : _DebugEnv.baseIconUrl;
  static String? get portfolioLink => kReleaseMode ? _ProdEnv.portfolioLink : _DebugEnv.portfolioLink;
  static String get debugMode => kReleaseMode ? _ProdEnv.debugMode : _DebugEnv.debugMode;
  static String get devEmail => kReleaseMode ? _ProdEnv.devEmail : _DebugEnv.devEmail;
  static String get githubLink => kReleaseMode ? _ProdEnv.githubLink : _DebugEnv.githubLink;
}
