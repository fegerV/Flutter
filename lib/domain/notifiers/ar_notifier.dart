import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/ar_entities.dart';
import '../repositories/ar_repository.dart';
import '../events/ar_events.dart';
import '../states/ar_state.dart';

class ArNotifier extends StateNotifier<ArState> {
  final ArRepository _arRepository;
  final StreamController<ArEvent> _eventController;
  
  Stream<ArEvent> get eventStream => _eventController.stream;
  
  ArNotifier(this._arRepository) 
      : _eventController = StreamController<ArEvent>.broadcast(),
        super(const ArInitial()) {
    _initializeTrackingListener();
  }

  void _initializeTrackingListener() {
    _arRepository.trackingStateStream.listen(
      (trackingInfo) {
        if (state is ArSessionReady || state is ArSessionActive || state is ArSessionPaused) {
          final currentState = state;
          final isImageTrackingEnabled = currentState is ArSessionReady
              ? currentState.isImageTrackingEnabled
              : currentState is ArSessionActive
                  ? currentState.isImageTrackingEnabled
                  : currentState is ArSessionPaused
                      ? currentState.isImageTrackingEnabled
                      : false;
          
          if (trackingInfo.state == ArTrackingState.tracking) {
            state = ArSessionActive(
              trackingInfo: trackingInfo,
              isImageTrackingEnabled: isImageTrackingEnabled,
            );
          } else if (trackingInfo.state == ArTrackingState.paused) {
            state = ArSessionPaused(
              trackingInfo: trackingInfo,
              isImageTrackingEnabled: isImageTrackingEnabled,
            );
          } else {
            state = ArSessionReady(
              trackingInfo: trackingInfo,
              isImageTrackingEnabled: isImageTrackingEnabled,
            );
          }
          
          _eventController.add(ArTrackingStateChanged(trackingInfo));
        }
      },
      onError: (error) {
        state = ArError('AR tracking error: $error');
        _eventController.add(ArError('AR tracking error: $error'));
      },
    );
  }

  Future<void> checkPermissions() async {
    state = const ArPermissionChecking();
    _eventController.add(const ArPermissionRequested());
    
    try {
      final isGranted = await _arRepository.isCameraPermissionGranted();
      
      if (!isGranted) {
        final granted = await _arRepository.requestCameraPermission();
        if (!granted) {
          state = const ArPermissionDenied('Camera permission is required for AR features');
          _eventController.add(const ArPermissionDenied());
          return;
        }
      }
      
      _eventController.add(const ArPermissionGranted());
    } catch (e) {
      state = ArError('Failed to check permissions: $e');
      _eventController.add(ArError('Failed to check permissions: $e'));
    }
  }

  Future<void> checkDeviceCompatibility() async {
    if (state is! ArPermissionDenied) {
      state = const ArDeviceChecking();
    }
    
    try {
      final compatibility = await _arRepository.checkDeviceCompatibility();
      
      if (!compatibility.isSupported) {
        state = ArDeviceUnsupported(compatibility.reason ?? 'Device not supported');
      }
      
      _eventController.add(ArDeviceCompatibilityChecked(compatibility));
    } catch (e) {
      state = ArError('Failed to check device compatibility: $e');
      _eventController.add(ArError('Failed to check device compatibility: $e'));
    }
  }

  Future<void> initializeSession() async {
    state = const ArSessionInitializing();
    _eventController.add(const ArSessionInitialized());
    
    try {
      await _arRepository.initializeArSession();
      state = const ArSessionReady(
        trackingInfo: ArTrackingInfo(
          state: ArTrackingState.none,
          lighting: ArLightingCondition.unknown,
          isDeviceSupported: true,
          confidence: 0.0,
        ),
      );
    } catch (e) {
      state = ArError('Failed to initialize AR session: $e');
      _eventController.add(ArError('Failed to initialize AR session: $e'));
    }
  }

  Future<void> startSession() async {
    if (state is! ArSessionReady) return;
    
    try {
      await _arRepository.startArSession();
      _eventController.add(const ArSessionStarted());
    } catch (e) {
      state = ArError('Failed to start AR session: $e');
      _eventController.add(ArError('Failed to start AR session: $e'));
    }
  }

  Future<void> pauseSession() async {
    if (state is! ArSessionActive) return;
    
    try {
      await _arRepository.pauseArSession();
      _eventController.add(const ArSessionPaused());
    } catch (e) {
      state = ArError('Failed to pause AR session: $e');
      _eventController.add(ArError('Failed to pause AR session: $e'));
    }
  }

  Future<void> resumeSession() async {
    if (state is! ArSessionPaused) return;
    
    try {
      await _arRepository.resumeArSession();
      _eventController.add(const ArSessionResumed());
    } catch (e) {
      state = ArError('Failed to resume AR session: $e');
      _eventController.add(ArError('Failed to resume AR session: $e'));
    }
  }

  Future<void> stopSession() async {
    if (state is! ArSessionActive && state is! ArSessionPaused) return;
    
    try {
      await _arRepository.stopArSession();
      state = const ArSessionReady(
        trackingInfo: ArTrackingInfo(
          state: ArTrackingState.stopped,
          lighting: ArLightingCondition.unknown,
          isDeviceSupported: true,
          confidence: 0.0,
        ),
      );
      _eventController.add(const ArSessionStopped());
    } catch (e) {
      state = ArError('Failed to stop AR session: $e');
      _eventController.add(ArError('Failed to stop AR session: $e'));
    }
  }

  Future<void> toggleImageTracking() async {
    final currentState = state;
    if (currentState is! ArSessionReady && currentState is! ArSessionActive && currentState is! ArSessionPaused) {
      return;
    }
    
    final isCurrentlyEnabled = currentState is ArSessionReady
        ? currentState.isImageTrackingEnabled
        : currentState is ArSessionActive
            ? currentState.isImageTrackingEnabled
            : currentState is ArSessionPaused
                ? currentState.isImageTrackingEnabled
                : false;
    
    try {
      if (isCurrentlyEnabled) {
        await _arRepository.disableImageTracking();
      } else {
        await _arRepository.enableImageTracking();
      }
      
      final trackingInfo = currentState.trackingInfo;
      final newEnabled = !isCurrentlyEnabled;
      
      if (currentState is ArSessionReady) {
        state = ArSessionReady(
          trackingInfo: trackingInfo,
          isImageTrackingEnabled: newEnabled,
        );
      } else if (currentState is ArSessionActive) {
        state = ArSessionActive(
          trackingInfo: trackingInfo,
          isImageTrackingEnabled: newEnabled,
        );
      } else if (currentState is ArSessionPaused) {
        state = ArSessionPaused(
          trackingInfo: trackingInfo,
          isImageTrackingEnabled: newEnabled,
        );
      }
      
      _eventController.add(ArImageTrackingToggled(newEnabled));
    } catch (e) {
      state = ArError('Failed to toggle image tracking: $e');
      _eventController.add(ArError('Failed to toggle image tracking: $e'));
    }
  }

  Future<void> dispose() async {
    try {
      await _arRepository.disposeArSession();
    } catch (e) {
      // Log error but don't throw
    }
    
    await _eventController.close();
  }
}