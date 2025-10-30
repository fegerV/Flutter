import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, production }

class AppConfig {
  static late Environment _environment;
  static late String _apiBaseUrl;
  static late String _authTokenEndpoint;
  static late String _authRefreshEndpoint;
  static late bool _enableLogging;
  static late bool _enableArFeatures;
  static late String _minioEndpoint;
  static late int _minioPort;
  static late String _minioAccessKey;
  static late String _minioSecretKey;
  static late bool _minioUseSSL;
  static late String _minioBucket;

  static Environment get environment => _environment;
  static String get apiBaseUrl => _apiBaseUrl;
  static String get authTokenEndpoint => _authTokenEndpoint;
  static String get authRefreshEndpoint => _authRefreshEndpoint;
  static bool get enableLogging => _enableLogging;
  static bool get enableArFeatures => _enableArFeatures;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isProduction => _environment == Environment.production;
  
  static String get minioEndpoint => _minioEndpoint;
  static int get minioPort => _minioPort;
  static String get minioAccessKey => _minioAccessKey;
  static String get minioSecretKey => _minioSecretKey;
  static bool get minioUseSSL => _minioUseSSL;
  static String get minioBucket => _minioBucket;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    
    final env = dotenv.env['ENVIRONMENT'] ?? 'development';
    _environment = env == 'production' ? Environment.production : Environment.development;
    
    _apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
    _authTokenEndpoint = dotenv.env['AUTH_TOKEN_ENDPOINT'] ?? '/auth/token';
    _authRefreshEndpoint = dotenv.env['AUTH_REFRESH_ENDPOINT'] ?? '/auth/refresh';
    _enableLogging = dotenv.env['ENABLE_LOGGING'] == 'true';
    _enableArFeatures = dotenv.env['ENABLE_AR_FEATURES'] == 'true';
    
    _minioEndpoint = dotenv.env['MINIO_ENDPOINT'] ?? 'play.min.io';
    _minioPort = int.tryParse(dotenv.env['MINIO_PORT'] ?? '9000') ?? 9000;
    _minioAccessKey = dotenv.env['MINIO_ACCESS_KEY'] ?? '';
    _minioSecretKey = dotenv.env['MINIO_SECRET_KEY'] ?? '';
    _minioUseSSL = dotenv.env['MINIO_USE_SSL'] == 'true';
    _minioBucket = dotenv.env['MINIO_BUCKET'] ?? 'ar-animations';
  }
}
