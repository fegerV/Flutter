import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vector_math/vector_math.dart';

import '../entity.dart';
import 'ar_marker.dart';

part 'ar_tracking.g.dart';

@JsonSerializable()
class ARTrackingResult extends Equatable implements Entity {
  final String markerId;
  final bool isTracking;
  final Matrix4 transformMatrix;
  final double confidence;
  final DateTime timestamp;
  final Vector3 position;
  final Quaternion rotation;
  final Vector3 scale;

  const ARTrackingResult({
    required this.markerId,
    required this.isTracking,
    required this.transformMatrix,
    required this.confidence,
    required this.timestamp,
    required this.position,
    required this.rotation,
    required this.scale,
  });

  factory ARTrackingResult.fromJson(Map<String, dynamic> json) =>
      _$ARTrackingResultFromJson(json);

  Map<String, dynamic> toJson() => _$ARTrackingResultToJson(this);

  @override
  List<Object?> get props => [
        markerId,
        isTracking,
        transformMatrix,
        confidence,
        timestamp,
        position,
        rotation,
        scale,
      ];
}

@JsonSerializable()
class ARPose extends Equatable implements Entity {
  final Matrix4 transform;
  final Vector3 position;
  final Quaternion rotation;
  final Vector3 scale;
  final double confidence;
  final DateTime timestamp;

  const ARPose({
    required this.transform,
    required this.position,
    required this.rotation,
    required this.scale,
    required this.confidence,
    required this.timestamp,
  });

  factory ARPose.fromJson(Map<String, dynamic> json) =>
      _$ARPoseFromJson(json);

  Map<String, dynamic> toJson() => _$ARPoseToJson(this);

  @override
  List<Object?> get props => [
        transform,
        position,
        rotation,
        scale,
        confidence,
        timestamp,
      ];
}

@JsonSerializable()
class SmoothedPose extends Equatable implements Entity {
  final ARPose currentPose;
  final ARPose smoothedPose;
  final double smoothingFactor;
  final bool isStable;
  final double velocity;
  final DateTime timestamp;

  const SmoothedPose({
    required this.currentPose,
    required this.smoothedPose,
    required this.smoothingFactor,
    required this.isStable,
    required this.velocity,
    required this.timestamp,
  });

  factory SmoothedPose.fromJson(Map<String, dynamic> json) =>
      _$SmoothedPoseFromJson(json);

  Map<String, dynamic> toJson() => _$SmoothedPoseToJson(this);

  @override
  List<Object?> get props => [
        currentPose,
        smoothedPose,
        smoothingFactor,
        isStable,
        velocity,
        timestamp,
      ];
}

@JsonSerializable()
class ARTrackingState extends Equatable implements Entity {
  final bool isInitialized;
  final bool isTracking;
  final List<String> detectedMarkers;
  final Map<String, ARTrackingResult> trackingResults;
  final String? errorMessage;
  final DateTime lastUpdate;

  const ARTrackingState({
    this.isInitialized = false,
    this.isTracking = false,
    this.detectedMarkers = const [],
    this.trackingResults = const {},
    this.errorMessage,
    required this.lastUpdate,
  });

  factory ARTrackingState.fromJson(Map<String, dynamic> json) =>
      _$ARTrackingStateFromJson(json);

  Map<String, dynamic> toJson() => _$ARTrackingStateToJson(this);

  ARTrackingState copyWith({
    bool? isInitialized,
    bool? isTracking,
    List<String>? detectedMarkers,
    Map<String, ARTrackingResult>? trackingResults,
    String? errorMessage,
    DateTime? lastUpdate,
  }) {
    return ARTrackingState(
      isInitialized: isInitialized ?? this.isInitialized,
      isTracking: isTracking ?? this.isTracking,
      detectedMarkers: detectedMarkers ?? this.detectedMarkers,
      trackingResults: trackingResults ?? this.trackingResults,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  List<Object?> get props => [
        isInitialized,
        isTracking,
        detectedMarkers,
        trackingResults,
        errorMessage,
        lastUpdate,
      ];
}

enum TrackingStatus {
  initializing,
  ready,
  tracking,
  lost,
  error,
}

@JsonSerializable()
class VideoOverlayState extends Equatable implements Entity {
  final String markerId;
  final bool isPlaying;
  final bool isLoaded;
  final Duration position;
  final Duration duration;
  final bool hasError;
  final String? errorMessage;
  final DateTime lastUpdate;

  const VideoOverlayState({
    required this.markerId,
    this.isPlaying = false,
    this.isLoaded = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.hasError = false,
    this.errorMessage,
    required this.lastUpdate,
  });

  factory VideoOverlayState.fromJson(Map<String, dynamic> json) =>
      _$VideoOverlayStateFromJson(json);

  Map<String, dynamic> toJson() => _$VideoOverlayStateToJson(this);

  VideoOverlayState copyWith({
    String? markerId,
    bool? isPlaying,
    bool? isLoaded,
    Duration? position,
    Duration? duration,
    bool? hasError,
    String? errorMessage,
    DateTime? lastUpdate,
  }) {
    return VideoOverlayState(
      markerId: markerId ?? this.markerId,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoaded: isLoaded ?? this.isLoaded,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  List<Object?> get props => [
        markerId,
        isPlaying,
        isLoaded,
        position,
        duration,
        hasError,
        errorMessage,
        lastUpdate,
      ];
}