import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_ar_app/presentation/widgets/cache_status_widget.dart';
import 'package:flutter_ar_app/presentation/providers/cache_provider.dart';
import 'package:flutter_ar_app/domain/entities/cache_info.dart';

void main() {
  group('CacheStatusWidget', () {
    testWidgets('should display loading state', (WidgetTester tester) async {
      // Arrange
      const cacheState = CacheState.loading();

      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) {
                  return CacheStatusWidget(cacheState: cacheState);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No cache data available'), findsNothing);
    });

    testWidgets('should display loaded state with cache info', (WidgetTester tester) async {
      // Arrange
      final cacheInfo = CacheInfo(
        totalSize: 100000000, // 100MB
        usedSize: 50000000, // 50MB
        itemCount: 10,
        lastCleanup: DateTime.now(),
        maxSizeLimit: 500000000, // 500MB
        ttl: const Duration(days: 7),
      );
      const cacheState = CacheState.loaded(cacheInfo);

      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) {
                  return CacheStatusWidget(cacheState: cacheState);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Storage Usage'), findsOneWidget);
      expect(find.textContaining('50.0 MB'), findsOneWidget);
      expect(find.textContaining('500.0 MB'), findsOneWidget);
      expect(find.textContaining('10'), findsOneWidget);
      expect(find.textContaining('50.0%'), findsOneWidget);
      expect(find.textContaining('7d'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (WidgetTester tester) async {
      // Arrange
      const cacheState = CacheState.error('Cache error occurred');

      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) {
                  return CacheStatusWidget(cacheState: cacheState);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('Cache error occurred'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('should display warning when cache is near limit', (WidgetTester tester) async {
      // Arrange
      final cacheInfo = CacheInfo(
        totalSize: 450000000, // 450MB (90% of 500MB limit)
        usedSize: 450000000,
        itemCount: 90,
        lastCleanup: DateTime.now(),
        maxSizeLimit: 500000000, // 500MB
        ttl: const Duration(days: 7),
      );
      const cacheState = CacheState.loaded(cacheInfo);

      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) {
                  return CacheStatusWidget(cacheState: cacheState);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Cache approaching limit'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('should display error when cache is over limit', (WidgetTester tester) async {
      // Arrange
      final cacheInfo = CacheInfo(
        totalSize: 550000000, // 550MB (over 500MB limit)
        usedSize: 550000000,
        itemCount: 110,
        lastCleanup: DateTime.now(),
        maxSizeLimit: 500000000, // 500MB
        ttl: const Duration(days: 7),
      );
      const cacheState = CacheState.loaded(cacheInfo);

      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) {
                  return CacheStatusWidget(cacheState: cacheState);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Cache over limit'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should format file sizes correctly', (WidgetTester tester) async {
      // Arrange
      final cacheInfo = CacheInfo(
        totalSize: 1024, // 1KB
        usedSize: 512, // 512B
        itemCount: 1,
        lastCleanup: DateTime.now(),
        maxSizeLimit: 2048, // 2KB
        ttl: const Duration(days: 7),
      );
      const cacheState = CacheState.loaded(cacheInfo);

      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) {
                  return CacheStatusWidget(cacheState: cacheState);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('512.0 B'), findsOneWidget);
      expect(find.textContaining('2.0 KB'), findsOneWidget);
    });
  });
}