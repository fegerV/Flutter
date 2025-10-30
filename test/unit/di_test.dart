import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'package:flutter_ar_app/core/di/injection_container.dart';

void main() {
  group('Dependency Injection Tests', () {
    setUpAll(() async {
      await configureDependencies();
    });

    test('should register Dio instance', () {
      final dio = getIt<Dio>();
      expect(dio, isNotNull);
      expect(dio, isA<Dio>());
    });

    test('should have correct Dio configuration', () {
      final dio = getIt<Dio>();
      expect(dio.options.connectTimeout, const Duration(seconds: 30));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
      expect(dio.options.sendTimeout, const Duration(seconds: 30));
    });
  });
}
