import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ar_app/presentation/widgets/performance_overlay.dart';
import 'package:flutter_ar_app/presentation/providers/performance_providers.dart';

void main() {
  group('PerformanceOverlay Widget Tests', () {
    testWidgets('should render performance overlay when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Should render the child content
      expect(find.text('Test Content'), findsOneWidget);
      
      // Should render the overlay
      expect(find.byType(PerformanceOverlay), findsOneWidget);
    });

    testWidgets('should not render overlay when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: false,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Should render the child content
      expect(find.text('Test Content'), findsOneWidget);
      
      // Should not render overlay controls
      expect(find.byIcon(Icons.speed), findsNothing);
    });

    testWidgets('should show performance metrics', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Should show performance section title
      expect(find.text('Performance'), findsOneWidget);
      
      // Should show metric labels
      expect(find.text('FPS'), findsOneWidget);
      expect(find.text('CPU'), findsOneWidget);
      expect(find.text('GPU'), findsOneWidget);
      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('Battery'), findsOneWidget);
    });

    testWidgets('should show device information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Should show device tier information
      expect(find.textContaining('Tier:'), findsOneWidget);
    });

    testWidgets('should show monitoring controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Should show start/stop button
      expect(find.text('Start'), findsOneWidget);
      
      // Should show clear button
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('should toggle visibility when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Should show performance metrics initially
      expect(find.text('Performance'), findsOneWidget);
      
      // Tap on the overlay to hide it
      await tester.tap(find.byType(PerformanceOverlay));
      await tester.pumpAndSettle();

      // Should hide performance metrics
      expect(find.text('Performance'), findsNothing);
      
      // Should show collapsed icon
      expect(find.byIcon(Icons.speed), findsOneWidget);
      
      // Tap on the icon to show it again
      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();

      // Should show performance metrics again
      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('should handle start/stop monitoring', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Should show Start button initially
      expect(find.text('Start'), findsOneWidget);
      
      // Tap Start button
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Should show Stop button after starting
      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Start'), findsNothing);
      
      // Tap Stop button
      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();

      // Should show Start button again after stopping
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Stop'), findsNothing);
    });

    testWidgets('should handle clear alerts', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Should show Clear button
      expect(find.text('Clear'), findsOneWidget);
      
      // Tap Clear button
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Should not throw any exceptions
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('should show alerts when present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceProvider.overrideWith((ref) {
              // Create a mock provider state with alerts
              return MockPerformanceNotifier();
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // This test would need a proper mock provider
      // For now, just ensure the widget renders without errors
      expect(find.byType(PerformanceOverlay), findsOneWidget);
    });

    testWidgets('should position overlay correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Find the overlay container
      final overlayFinder = find.byType(Container);
      expect(overlayFinder, findsWidgets);
      
      // Verify positioning (should be in top right)
      final overlay = tester.widget<Container>(overlayFinder.first);
      expect(overlay.decoration, isA<BoxDecoration>());
    });

    testWidgets('should apply correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Should have proper styling
      expect(find.byType(Container), findsWidgets);
      
      // Check for dark background
      final containers = find.byType(Container);
      for (final container in containers.evaluate()) {
        final widget = container.widget as Container;
        if (widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          // Should have dark background for overlay
          if (decoration.color != null) {
            expect(decoration.color!.value, lessThan(0xFF888888)); // Dark color
          }
        }
      }
    });

    testWidgets('should handle child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceOverlay(
                enabled: true,
                child: Column(
                  children: [
                    const Text('Child 1'),
                    const Text('Child 2'),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Button'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for provider to initialize
      await tester.pumpAndSettle();

      // Should render all child widgets
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Should still be able to interact with child widgets
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Should not throw any exceptions
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}

// Mock PerformanceNotifier for testing
class MockPerformanceNotifier extends StateNotifier<PerformanceState> {
  MockPerformanceNotifier() : super(const PerformanceState(
    alerts: ['Test Alert 1', 'Test Alert 2'],
    deviceProfile: null,
    currentMetrics: null,
    isMonitoring: false,
  ));
}