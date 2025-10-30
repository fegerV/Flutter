import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_ar_app/data/services/cache_service.dart';

import 'cache_service_test.mocks.dart';

@GenerateMocks([CacheManager, SharedPreferences, Directory, File])
void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      cacheService = CacheService();
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Act & Assert
        expect(() async => await cacheService.initialize(), returnsNormally);
      });
    });

    group('cache size calculations', () {
      setUp(() async {
        await cacheService.initialize();
      });

      test('should return 0 for empty cache', () async {
        // Act
        final size = await cacheService.getCacheSize();

        // Assert
        expect(size, 0);
      });

      test('should return 0 for empty cache item count', () async {
        // Act
        final count = await cacheService.getCacheItemCount();

        // Assert
        expect(count, 0);
      });
    });

    group('cache operations', () {
      setUp(() async {
        await cacheService.initialize();
      });

      test('should handle cache cleanup', () async {
        // Act & Assert
        expect(() async => await cacheService.cleanupExpiredCache(), returnsNormally);
      });

      test('should handle cache size limit enforcement', () async {
        // Act & Assert
        expect(() async => await cacheService.enforceCacheSizeLimit(), returnsNormally);
      });

      test('should handle clear all cache', () async {
        // Act & Assert
        expect(() async => await cacheService.clearAllCache(), returnsNormally);
      });

      test('should handle remove cached animation', () async {
        // Act & Assert
        expect(() async => await cacheService.removeCachedAnimation('test_key'), returnsNormally);
      });

      test('should handle is animation cached check', () async {
        // Act
        final isCached = await cacheService.isAnimationCached('non_existent_key');

        // Assert
        expect(isCached, isFalse);
      });

      test('should handle get cached animation', () async {
        // Act
        final file = await cacheService.getCachedAnimation('non_existent_key');

        // Assert
        expect(file, isNull);
      });
    });

    group('last cleanup time', () {
      setUp(() async {
        await cacheService.initialize();
      });

      test('should get and update last cleanup time', () async {
        // Act
        final initialTime = await cacheService.getLastCleanupTime();
        await cacheService.updateLastCleanupTime();
        final updatedTime = await cacheService.getLastCleanupTime();

        // Assert
        expect(updatedTime.isAfter(initialTime) || updatedTime.isAtSameMomentAs(initialTime), isTrue);
      });

      test('should return default time for first run', () async {
        // Act
        SharedPreferences.setMockInitialValues({});
        final newCacheService = CacheService();
        await newCacheService.initialize();
        final time = await newCacheService.getLastCleanupTime();

        // Assert
        expect(time, isA<DateTime>());
      });
    });
  });
}