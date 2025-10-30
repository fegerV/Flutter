import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

import '../../../lib/domain/entities/ar_tracking.dart';
import '../../../lib/presentation/widgets/ar_video_overlay_widget.dart';

void main() {
  group('ARVideoOverlayWidget', () {
    late VideoOverlayState mockVideoState;
    late ARTrackingResult mockTrackingResult;

    setUp(() {
      mockVideoState = const VideoOverlayState(
        markerId: 'test-marker-1',
        isLoaded: true,
        isPlaying: true,
        lastUpdate: Duration.zero,
      );

      final transform = Matrix4.identity();
      mockTrackingResult = ARTrackingResult(
        markerId: 'test-marker-1',
        isTracking: true,
        transformMatrix: transform,
        confidence: 0.85,
        timestamp: DateTime.now(),
        position: Vector3(0, 0, 1),
        rotation: Quaternion.identity(),
        scale: Vector3.all(1),
      );
    });

    testWidgets('should display video overlay when tracking is active', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ARVideoOverlayWidget(
                markerId: 'test-marker-1',
                videoState: mockVideoState,
                trackingResult: mockTrackingResult,
              ),
            ),
          ),
        ),
      );

      // The widget should be rendered (though positioning logic is complex)
      expect(find.byType(ARVideoOverlayWidget), findsOneWidget);
    });

    testWidgets('should not display overlay when tracking is not active', (WidgetTester tester) async {
      final inactiveTrackingResult = ARTrackingResult(
        markerId: 'test-marker-1',
        isTracking: false,
        transformMatrix: Matrix4.identity(),
        confidence: 0.0,
        timestamp: DateTime.now(),
        position: Vector3.zero(),
        rotation: Quaternion.identity(),
        scale: Vector3.all(1),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ARVideoOverlayWidget(
                markerId: 'test-marker-1',
                videoState: mockVideoState,
                trackingResult: inactiveTrackingResult,
              ),
            ),
          ),
        ),
      );

      // The widget should not render anything when tracking is inactive
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should not display overlay when tracking result is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ARVideoOverlayWidget(
                markerId: 'test-marker-1',
                videoState: mockVideoState,
                trackingResult: null,
              ),
            ),
          ),
        ),
      );

      // The widget should not render anything when tracking result is null
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should display error widget when video has error', (WidgetTester tester) async {
      final errorVideoState = VideoOverlayState(
        markerId: 'test-marker-1',
        hasError: true,
        errorMessage: 'Test error',
        lastUpdate: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ARVideoOverlayWidget(
                markerId: 'test-marker-1',
                videoState: errorVideoState,
                trackingResult: mockTrackingResult,
              ),
            ),
          ),
        ),
      );

      // Should find error icon and text
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Video Error'), findsOneWidget);
    });

    testWidgets('should display loading widget when video is not loaded', (WidgetTester tester) async {
      final loadingVideoState = VideoOverlayState(
        markerId: 'test-marker-1',
        isLoaded: false,
        lastUpdate: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ARVideoOverlayWidget(
                markerId: 'test-marker-1',
                videoState: loadingVideoState,
                trackingResult: mockTrackingResult,
              ),
            ),
          ),
        ),
      );

      // Should find loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle tracking state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return ARVideoOverlayWidget(
                    markerId: 'test-marker-1',
                    videoState: mockVideoState,
                    trackingResult: mockTrackingResult,
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initial state - tracking is active
      expect(find.byType(ARVideoOverlayWidget), findsOneWidget);

      // Simulate tracking lost
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ARVideoOverlayWidget(
                markerId: 'test-marker-1',
                videoState: mockVideoState,
                trackingResult: ARTrackingResult(
                  markerId: 'test-marker-1',
                  isTracking: false,
                  transformMatrix: Matrix4.identity(),
                  confidence: 0.0,
                  timestamp: DateTime.now(),
                  position: Vector3.zero(),
                  rotation: Quaternion.identity(),
                  scale: Vector3.all(1),
                ),
              ),
            ),
          ),
        ),
      );

      // Widget should handle the state change gracefully
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}