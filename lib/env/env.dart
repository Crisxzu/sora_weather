import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'WEATHER_API_KEY', obfuscate: true)
  static String apiKey = _Env.apiKey;

  @EnviedField(varName: 'WEATHER_API_LINK', obfuscate: true)
  static String apiLink = _Env.apiLink;

  @EnviedField(varName: 'BASE_ICON_URL')
  static const String baseIconUrl = _Env.baseIconUrl;

  @EnviedField(varName: 'PORTFOLIO_LINK')
  static const String portfolioLink = _Env.portfolioLink;

  @EnviedField(varName: 'DEBUG_MODE')
  static const String debugMode = _Env.debugMode;

  @EnviedField(varName: 'DEV_EMAIL')
  static const String devEmail = _Env.devEmail;

  @EnviedField(varName: 'GITHUB_LINK')
  static const String githubLink = _Env.githubLink;
}