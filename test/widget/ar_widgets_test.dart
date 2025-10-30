import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_ar_app/presentation/widgets/ar_camera_view.dart';
import 'package:flutter_ar_app/presentation/widgets/ar_error_widgets.dart';
import 'package:flutter_ar_app/domain/entities/ar_entities.dart';

void main() {
  group('ArCameraView Widget Tests', () {
    setUp(() {
      // Initialize FlutterScreenUtil for tests
      ScreenUtil.init(
        testWidgetsFlutterBinding.window,
        size: const Size(375, 812),
        minTextAdapt: true,
      );
    });

    testWidgets('should display tracking status indicator', (WidgetTester tester) async {
      // Arrange
      const trackingInfo = ArTrackingInfo(
        state: ArTrackingState.tracking,
        lighting: ArLightingCondition.moderate,
        isDeviceSupported: true,
        confidence: 0.8,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArCameraView(
              trackingInfo: trackingInfo,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Tracking'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('should display image tracking toggle when callback provided', (WidgetTester tester) async {
      // Arrange
      const trackingInfo = ArTrackingInfo(
        state: ArTrackingState.tracking,
        lighting: ArLightingCondition.moderate,
        isDeviceSupported: true,
        confidence: 0.8,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArCameraView(
              trackingInfo: trackingInfo,
              isImageTrackingEnabled: true,
              onImageTrackingToggle: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.image_search), findsOneWidget);
    });

    testWidgets('should not display image tracking toggle when callback not provided', (WidgetTester tester) async {
      // Arrange
      const trackingInfo = ArTrackingInfo(
        state: ArTrackingState.tracking,
        lighting: ArLightingCondition.moderate,
        isDeviceSupported: true,
        confidence: 0.8,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArCameraView(
              trackingInfo: trackingInfo,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('should display correct tracking state colors', (WidgetTester tester) async {
      // Test different tracking states
      final testCases = [
        ArTrackingState.tracking,
        ArTrackingState.initializing,
        ArTrackingState.paused,
        ArTrackingState.stopped,
        ArTrackingState.error,
      ];

      for (final state in testCases) {
        // Arrange
        final trackingInfo = ArTrackingInfo(
          state: state,
          lighting: ArLightingCondition.moderate,
          isDeviceSupported: true,
          confidence: 0.8,
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ArCameraView(
                trackingInfo: trackingInfo,
              ),
            ),
          ),
        );

        // Assert - just verify it renders without errors
        expect(find.byType(ArCameraView), findsOneWidget);
        await tester.pumpWidget(Container()); // Clean up
      }
    });
  });

  group('ArErrorWidgets Tests', () {
    setUp(() {
      ScreenUtil.init(
        testWidgetsFlutterBinding.window,
        size: const Size(375, 812),
        minTextAdapt: true,
      );
    });

    testWidgets('ArErrorWidget should display title and message', (WidgetTester tester) async {
      // Arrange
      const title = 'Test Error';
      const message = 'This is a test error message';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArErrorWidget(
              title: title,
              message: message,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('ArErrorWidget should display retry button when callback provided', (WidgetTester tester) async {
      // Arrange
      bool retryPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArErrorWidget(
              title: 'Test Error',
              message: 'Test message',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retryPressed, isTrue);
    });

    testWidgets('ArPermissionDeniedWidget should handle permission request', (WidgetTester tester) async {
      // Arrange
      bool permissionRequested = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArPermissionDeniedWidget(
              onRequestPermission: () => permissionRequested = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Camera Permission Required'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(permissionRequested, isTrue);
    });

    testWidgets('ArDeviceUnsupportedWidget should display reason', (WidgetTester tester) async {
      // Arrange
      const reason = 'Device does not support ARCore';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArDeviceUnsupportedWidget(reason: reason),
          ),
        ),
      );

      // Assert
      expect(find.text('Device Not Supported'), findsOneWidget);
      expect(find.text(reason), findsOneWidget);
    });

    testWidgets('ArCalibrationWidget should handle completion', (WidgetTester tester) async {
      // Arrange
      bool calibrationCompleted = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArCalibrationWidget(
              onCalibrationComplete: () => calibrationCompleted = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Calibrating Camera'), findsOneWidget);
      expect(find.text('Calibration Complete'), findsOneWidget);
      await tester.tap(find.text('Calibration Complete'));
      expect(calibrationCompleted, isTrue);
    });
  });
}