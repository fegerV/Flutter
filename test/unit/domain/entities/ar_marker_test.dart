import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

import '../../../lib/domain/entities/ar_marker.dart';
import '../../../lib/domain/entities/ar_tracking.dart';

void main() {
  group('ARMarker', () {
    test('should create ARMarker with required fields', () {
      const marker = ARMarker(
        id: 'test-marker-1',
        name: 'Test Marker',
        imageUrl: 'https://example.com/marker.jpg',
        alignment: MarkerAlignment.center,
        type: MarkerType.portrait,
        width: 100.0,
        height: 150.0,
        transformMatrix: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        createdAt: Duration.zero,
      );

      expect(marker.id, 'test-marker-1');
      expect(marker.name, 'Test Marker');
      expect(marker.type, MarkerType.portrait);
      expect(marker.isActive, true);
    });

    test('should support copyWith', () {
      const marker = ARMarker(
        id: 'test-marker-1',
        name: 'Test Marker',
        imageUrl: 'https://example.com/marker.jpg',
        alignment: MarkerAlignment.center,
        type: MarkerType.portrait,
        width: 100.0,
        height: 150.0,
        transformMatrix: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        createdAt: Duration.zero,
      );

      final updatedMarker = marker.copyWith(
        name: 'Updated Marker',
        isActive: false,
      );

      expect(updatedMarker.id, marker.id);
      expect(updatedMarker.name, 'Updated Marker');
      expect(updatedMarker.isActive, false);
      expect(updatedMarker.imageUrl, marker.imageUrl);
    });

    test('should handle equality correctly', () {
      const marker1 = ARMarker(
        id: 'test-marker-1',
        name: 'Test Marker',
        imageUrl: 'https://example.com/marker.jpg',
        alignment: MarkerAlignment.center,
        type: MarkerType.portrait,
        width: 100.0,
        height: 150.0,
        transformMatrix: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        createdAt: Duration.zero,
      );

      const marker2 = ARMarker(
        id: 'test-marker-1',
        name: 'Test Marker',
        imageUrl: 'https://example.com/marker.jpg',
        alignment: MarkerAlignment.center,
        type: MarkerType.portrait,
        width: 100.0,
        height: 150.0,
        transformMatrix: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        createdAt: Duration.zero,
      );

      expect(marker1, equals(marker2));
    });
  });

  group('MarkerConfiguration', () {
    test('should create MarkerConfiguration with markers', () {
      const marker = ARMarker(
        id: 'test-marker-1',
        name: 'Test Marker',
        imageUrl: 'https://example.com/marker.jpg',
        alignment: MarkerAlignment.center,
        type: MarkerType.portrait,
        width: 100.0,
        height: 150.0,
        transformMatrix: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        createdAt: Duration.zero,
      );

      const config = MarkerConfiguration(
        id: 'config-1',
        name: 'Test Configuration',
        markers: [marker],
        trackingSettings: TrackingSettings(),
        videoSettings: VideoSettings(),
        createdAt: Duration.zero,
      );

      expect(config.id, 'config-1');
      expect(config.markers.length, 1);
      expect(config.markers.first, marker);
    });
  });

  group('TrackingSettings', () {
    test('should create TrackingSettings with defaults', () {
      const settings = TrackingSettings();

      expect(settings.maxTrackingDistance, 5.0);
      expect(settings.minTrackingDistance, 0.1);
      expect(settings.confidenceThreshold, 0.7);
      expect(settings.enablePoseSmoothing, true);
      expect(settings.smoothingFactor, 0.3);
    });

    test('should support custom values', () {
      const settings = TrackingSettings(
        maxTrackingDistance: 10.0,
        confidenceThreshold: 0.8,
        smoothingFactor: 0.5,
      );

      expect(settings.maxTrackingDistance, 10.0);
      expect(settings.confidenceThreshold, 0.8);
      expect(settings.smoothingFactor, 0.5);
    });
  });

  group('VideoSettings', () {
    test('should create VideoSettings with defaults', () {
      const settings = VideoSettings();

      expect(settings.autoPlay, true);
      expect(settings.loop, true);
      expect(settings.volume, 1.0);
      expect(settings.playbackSpeed, PlaybackSpeed.normal);
      expect(settings.enableAudio, false);
    });

    test('should support custom values', () {
      const settings = VideoSettings(
        autoPlay: false,
        volume: 0.5,
        playbackSpeed: PlaybackSpeed.fast,
        enableAudio: true,
      );

      expect(settings.autoPlay, false);
      expect(settings.volume, 0.5);
      expect(settings.playbackSpeed, PlaybackSpeed.fast);
      expect(settings.enableAudio, true);
    });
  });
}