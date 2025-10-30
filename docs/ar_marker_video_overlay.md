# AR Marker Video Overlay Implementation

This document describes the comprehensive implementation of an AR marker video overlay system for Flutter, featuring backend-driven configuration, ARCore integration, video playback with ExoPlayer, pose smoothing, and automated testing.

## Architecture Overview

The implementation follows a clean architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   AR Pages      │  │ AR Video Widget │  │  Providers   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │    Entities     │  │   Use Cases     │  │ Repositories │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Repository Impl │  │   Data Sources   │  │   Models     │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Domain Entities

#### ARMarker
Represents a physical marker that can be detected by ARCore:
```dart
class ARMarker extends Entity {
  final String id;
  final String name;
  final String imageUrl;
  final String? videoUrl;
  final MarkerAlignment alignment;
  final MarkerType type;
  final double width;
  final double height;
  final List<double> transformMatrix;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

#### ARTrackingResult
Contains real-time tracking information:
```dart
class ARTrackingResult extends Entity {
  final String markerId;
  final bool isTracking;
  final Matrix4 transformMatrix;
  final double confidence;
  final DateTime timestamp;
  final Vector3 position;
  final Quaternion rotation;
  final Vector3 scale;
}
```

#### VideoOverlayState
Manages video playback state:
```dart
class VideoOverlayState extends Entity {
  final String markerId;
  final bool isPlaying;
  final bool isLoaded;
  final Duration position;
  final Duration duration;
  final bool hasError;
  final String? errorMessage;
  final DateTime lastUpdate;
}
```

### 2. Repository Pattern

#### ARMarkerRepository
Handles marker configuration and asset management:
- Fetch marker configurations from backend
- Download and cache marker images and videos
- Manage local storage of AR assets

#### ARTrackingRepository
Manages ARCore integration:
- Initialize and configure AR sessions
- Add markers to tracking database
- Process tracking results and pose data
- Apply pose smoothing algorithms

#### VideoOverlayRepository
Controls video playback:
- Initialize ExoPlayer integration
- Load and play videos based on tracking state
- Handle video lifecycle management
- Apply video settings and effects

#### PoseSmoothingRepository
Implements smoothing algorithms:
- Exponential moving average smoothing
- Kalman filter-like prediction
- Velocity and stability calculations
- Configurable smoothing parameters

### 3. Use Cases

Business logic is encapsulated in use cases:
- `GetMarkerConfigurationUseCase` - Load marker configs
- `SyncMarkerDataUseCase` - Download and cache assets
- `InitializeARSessionUseCase` - Setup ARCore session
- `StartMarkerTrackingUseCase` - Begin marker detection
- `HandleMarkerTrackingStateUseCase` - Coordinate video playback
- `ApplyPoseSmoothingUseCase` - Smooth pose data

### 4. State Management

Uses Riverpod for reactive state management:
```dart
final arTrackingStateProvider = StateNotifierProvider<ARTrackingNotifier, ARTrackingState>;
final videoOverlayStatesProvider = StateProvider<Map<String, VideoOverlayState>>;
final smoothedPosesProvider = StateProvider<Map<String, SmoothedPose>>;
```

## Key Features

### 1. Backend-Driven Configuration

The system fetches marker configurations from a REST API:
```dart
// API Response Structure
{
  "id": "config-1",
  "name": "Default Configuration",
  "markers": [
    {
      "id": "marker-1",
      "name": "Portrait Marker",
      "imageUrl": "https://api.example.com/markers/1/image.jpg",
      "videoUrl": "https://api.example.com/markers/1/video.mp4",
      "alignment": "center",
      "type": "portrait",
      "width": 100.0,
      "height": 150.0,
      "transformMatrix": [...],
      "isActive": true
    }
  ],
  "trackingSettings": {
    "maxTrackingDistance": 5.0,
    "confidenceThreshold": 0.7,
    "enablePoseSmoothing": true,
    "smoothingFactor": 0.3
  },
  "videoSettings": {
    "autoPlay": true,
    "loop": true,
    "volume": 0.0,
    "playbackSpeed": "normal"
  }
}
```

### 2. ARCore Integration

Seamless integration with ARCore for marker detection:
```dart
// AR Session Initialization
await _arSessionManager.onInitialize(
  featureMapEnabled: true,
  planeDetectionEnabled: true,
  planeOcclusionEnabled: true,
  updateEnabled: true,
);

// Marker Addition
final node = ARNode(
  type: NodeType.localGLTF2,
  uri: marker.imageUrl,
  scale: Vector3(marker.width, marker.height, 1.0),
  position: Vector3.zero(),
  rotation: Vector4.zero(),
);
await _arObjectManager.addNode(node);
```

### 3. Video Overlay Rendering

Advanced video overlay system with ExoPlayer:
```dart
// Video Loading and Playback
final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
await controller.initialize();
controller.setLooping(videoSettings.loop);
controller.setVolume(videoSettings.enableAudio ? videoSettings.volume : 0.0);
await controller.play();

