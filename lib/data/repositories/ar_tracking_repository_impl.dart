import 'dart:async';
import 'dart:math';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:vector_math/vector_math.dart';

import '../../domain/entities/ar_marker.dart';
import '../../domain/entities/ar_tracking.dart';
import '../../domain/repositories/ar_repositories.dart';

@LazySingleton(as: ARTrackingRepository)
class ARTrackingRepositoryImpl implements ARTrackingRepository {
  final ARSessionManager _arSessionManager;
  final ARObjectManager _arObjectManager;
  final ARAnchorManager _arAnchorManager;
  final ARLocationManager _arLocationManager;

  TrackingSettings _trackingSettings = const TrackingSettings();
  ARTrackingState _currentState = ARTrackingState(
    lastUpdate: DateTime.now(),
  );
  
  final Map<String, ARAnchor> _anchors = {};
  final Map<String, List<ARPose>> _poseHistory = {};
  Timer? _trackingTimer;

  ARTrackingRepositoryImpl(
    this._arSessionManager,
    this._arObjectManager,
    this._arAnchorManager,
    this._arLocationManager,
  );

  @override
  Future<Either<Exception, bool>> initializeARSession() async {
    try {
      final sessionConfig = ARSessionConfig(
        planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
        enablePlaneRenderer: true,
        enableUpdateMode: true,
        lightEstimationMode: ARConfigLightEstimationMode.ambientIntensity,
      );

      await _arSessionManager.onInitialize(
        featureMapEnabled: true,
        planeDetectionEnabled: true,
        planeOcclusionEnabled: true,
        updateEnabled: true,
      );

      _startTrackingTimer();
      
      _currentState = _currentState.copyWith(
        isInitialized: true,
        lastUpdate: DateTime.now(),
      );

      return const Right(true);
    } catch (e) {
      return Left(Exception('Failed to initialize AR session: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> addMarkersToTrack(List<ARMarker> markers) async {
    try {
      for (final marker in markers) {
        // Create AR nodes for marker tracking
        final node = ARNode(
          type: NodeType.localGLTF2,
          uri: marker.imageUrl,
          scale: Vector3(marker.width, marker.height, 1.0),
          position: Vector3.zero(),
          rotation: Vector4.zero(),
        );

        final result = await _arObjectManager.addNode(node);
        
        if (result) {
          _currentState = _currentState.copyWith(
            detectedMarkers: [..._currentState.detectedMarkers, marker.id],
            lastUpdate: DateTime.now(),
          );
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to add markers to track: $e'));
    }
  }

  @override
  Future<Either<Exception, ARTrackingState>> getTrackingState() async {
    try {
      // Get current tracking results from AR session
      final anchors = _arAnchorManager.anchors;
      final trackingResults = <String, ARTrackingResult>{};
      final detectedMarkers = <String>[];

      for (final anchor in anchors) {
        if (anchor.name?.isNotEmpty == true) {
          final transform = _getTransformFromAnchor(anchor);
          final pose = _extractPoseFromTransform(transform);
          
          final result = ARTrackingResult(
            markerId: anchor.name!,
            isTracking: true,
            transformMatrix: transform,
            confidence: _calculateConfidence(anchor),
            timestamp: DateTime.now(),
            position: pose.position,
            rotation: pose.rotation,
            scale: pose.scale,
          );

          trackingResults[anchor.name!] = result;
          detectedMarkers.add(anchor.name!);

          // Update pose history for smoothing
          _updatePoseHistory(anchor.name!, pose);
        }
      }

      _currentState = _currentState.copyWith(
        isTracking: trackingResults.isNotEmpty,
        detectedMarkers: detectedMarkers,
        trackingResults: trackingResults,
        lastUpdate: DateTime.now(),
      );

      return Right(_currentState);
    } catch (e) {
      return Left(Exception('Failed to get tracking state: $e'));
    }
  }

  @override
  Future<Either<Exception, List<ARTrackingResult>>> getTrackingResults() async {
    try {
      final stateResult = await getTrackingState();
      return stateResult.fold(
        (error) => Left(error),
        (state) => Right(state.trackingResults.values.toList()),
      );
    } catch (e) {
      return Left(Exception('Failed to get tracking results: $e'));
    }
  }

  @override
  Future<Either<Exception, SmoothedPose>> getSmoothedPose(String markerId) async {
    try {
      final poseHistory = _poseHistory[markerId] ?? [];
      
      if (poseHistory.isEmpty) {
        return Left(Exception('No pose history available for marker $markerId'));
      }

      final currentPose = poseHistory.last;
      var smoothedPose = currentPose;

      if (poseHistory.length > 1 && _trackingSettings.enablePoseSmoothing) {
        final previousPose = poseHistory[poseHistory.length - 2];
        smoothedPose = _applySmoothing(currentPose, previousPose);
      }

      final isStable = _isPoseStable(poseHistory);
      final velocity = _calculateVelocity(currentPose, poseHistory.length > 1 ? poseHistory[poseHistory.length - 2] : null);

      final result = SmoothedPose(
        currentPose: currentPose,
        smoothedPose: smoothedPose,
        smoothingFactor: _trackingSettings.smoothingFactor,
        isStable: isStable,
        velocity: velocity,
        timestamp: DateTime.now(),
      );

      return Right(result);
    } catch (e) {
      return Left(Exception('Failed to get smoothed pose: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateTrackingSettings(TrackingSettings settings) async {
    try {
      _trackingSettings = settings;
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to update tracking settings: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> pauseTracking() async {
    try {
      _trackingTimer?.cancel();
      _currentState = _currentState.copyWith(
        isTracking: false,
        lastUpdate: DateTime.now(),
      );
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to pause tracking: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> resumeTracking() async {
    try {
      _startTrackingTimer();
      _currentState = _currentState.copyWith(
        isTracking: true,
        lastUpdate: DateTime.now(),
      );
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to resume tracking: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> stopTracking() async {
    try {
      _trackingTimer?.cancel();
      
      // Remove all anchors
      for (final anchor in _anchors.values) {
        await _arAnchorManager.removeAnchor(anchor);
      }
      _anchors.clear();
      _poseHistory.clear();

      _currentState = ARTrackingState(
        lastUpdate: DateTime.now(),
      );

      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to stop tracking: $e'));
    }
  }

  void _startTrackingTimer() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(
      const Duration(milliseconds: 33), // ~30 FPS
      (_) => getTrackingState(),
    );
  }

  Matrix4 _getTransformFromAnchor(ARAnchor anchor) {
    // Convert AR anchor transform to Matrix4
    return Matrix4.identity();
  }

  ARPose _extractPoseFromTransform(Matrix4 transform) {
    final translation = transform.getTranslation();
    final rotation = Quaternion.fromRotation(transform.getRotation());
    final scale = transform.getMaxScaleOnAxis();

    return ARPose(
      transform: transform,
      position: Vector3(translation.x, translation.y, translation.z),
      rotation: rotation,
      scale: Vector3.all(scale),
      confidence: 1.0,
      timestamp: DateTime.now(),
    );
  }

  double _calculateConfidence(ARAnchor anchor) {
    // Calculate tracking confidence based on various factors
    // This is a simplified implementation
    return Random().nextDouble() * 0.3 + 0.7; // 0.7 to 1.0
  }

  void _updatePoseHistory(String markerId, ARPose pose) {
    final history = _poseHistory[markerId] ?? [];
    history.add(pose);
    
    // Keep only recent poses (last 10)
    if (history.length > 10) {
      history.removeAt(0);
    }
    
    _poseHistory[markerId] = history;
  }

  ARPose _applySmoothing(ARPose currentPose, ARPose previousPose) {
    final factor = _trackingSettings.smoothingFactor;
    
    final smoothedPosition = Vector3.lerp(
      previousPose.position,
      currentPose.position,
      factor,
    );
    
    final smoothedRotation = previousPose.rotation.slerp(
      currentPose.rotation,
      factor,
    );
    
    final smoothedScale = Vector3.lerp(
      previousPose.scale,
      currentPose.scale,
      factor,
    );

    return ARPose(
      transform: Matrix4.compose(
        smoothedPosition,
        smoothedRotation,
        smoothedScale,
      ),
      position: smoothedPosition,
      rotation: smoothedRotation,
      scale: smoothedScale,
      confidence: (currentPose.confidence + previousPose.confidence) / 2,
      timestamp: DateTime.now(),
    );
  }

  bool _isPoseStable(List<ARPose> poses) {
    if (poses.length < 3) return false;

    final recent = poses.takeLast(3).toList();
    double totalVariation = 0.0;

    for (int i = 1; i < recent.length; i++) {
      final delta = recent[i].position.distanceTo(recent[i - 1].position);
      totalVariation += delta;
    }

    return totalVariation < 0.01; // Threshold for stability
  }

  double _calculateVelocity(ARPose currentPose, ARPose? previousPose) {
    if (previousPose == null) return 0.0;

    final distance = currentPose.position.distanceTo(previousPose.position);
    final timeDelta = currentPose.timestamp.difference(previousPose.timestamp).inMilliseconds;
    
    return timeDelta > 0 ? distance / (timeDelta / 1000.0) : 0.0;
  }
}