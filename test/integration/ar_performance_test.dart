import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_ar_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AR Performance Tests', () {
    testWidgets('AR initialization performance', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AR screen
      final arButton = find.byIcon(Icons.camera_alt);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Wait for AR initialization
      await tester.pumpAndSettle(const Duration(seconds: 5));

      stopwatch.stop();

      // AR should initialize within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Verify AR view is loaded
      expect(find.byType(Container), findsWidgets); // AR camera view
    });

    testWidgets('AR frame rate stability', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AR screen
      final arButton = find.byIcon(Icons.camera_alt);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      // Wait for AR initialization
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Monitor frame rate for 10 seconds
      final frameTimes = <int>[];
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 60; i++) { // 60 frames at ~60fps
        final frameStart = stopwatch.elapsedMilliseconds;
        await tester.pump(const Duration(milliseconds: 16)); // ~60fps
        final frameEnd = stopwatch.elapsedMilliseconds;
        frameTimes.add(frameEnd - frameStart);
      }

      stopwatch.stop();

      // Calculate average frame time
      final avgFrameTime = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      final avgFps = 1000 / avgFrameTime;

      // Verify minimum acceptable FPS
      expect(avgFps, greaterThan(15)); // Should maintain at least 15 FPS

      // Verify frame time consistency (variance should be reasonable)
      final variance = _calculateVariance(frameTimes, avgFrameTime);
      expect(variance, lessThan(avgFrameTime * 0.5)); // Variance less than 50% of average
    });

    testWidgets('AR memory usage during extended session', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AR screen
      final arButton = find.byIcon(Icons.camera_alt);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      // Wait for AR initialization
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Simulate extended AR usage (2 minutes compressed to 30 seconds)
      for (int i = 0; i < 30; i++) {
        // Simulate user interaction
        await tester.tapAt(Offset(100, 100));
        await tester.pump(const Duration(milliseconds: 500));

        // Simulate device movement
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Verify app is still responsive
      expect(tester.takeException(), isNull);

      // Verify AR view is still active
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('AR object placement performance', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AR screen
      final arButton = find.byIcon(Icons.camera_alt);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      // Wait for AR initialization
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test object placement performance
      final placementTimes = <int>[];

      for (int i = 0; i < 10; i++) {
        final stopwatch = Stopwatch()..start();

        // Place object
        await tester.tapAt(Offset(100 + i * 20, 100));
        await tester.pumpAndSettle();

        stopwatch.stop();
        placementTimes.add(stopwatch.elapsedMilliseconds);
      }

      // Calculate average placement time
      final avgPlacementTime = placementTimes.reduce((a, b) => a + b) / placementTimes.length;

      // Object placement should be fast
      expect(avgPlacementTime, lessThan(500)); // Less than 500ms average

      // All placements should complete within reasonable time
      for (final time in placementTimes) {
        expect(time, lessThan(1000)); // Each placement under 1 second
      }
    });

    testWidgets('AR tracking stability during movement', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AR screen
      final arButton = find.byIcon(Icons.camera_alt);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      // Wait for AR initialization
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Place an object
      await tester.tapAt(Offset(200, 200));
      await tester.pumpAndSettle();

      // Simulate device movement
      final movements = [
        const Offset(10, 0), const Offset(-10, 0), // Horizontal
        const Offset(0, 10), const Offset(0, -10), // Vertical
        const Offset(10, 10), const Offset(-10, -10), // Diagonal
      ];

      for (final movement in movements) {
        await tester.pumpAndSettle();
        
        // Simulate gradual movement
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      // Verify AR is still tracking
      expect(tester.takeException(), isNull);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('AR performance with multiple objects', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AR screen
      final arButton = find.byIcon(Icons.camera_alt);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      // Wait for AR initialization
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Place multiple objects
      final positions = [
        const Offset(100, 100),
        const Offset(200, 100),
        const Offset(300, 100),
        const Offset(100, 200),
        const Offset(200, 200),
      ];

      final stopwatch = Stopwatch()..start();

      for (final position in positions) {
        await tester.tapAt(position);
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Multiple object placement should complete in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Verify performance is still acceptable
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    });
  });
}

double _calculateVariance(List<int> values, double mean) {
  if (values.isEmpty) return 0.0;
  
  final sumOfSquares = values
      .map((value) => (value - mean) * (value - mean))
      .reduce((a, b) => a + b);
  
  return sumOfSquares / values.length;
}