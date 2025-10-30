import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_ar_app/domain/entities/ar_entities.dart';
import 'package:flutter_ar_app/domain/repositories/ar_repository.dart';
import 'package:flutter_ar_app/domain/notifiers/ar_notifier.dart';

import 'ar_notifier_test.mocks.dart';

@GenerateMocks([ArRepository])
void main() {
  group('ArNotifier', () {
    late MockArRepository mockRepository;
    late ArNotifier notifier;

    setUp(() {
      mockRepository = MockArRepository();
      notifier = ArNotifier(mockRepository);
    });

    tearDown(() {
      notifier.dispose();
    });

    group('Permission Management', () {
      test('should request camera permission when not granted', () async {
        // Arrange
        when(mockRepository.isCameraPermissionGranted())
            .thenAnswer((_) async => false);
        when(mockRepository.requestCameraPermission())
            .thenAnswer((_) async => true);

        // Act
        await notifier.checkPermissions();

        // Assert
        verify(mockRepository.isCameraPermissionGranted()).called(1);
        verify(mockRepository.requestCameraPermission()).called(1);
      });

      test('should not request permission when already granted', () async {
        // Arrange
        when(mockRepository.isCameraPermissionGranted())
            .thenAnswer((_) async => true);

        // Act
        await notifier.checkPermissions();

        // Assert
        verify(mockRepository.isCameraPermissionGranted()).called(1);
        verifyNever(mockRepository.requestCameraPermission());
      });

      test('should handle permission denial', () async {
        // Arrange
        when(mockRepository.isCameraPermissionGranted())
            .thenAnswer((_) async => false);
        when(mockRepository.requestCameraPermission())
            .thenAnswer((_) async => false);

        // Act
        await notifier.checkPermissions();

        // Assert
        expect(notifier.state, isA<ArPermissionDenied>());
      });
    });

    group('Device Compatibility', () {
      test('should check device compatibility', () async {
        // Arrange
        const compatibility = ArDeviceCompatibility(
          isSupported: true,
          requiresArCore: true,
        );
        when(mockRepository.checkDeviceCompatibility())
            .thenAnswer((_) async => compatibility);

        // Act
        await notifier.checkDeviceCompatibility();

        // Assert
        verify(mockRepository.checkDeviceCompatibility()).called(1);
      });

      test('should handle unsupported device', () async {
        // Arrange
        const compatibility = ArDeviceCompatibility(
          isSupported: false,
          reason: 'Device not supported',
          requiresArCore: true,
        );
        when(mockRepository.checkDeviceCompatibility())
            .thenAnswer((_) async => compatibility);

        // Act
        await notifier.checkDeviceCompatibility();

        // Assert
        expect(notifier.state, isA<ArDeviceUnsupported>());
      });
    });

    group('Session Management', () {
      setUp(() {
        // Set up initial state to allow session operations
        when(mockRepository.isCameraPermissionGranted())
            .thenAnswer((_) async => true);
        when(mockRepository.checkDeviceCompatibility())
            .thenAnswer((_) async => const ArDeviceCompatibility(
              isSupported: true,
              requiresArCore: true,
            ));
        when(mockRepository.initializeArSession())
            .thenAnswer((_) async {});
      });

      test('should initialize AR session', () async {
        // Act
        await notifier.initializeSession();

        // Assert
        verify(mockRepository.initializeArSession()).called(1);
        expect(notifier.state, isA<ArSessionReady>());
      });

      test('should start AR session', () async {
        // Arrange
        await notifier.initializeSession();

        // Act
        await notifier.startSession();

        // Assert
        verify(mockRepository.startArSession()).called(1);
      });

      test('should pause AR session', () async {
        // Arrange
        await notifier.initializeSession();
        await notifier.startSession();

        // Act
        await notifier.pauseSession();

        // Assert
        verify(mockRepository.pauseArSession()).called(1);
      });

      test('should resume AR session', () async {
        // Arrange
        await notifier.initializeSession();
        await notifier.startSession();
        await notifier.pauseSession();

        // Act
        await notifier.resumeSession();

        // Assert
        verify(mockRepository.resumeArSession()).called(1);
      });

      test('should stop AR session', () async {
        // Arrange
        await notifier.initializeSession();
        await notifier.startSession();

        // Act
        await notifier.stopSession();

        // Assert
        verify(mockRepository.stopArSession()).called(1);
      });
    });

    group('Image Tracking', () {
      setUp(() {
        when(mockRepository.isCameraPermissionGranted())
            .thenAnswer((_) async => true);
        when(mockRepository.checkDeviceCompatibility())
            .thenAnswer((_) async => const ArDeviceCompatibility(
              isSupported: true,
              requiresArCore: true,
            ));
        when(mockRepository.initializeArSession())
            .thenAnswer((_) async {});
      });

      test('should enable image tracking', () async {
        // Arrange
        await notifier.initializeSession();
        when(mockRepository.isImageTrackingEnabled())
            .thenAnswer((_) async => false);
        when(mockRepository.enableImageTracking())
            .thenAnswer((_) async {});

        // Act
        await notifier.toggleImageTracking();

        // Assert
        verify(mockRepository.enableImageTracking()).called(1);
      });

      test('should disable image tracking', () async {
        // Arrange
        await notifier.initializeSession();
        when(mockRepository.isImageTrackingEnabled())
            .thenAnswer((_) async => true);
        when(mockRepository.disableImageTracking())
            .thenAnswer((_) async {});

        // Act
        await notifier.toggleImageTracking();

        // Assert
        verify(mockRepository.disableImageTracking()).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle permission check error', () async {
        // Arrange
        when(mockRepository.isCameraPermissionGranted())
            .thenThrow(Exception('Permission check failed'));

        // Act
        await notifier.checkPermissions();

        // Assert
        expect(notifier.state, isA<ArError>());
      });

      test('should handle device compatibility check error', () async {
        // Arrange
        when(mockRepository.checkDeviceCompatibility())
            .thenThrow(Exception('Compatibility check failed'));

        // Act
        await notifier.checkDeviceCompatibility();

        // Assert
        expect(notifier.state, isA<ArError>());
      });

      test('should handle session initialization error', () async {
        // Arrange
        when(mockRepository.initializeArSession())
            .thenThrow(Exception('Initialization failed'));

        // Act
        await notifier.initializeSession();

        // Assert
        expect(notifier.state, isA<ArError>());
      });
    });

    group('Tracking State Updates', () {
      test('should update tracking state from stream', () async {
        // Arrange
        final trackingController = StreamController<ArTrackingInfo>();
        when(mockRepository.trackingStateStream)
            .thenAnswer((_) => trackingController.stream);

        final newNotifier = ArNotifier(mockRepository);

        final trackingInfo = const ArTrackingInfo(
          state: ArTrackingState.tracking,
          lighting: ArLightingCondition.moderate,
          isDeviceSupported: true,
          confidence: 0.8,
        );

        // Act
        trackingController.add(trackingInfo);

        // Wait for stream processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(newNotifier.state, isA<ArSessionReady>());

        // Cleanup
        await newNotifier.dispose();
        await trackingController.close();
      });
    });
  });
}