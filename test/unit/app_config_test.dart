import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ar_app/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('should initialize with default values', () async {
      await AppConfig.initialize();
      
      expect(AppConfig.environment, Environment.development);
      expect(AppConfig.enableLogging, true);
      expect(AppConfig.enableArFeatures, true);
    });
    
    test('should correctly identify development environment', () async {
      await AppConfig.initialize();
      
      expect(AppConfig.isDevelopment, true);
      expect(AppConfig.isProduction, false);
    });
  });
}
