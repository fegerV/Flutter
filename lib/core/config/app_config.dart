import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, production }

class AppConfig {
  static late Environment _environment;
  static late String _apiBaseUrl;
  static late bool _enableLogging;
  static late bool _enableArFeatures;

  static Environment get environment => _environment;
  static String get apiBaseUrl => _apiBaseUrl;
  static bool get enableLogging => _enableLogging;
  static bool get enableArFeatures => _enableArFeatures;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isProduction => _environment == Environment.production;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    
    final env = dotenv.env['ENVIRONMENT'] ?? 'development';
    _environment = env == 'production' ? Environment.production : Environment.development;
    
    _apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
    _enableLogging = dotenv.env['ENABLE_LOGGING'] == 'true';
    _enableArFeatures = dotenv.env['ENABLE_AR_FEATURES'] == 'true';
  }
}