// Overlay Positioning
Widget buildVideoOverlay(VideoState state, Size size) {
  return Positioned(
    left: screenPosition.dx - size.width / 2,
    top: screenPosition.dy - size.height / 2,
    width: size.width,
    height: size.height,
    child: Transform.scale(
      scale: _scaleAnimation.value,
      child: Opacity(
        opacity: _fadeAnimation.value * _calculateOpacity(trackingResult),
        child: VideoPlayer(controller),
      ),
    ),
  );
}
```

### 4. Pose Smoothing Algorithms

Multiple smoothing techniques for stable overlays:

#### Exponential Moving Average
```dart
ARPose _applySmoothingAlgorithm(ARPose current, ARPose previous, double factor) {
  final smoothedPosition = Vector3.lerp(
    previous.position,
    current.position,
    factor,
  );
  
  final smoothedRotation = previous.rotation.slerp(
    current.rotation,
    factor,
  );
  
  return ARPose(
    position: smoothedPosition,
    rotation: smoothedRotation,
    // ... other properties
  );
}
```

#### Kalman Filter-like Prediction
```dart
ARPose _applyKalmanSmoothing(ARPose current, String markerId) {
  final history = _poseHistory[markerId] ?? [];
  if (history.length < 2) return current;
  
  final predicted = _predictPose(lastSmoothed, history.last);
  final smoothed = _updatePose(predicted, current);
  
  return smoothed;
}
```

### 5. Automated Testing

Comprehensive test coverage:

#### Unit Tests
- Domain entity validation
- Repository implementation testing
- Use case logic verification
- Edge case handling

#### Widget Tests
- UI component rendering
- User interaction testing
- State change handling
- Error state display

#### Integration Tests
- End-to-end workflows
- Data flow verification
- Performance benchmarking
- Error propagation testing

## Performance Optimizations

### 1. Memory Management
- Automatic cleanup of unused video controllers
- Limited pose history buffers
- Efficient caching strategies
- Resource disposal on view exit

### 2. CPU Optimization
- 30 FPS update rate for tracking
- Background processing for video loading
- Efficient matrix calculations
- Optimized smoothing algorithms

### 3. Battery Optimization
- Adaptive frame rates
- Background task management
- Efficient ARCore usage
- Video playback optimization

## Error Handling

### 1. Network Errors
- Graceful degradation with cached content
- Retry mechanisms for failed downloads
- Offline mode support
- User-friendly error messages

### 2. ARCore Errors
- Compatibility checking
- Session recovery
- Initialization failure handling
- Tracking loss management

### 3. Video Errors
- Codec compatibility checking
- Corrupted file handling
- Playback failure recovery
- Resource cleanup on errors

## Configuration

### Environment Variables
```bash
# .env
ENVIRONMENT=development
API_BASE_URL=https://api.example.com
ENABLE_AR_FEATURES=true
ENABLE_LOGGING=true
```

### Dependencies
```yaml
dependencies:
  # AR & Video
  ar_flutter_plugin: ^0.7.3
  video_player: ^2.8.1
  
  # State Management
  flutter_riverpod: ^2.4.9
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # Data & Networking
  dio: ^5.4.0
  flutter_cache_manager: ^3.3.1
  vector_math: ^2.1.4
  dartz: ^0.10.1
```

## Usage

### Basic Setup
```dart
// Initialize dependencies
await configureDependencies();
await AppConfig.initialize();

// Navigate to AR view
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const ARMarkerVideoPage(),
  ),
);
```

### Custom Configuration
```dart
// Update tracking settings
final trackingSettings = TrackingSettings(
  confidenceThreshold: 0.8,
  smoothingFactor: 0.5,
  enablePoseSmoothing: true,
);

// Update video settings
final videoSettings = VideoSettings(
  autoPlay: true,
  loop: false,
  volume: 0.5,
  enableAudio: true,
);
```

## Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/domain/entities/ar_marker_test.dart

# Run with coverage
flutter test --coverage
```

### QA Checklist
See [docs/qa_checklist.md](docs/qa_checklist.md) for comprehensive testing guidelines including:
- Environmental testing conditions
- Device compatibility matrix
- Performance benchmarks
- User experience validation
- Integration testing scenarios

## Future Enhancements

### 1. Advanced Features
- Multi-user AR experiences
- Cloud anchoring support
- Real-time collaboration
- Advanced gesture recognition

### 2. Performance Improvements
- GPU-accelerated video processing
- Machine learning for pose prediction
- Adaptive quality streaming
- Progressive loading strategies

### 3. Platform Expansion
- iOS ARKit integration
- WebAR support
- ARCore Cloud Anchors
- Cross-platform synchronization

## Troubleshooting

### Common Issues

#### ARCore Not Available
- Ensure device supports ARCore
- Check ARCore installation
- Verify permissions

#### Video Playback Issues
- Check video format compatibility
- Verify network connectivity
- Clear video cache

#### Performance Problems
- Reduce concurrent video playback
- Lower video quality settings
- Optimize marker complexity

### Debug Mode
Enable debug logging in `.env`:
```bash
DEBUG_MODE=true
ENABLE_LOGGING=true
```

## Contributing

1. Follow the established architecture patterns
2. Ensure test coverage for new features
3. Update documentation for API changes
4. Run QA checklist before submissions
5. Follow Flutter/Dart coding standards

## License

This implementation follows the project's existing license terms.