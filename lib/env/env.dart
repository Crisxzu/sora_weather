import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envied(path: '.env', name: 'DebugEnv')
@Envied(path: '.env.prod', name: 'ProductionEnv')
final class Env {
  factory Env() => _instance;

  static final Env _instance = kReleaseMode ? _ProductionEnv() : _DebugEnv();

  @EnviedField(varName: 'WEATHER_API_KEY', obfuscate: true)
  final String apiKey = _instance.apiKey;

  @EnviedField(varName: 'WEATHER_API_LINK', obfuscate: true)
  final String apiLink = _instance.apiLink;

  @EnviedField(varName: 'BASE_ICON_URL')
  final String baseIconUrl = _instance.baseIconUrl;

  @EnviedField(varName: 'PORTFOLIO_LINK')
  final String portfolioLink = _instance.portfolioLink;

  @EnviedField(varName: 'DEBUG_MODE', defaultValue: '0')
  final String debugMode = _instance.debugMode;

  @EnviedField(varName: 'DEV_EMAIL')
  final String devEmail = _instance.devEmail;

  @EnviedField(varName: 'GITHUB_LINK')
  final String githubLink = _instance.githubLink;
}
