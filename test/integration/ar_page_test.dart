import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_ar_app/presentation/pages/ar/ar_page.dart';
import 'package:flutter_ar_app/presentation/providers/ar_provider.dart';
import 'package:flutter_ar_app/domain/repositories/ar_repository.dart';
import 'package:flutter_ar_app/domain/entities/ar_entities.dart';

import 'mocks/mock_ar_repository.dart';

void main() {
  group('ArPage Integration Tests', () {
    late MockArRepository mockRepository;

    setUp(() {
      mockRepository = MockArRepository();
    });

    setUpAll(() {
      ScreenUtil.init(
        testWidgetsFlutterBinding.window,
        size: const Size(375, 812),
        minTextAdapt: true,
      );
    });

    testWidgets('should display loading state initially', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            arNotifierProvider.overrideWith(
              (ref) => ArNotifier(mockRepository),
            ),
          ],
          child: const MaterialApp(
            home: ArPage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display permission denied state', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.isCameraPermissionGranted())
          .thenAnswer((_) async => false);
      when(mockRepository.requestCameraPermission())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            arNotifierProvider.overrideWith(
              (ref) => ArNotifier(mockRepository),
            ),
          ],
          child: const MaterialApp(
            home: ArPage(),
          ),
        ),
      );

      // Wait for permission check
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Camera Permission Required'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display device unsupported state', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.isCameraPermissionGranted())
          .thenAnswer((_) async => true);
      when(mockRepository.checkDeviceCompatibility())
          .thenAnswer((_) async => const ArDeviceCompatibility(
                isSupported: false,
                reason: 'Device does not support ARCore',
                requiresArCore: true,
              ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            arNotifierProvider.overrideWith(
              (ref) => ArNotifier(mockRepository),
            ),
          ],
          child: const MaterialApp(
            home: ArPage(),
          ),
        ),
      );

      // Wait for checks to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Device Not Supported'), findsOneWidget);
      expect(find.text('Device does not support ARCore'), findsOneWidget);
    });

    testWidgets('should display AR content when ready', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.isCameraPermissionGranted())
          .thenAnswer((_) async => true);
      when(mockRepository.checkDeviceCompatibility())
          .thenAnswer((_) async => const ArDeviceCompatibility(
                isSupported: true,
                requiresArCore: true,
              ));
      when(mockRepository.initializeArSession())
          .thenAnswer((_) async {});
      when(mockRepository.startArSession())
          .thenAnswer((_) async {});
      when(mockRepository.trackingStateStream)
          .thenAnswer((_) => Stream.value(const ArTrackingInfo(
                state: ArTrackingState.tracking,
                lighting: ArLightingCondition.moderate,
                isDeviceSupported: true,
                confidence: 0.8,
              )));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            arNotifierProvider.overrideWith(
              (ref) => ArNotifier(mockRepository),
            ),
          ],
          child: const MaterialApp(
            home: ArPage(),
          ),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert
      expect(find.text('Session Status'), findsOneWidget);
      expect(find.text('Tracking'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('should handle start/stop session buttons', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.isCameraPermissionGranted())
          .thenAnswer((_) async => true);
      when(mockRepository.checkDeviceCompatibility())
          .thenAnswer((_) async => const ArDeviceCompatibility(
                isSupported: true,
                requiresArCore: true,
              ));
      when(mockRepository.initializeArSession())
          .thenAnswer((_) async {});
      when(mockRepository.startArSession())
          .thenAnswer((_) async {});
      when(mockRepository.stopArSession())
          .thenAnswer((_) async {});
      when(mockRepository.trackingStateStream)
          .thenAnswer((_) => Stream.value(const ArTrackingInfo(
                state: ArTrackingState.tracking,
                lighting: ArLightingCondition.moderate,
                isDeviceSupported: true,
                confidence: 0.8,
              )));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            arNotifierProvider.overrideWith(
              (ref) => ArNotifier(mockRepository),
            ),
          ],
          child: const MaterialApp(
            home: ArPage(),
          ),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act - Find and tap stop button
      final stopButton = find.text('Stop');
      expect(stopButton, findsOneWidget);
      await tester.tap(stopButton);
      await tester.pump();

      // Verify stop was called
      verify(mockRepository.stopArSession()).called(1);
    });

    testWidgets('should handle image tracking toggle', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.isCameraPermissionGranted())
          .thenAnswer((_) async => true);
      when(mockRepository.checkDeviceCompatibility())
          .thenAnswer((_) async => const ArDeviceCompatibility(
                isSupported: true,
                requiresArCore: true,
              ));
      when(mockRepository.initializeArSession())
          .thenAnswer((_) async {});
      when(mockRepository.startArSession())
          .thenAnswer((_) async {});
      when(mockRepository.isImageTrackingEnabled())
          .thenAnswer((_) async => false);
      when(mockRepository.enableImageTracking())
          .thenAnswer((_) async {});
      when(mockRepository.trackingStateStream)
          .thenAnswer((_) => Stream.value(const ArTrackingInfo(
                state: ArTrackingState.tracking,
                lighting: ArLightingCondition.moderate,
                isDeviceSupported: true,
                confidence: 0.8,
              )));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            arNotifierProvider.overrideWith(
              (ref) => ArNotifier(mockRepository),
            ),
          ],
          child: const MaterialApp(
            home: ArPage(),
          ),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act - Find and tap image tracking button
      final imageTrackButton = find.text('Image Track');
      expect(imageTrackButton, findsOneWidget);
      await tester.tap(imageTrackButton);
      await tester.pump();

      // Verify toggle was called
      verify(mockRepository.isImageTrackingEnabled()).called(1);
      verify(mockRepository.enableImageTracking()).called(1);
    });

    testWidgets('should handle app lifecycle changes', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.isCameraPermissionGranted())
          .thenAnswer((_) async => true);
      when(mockRepository.checkDeviceCompatibility())
          .thenAnswer((_) async => const ArDeviceCompatibility(
                isSupported: true,
                requiresArCore: true,
              ));
      when(mockRepository.initializeArSession())
          .thenAnswer((_) async {});
      when(mockRepository.startArSession())
          .thenAnswer((_) async {});
      when(mockRepository.pauseArSession())
          .thenAnswer((_) async {});
      when(mockRepository.resumeArSession())
          .thenAnswer((_) async {});
      when(mockRepository.trackingStateStream)
          .thenAnswer((_) => Stream.value(const ArTrackingInfo(
                state: ArTrackingState.tracking,
                lighting: ArLightingCondition.moderate,
                isDeviceSupported: true,
                confidence: 0.8,
              )));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            arNotifierProvider.overrideWith(
              (ref) => ArNotifier(mockRepository),
            ),
          ],
          child: const MaterialApp(
            home: ArPage(),
          ),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act - Simulate app paused
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        StringCodec().encodeMessage('AppLifecycleState.paused'),
        (data) {},
      );

      await tester.pump();

      // Verify pause was called
      verify(mockRepository.pauseArSession()).called(1);

      // Act - Simulate app resumed
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        StringCodec().encodeMessage('AppLifecycleState.resumed'),
        (data) {},
      );

      await tester.pump();

      // Verify resume was called
      verify(mockRepository.resumeArSession()).called(1);
    });
  });
}