import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

import '../../../lib/domain/entities/ar_tracking.dart';

void main() {
  group('ARTrackingResult', () {
    test('should create ARTrackingResult with required fields', () {
      final transform = Matrix4.identity();
      final position = Vector3(1.0, 2.0, 3.0);
      final rotation = Quaternion.identity();
      final scale = Vector3.all(1.0);

      final result = ARTrackingResult(
        markerId: 'test-marker-1',
        isTracking: true,
        transformMatrix: transform,
        confidence: 0.85,
        timestamp: DateTime.now(),
        position: position,
        rotation: rotation,
        scale: scale,
      );

      expect(result.markerId, 'test-marker-1');
      expect(result.isTracking, true);
      expect(result.confidence, 0.85);
      expect(result.position, position);
      expect(result.rotation, rotation);
      expect(result.scale, scale);
    });

    test('should handle equality correctly', () {
      final transform = Matrix4.identity();
      final position = Vector3(1.0, 2.0, 3.0);
      final rotation = Quaternion.identity();
      final scale = Vector3.all(1.0);
      final timestamp = DateTime.now();

      final result1 = ARTrackingResult(
        markerId: 'test-marker-1',
        isTracking: true,
        transformMatrix: transform,
        confidence: 0.85,
        timestamp: timestamp,
        position: position,
        rotation: rotation,
        scale: scale,
      );

      final result2 = ARTrackingResult(
        markerId: 'test-marker-1',
        isTracking: true,
        transformMatrix: transform,
        confidence: 0.85,
        timestamp: timestamp,
        position: position,
        rotation: rotation,
        scale: scale,
      );

      expect(result1, equals(result2));
    });
  });

  group('ARPose', () {
    test('should create ARPose with required fields', () {
      final transform = Matrix4.identity();
      final position = Vector3(1.0, 2.0, 3.0);
      final rotation = Quaternion.identity();
      final scale = Vector3.all(1.0);

      final pose = ARPose(
        transform: transform,
        position: position,
        rotation: rotation,
        scale: scale,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      expect(pose.transform, transform);
      expect(pose.position, position);
      expect(pose.rotation, rotation);
      expect(pose.scale, scale);
      expect(pose.confidence, 0.9);
    });
  });

  group('SmoothedPose', () {
    test('should create SmoothedPose with required fields', () {
      final transform = Matrix4.identity();
      final position = Vector3(1.0, 2.0, 3.0);
      final rotation = Quaternion.identity();
      final scale = Vector3.all(1.0);

      final currentPose = ARPose(
        transform: transform,
        position: position,
        rotation: rotation,
        scale: scale,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      final smoothedPose = SmoothedPose(
        currentPose: currentPose,
        smoothedPose: currentPose,
        smoothingFactor: 0.3,
        isStable: true,
        velocity: 0.5,
        timestamp: DateTime.now(),
      );

      expect(smoothedPose.currentPose, currentPose);
      expect(smoothedPose.smoothedPose, currentPose);
      expect(smoothedPose.smoothingFactor, 0.3);
      expect(smoothedPose.isStable, true);
      expect(smoothedPose.velocity, 0.5);
    });
  });

  group('ARTrackingState', () {
    test('should create ARTrackingState with defaults', () {
      final state = ARTrackingState(
        lastUpdate: DateTime.now(),
      );

      expect(state.isInitialized, false);
      expect(state.isTracking, false);
      expect(state.detectedMarkers, isEmpty);
      expect(state.trackingResults, isEmpty);
      expect(state.errorMessage, null);
    });

    test('should support copyWith', () {
      final timestamp = DateTime.now();
      final state = ARTrackingState(
        lastUpdate: timestamp,
      );

      final updatedState = state.copyWith(
        isInitialized: true,
        isTracking: true,
        detectedMarkers: ['marker-1', 'marker-2'],
        errorMessage: null,
      );

      expect(updatedState.isInitialized, true);
      expect(updatedState.isTracking, true);
      expect(updatedState.detectedMarkers, ['marker-1', 'marker-2']);
      expect(updatedState.errorMessage, null);
      expect(updatedState.lastUpdate, timestamp);
    });
  });

  group('VideoOverlayState', () {
    test('should create VideoOverlayState with defaults', () {
      final state = VideoOverlayState(
        markerId: 'test-marker-1',
        lastUpdate: DateTime.now(),
      );

      expect(state.markerId, 'test-marker-1');
      expect(state.isPlaying, false);
      expect(state.isLoaded, false);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.hasError, false);
      expect(state.errorMessage, null);
    });

    test('should support copyWith', () {
      final timestamp = DateTime.now();
      final state = VideoOverlayState(
        markerId: 'test-marker-1',
        lastUpdate: timestamp,
      );

      final updatedState = state.copyWith(
        isPlaying: true,
        isLoaded: true,
        position: const Duration(seconds: 10),
        duration: const Duration(seconds: 30),
      );

      expect(updatedState.markerId, 'test-marker-1');
      expect(updatedState.isPlaying, true);
      expect(updatedState.isLoaded, true);
      expect(updatedState.position, const Duration(seconds: 10));
      expect(updatedState.duration, const Duration(seconds: 30));
      expect(updatedState.lastUpdate, timestamp);
    });
  });
}