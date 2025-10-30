import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math.dart';

import '../../core/l10n/app_localizations.dart';
import '../providers/ar_providers.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart' as custom;
import '../widgets/ar_video_overlay_widget.dart';

class ARMarkerVideoPage extends ConsumerStatefulWidget {
  const ARMarkerVideoPage({super.key});

  @override
  ConsumerState<ARMarkerVideoPage> createState() => _ARMarkerVideoPageState();
}

class _ARMarkerVideoPageState extends ConsumerState<ARMarkerVideoPage> {
  late ARSessionManager _arSessionManager;
  late ARObjectManager _arObjectManager;
  late ARAnchorManager _arAnchorManager;
  late ARLocationManager _arLocationManager;

  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAR();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _initializeAR() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final initializeUseCase = ref.read(initializeARSessionProvider);
      final result = await initializeUseCase.execute();

      result.fold(
        (error) => setState(() {
          _errorMessage = 'Failed to initialize AR: $error';
        }),
        (success) async {
          if (success) {
            await _loadMarkerConfiguration();
          }
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'AR initialization error: $e';
      });
    }
  }

  Future<void> _loadMarkerConfiguration() async {
    try {
      final syncUseCase = ref.read(syncMarkerDataProvider);
      final configAsync = ref.read(markerConfigurationProvider);
      final markersAsync = ref.read(allMarkersProvider);

      // Wait for configuration and markers to load
      final config = await configAsync;
      final markers = await markersAsync;

      // Sync marker data (download images and videos)
      final syncResult = await syncUseCase.execute(markers);
      syncResult.fold(
        (error) => setState(() {
          _errorMessage = 'Failed to sync marker data: $error';
        }),
        (_) async {
          // Start tracking with markers
          final startTrackingUseCase = ref.read(startMarkerTrackingProvider);
          final trackingResult = await startTrackingUseCase.execute(markers);
          
          trackingResult.fold(
            (error) => setState(() {
              _errorMessage = 'Failed to start tracking: $error';
            }),
            (_) => setState(() {
              _isInitialized = true;
            }),
          );
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Configuration loading error: $e';
      });
    }
  }

  void _cleanup() {
    // Cleanup AR resources
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trackingState = ref.watch(arTrackingStateProvider);
    final videoStates = ref.watch(videoOverlayStatesProvider);

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.ar),
          centerTitle: true,
        ),
        body: custom.ErrorWidget(
          message: _errorMessage!,
          onRetry: _initializeAR,
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.ar),
          centerTitle: true,
        ),
        body: const LoadingIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ar),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              trackingState.isTracking ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: _toggleTracking,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          // AR View
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          
          // Video Overlays
          ...videoStates.entries.map((entry) {
            return ARVideoOverlayWidget(
              key: ValueKey(entry.key),
              markerId: entry.key,
              videoState: entry.value,
              trackingResult: trackingState.trackingResults[entry.key],
            );
          }).toList(),

          // Status overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildStatusOverlay(trackingState),
          ),

          // Debug info
          if (trackingState.errorMessage != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.withOpacity(0.8),
                child: Text(
                  trackingState.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;
    _arLocationManager = arLocationManager;

    // Set up AR session listeners
    _arSessionManager.onInitialize(
      featureMapEnabled: true,
      planeDetectionEnabled: true,
      planeOcclusionEnabled: true,
      updateEnabled: true,
    );

    // Start tracking updates
    _startTrackingUpdates();
  }

  void _startTrackingUpdates() {
    // Update tracking state periodically
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 33)); // ~30 FPS
      
      if (mounted) {
        final notifier = ref.read(arTrackingStateProvider.notifier);
        await notifier.updateTrackingState();
        
        // Handle video overlay state based on tracking
        _handleVideoOverlayStates();
        return true;
      }
      
      return false;
    });
  }

  void _handleVideoOverlayStates() {
    final trackingState = ref.read(arTrackingStateProvider);
    final videoStatesNotifier = ref.read(videoOverlayStatesProvider.notifier);
    
    final useCase = ref.read(handleMarkerTrackingStateProvider);
    useCase.execute(
      trackingState.trackingResults.values.toList(),
      videoStatesNotifier.state,
    );
  }

  Widget _buildStatusOverlay(ARTrackingState trackingState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                trackingState.isTracking ? Icons.videocam : Icons.videocam_off,
                color: trackingState.isTracking ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                trackingState.isTracking ? 'Tracking' : 'Not Tracking',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (trackingState.detectedMarkers.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Detected markers: ${trackingState.detectedMarkers.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              'Markers: ${trackingState.detectedMarkers.join(', ')}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleTracking() async {
    final trackingState = ref.read(arTrackingStateProvider);
    
    if (trackingState.isTracking) {
      // Pause tracking
      // Implementation would depend on your AR library
    } else {
      // Resume tracking
      // Implementation would depend on your AR library
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSettingsSheet(),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'AR Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera Settings'),
            onTap: () {
              Navigator.pop(context);
              // Show camera settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Video Settings'),
            onTap: () {
              Navigator.pop(context);
              // Show video settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Tracking Settings'),
            onTap: () {
              Navigator.pop(context);
              // Show tracking settings
            },
          ),
        ],
      ),
    );
  }
}