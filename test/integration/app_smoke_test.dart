import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_ar_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke Tests', () {
    testWidgets('App launches and shows home screen', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app launches without crash
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify home screen elements are visible
      expect(find.text('Flutter AR App'), findsOneWidget);
      
      // Check for main navigation elements
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Basic navigation works', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AR screen
      final arButton = find.byIcon(Icons.camera_alt);
      expect(arButton, findsOneWidget);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      // Verify AR screen loads
      expect(find.text('AR Camera'), findsOneWidget);

      // Navigate to Media screen
      final mediaButton = find.byIcon(Icons.photo_library);
      expect(mediaButton, findsOneWidget);
      await tester.tap(mediaButton);
      await tester.pumpAndSettle();

      // Verify Media screen loads
      expect(find.text('Media'), findsOneWidget);

      // Navigate to Settings screen
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Verify Settings screen loads
      expect(find.text('Settings'), findsOneWidget);

      // Navigate back to Home
      final homeButton = find.byIcon(Icons.home);
      expect(homeButton, findsOneWidget);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      // Verify back on Home screen
      expect(find.text('Flutter AR App'), findsOneWidget);
    });

    testWidgets('App handles permission requests gracefully', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to AR screen which requires camera permission
      final arButton = find.byIcon(Icons.camera_alt);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      // Check if permission dialog appears (may vary by device)
      // The app should not crash when permissions are requested
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify app is still running
      expect(tester.takeException(), isNull);
    });

    testWidgets('App maintains state during navigation', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to different screens
      final arButton = find.byIcon(Icons.camera_alt);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      final mediaButton = find.byIcon(Icons.photo_library);
      await tester.tap(mediaButton);
      await tester.pumpAndSettle();

      final settingsButton = find.byIcon(Icons.settings);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Navigate back through screens
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we can still navigate normally
      expect(arButton, findsOneWidget);
      await tester.tap(arButton);
      await tester.pumpAndSettle();

      expect(find.text('AR Camera'), findsOneWidget);
    });

    testWidgets('App handles system back button correctly', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a screen
      final settingsButton = find.byIcon(Icons.settings);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Verify we're on settings screen
      expect(find.text('Settings'), findsOneWidget);

      // Simulate system back button
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text('Flutter AR App'), findsOneWidget);
    });

    testWidgets('App performance metrics during basic usage', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Perform basic navigation sequence
      for (int i = 0; i < 5; i++) {
        // Navigate to AR
        await tester.tap(find.byIcon(Icons.camera_alt));
        await tester.pumpAndSettle();

        // Navigate to Media
        await tester.tap(find.byIcon(Icons.photo_library));
        await tester.pumpAndSettle();

        // Navigate to Settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Navigate back to Home
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Verify performance is acceptable (should complete within 30 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(30000));

      // Verify app is still responsive
      expect(find.byIcon(Icons.home), findsOneWidget);
    });
  });
}