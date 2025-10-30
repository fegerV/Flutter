import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../entity.dart';

part 'ar_marker.g.dart';

@JsonSerializable()
class ARMarker extends Equatable implements Entity {
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

  const ARMarker({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.videoUrl,
    required this.alignment,
    required this.type,
    required this.width,
    required this.height,
    required this.transformMatrix,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ARMarker.fromJson(Map<String, dynamic> json) =>
      _$ARMarkerFromJson(json);

  Map<String, dynamic> toJson() => _$ARMarkerToJson(this);

  ARMarker copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? videoUrl,
    MarkerAlignment? alignment,
    MarkerType? type,
    double? width,
    double? height,
    List<double>? transformMatrix,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ARMarker(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      alignment: alignment ?? this.alignment,
      type: type ?? this.type,
      width: width ?? this.width,
      height: height ?? this.height,
      transformMatrix: transformMatrix ?? this.transformMatrix,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        videoUrl,
        alignment,
        type,
        width,
        height,
        transformMatrix,
        isActive,
        createdAt,
        updatedAt,
      ];
}

enum MarkerType {
  portrait,
  landscape,
  square,
  custom,
}

enum MarkerAlignment {
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
  leftCenter,
  rightCenter,
}

@JsonSerializable()
class MarkerConfiguration extends Equatable implements Entity {
  final String id;
  final String name;
  final List<ARMarker> markers;
  final TrackingSettings trackingSettings;
  final VideoSettings videoSettings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MarkerConfiguration({
    required this.id,
    required this.name,
    required this.markers,
    required this.trackingSettings,
    required this.videoSettings,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory MarkerConfiguration.fromJson(Map<String, dynamic> json) =>
      _$MarkerConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$MarkerConfigurationToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        markers,
        trackingSettings,
        videoSettings,
        isActive,
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class TrackingSettings extends Equatable {
  final double maxTrackingDistance;
  final double minTrackingDistance;
  final double confidenceThreshold;
  final int maxTrackedImages;
  final bool enablePoseSmoothing;
  final double smoothingFactor;

  const TrackingSettings({
    this.maxTrackingDistance = 5.0,
    this.minTrackingDistance = 0.1,
    this.confidenceThreshold = 0.7,
    this.maxTrackedImages = 10,
    this.enablePoseSmoothing = true,
    this.smoothingFactor = 0.3,
  });

  factory TrackingSettings.fromJson(Map<String, dynamic> json) =>
      _$TrackingSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingSettingsToJson(this);

  @override
  List<Object?> get props => [
        maxTrackingDistance,
        minTrackingDistance,
        confidenceThreshold,
        maxTrackedImages,
        enablePoseSmoothing,
        smoothingFactor,
      ];
}

@JsonSerializable()
class VideoSettings extends Equatable {
  final bool autoPlay;
  final bool loop;
  final double volume;
  final PlaybackSpeed playbackSpeed;
  final VideoFit videoFit;
  final bool enableAudio;
  final int bufferSizeMs;

  const VideoSettings({
    this.autoPlay = true,
    this.loop = true,
    this.volume = 1.0,
    this.playbackSpeed = PlaybackSpeed.normal,
    this.videoFit = VideoFit.cover,
    this.enableAudio = false,
    this.bufferSizeMs = 2000,
  });

  factory VideoSettings.fromJson(Map<String, dynamic> json) =>
      _$VideoSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$VideoSettingsToJson(this);

  @override
  List<Object?> get props => [
        autoPlay,
        loop,
        volume,
        playbackSpeed,
        videoFit,
        enableAudio,
        bufferSizeMs,
      ];
}

enum PlaybackSpeed {
  slow(0.5),
  slower(0.75),
  normal(1.0),
  faster(1.25),
  fast(1.5);

  const PlaybackSpeed(this.value);
  final double value;
}

enum VideoFit {
  fill,
  contain,
  cover,
  fitWidth,
  fitHeight,
  none,
}