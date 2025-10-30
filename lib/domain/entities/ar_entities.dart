import 'package:equatable/equatable.dart';

enum ArTrackingState {
  none,
  initializing,
  tracking,
  paused,
  stopped,
  error,
}

enum ArLightingCondition {
  unknown,
  dark,
  moderate,
  bright,
  tooBright,
}

enum ArSessionStatus {
  notReady,
  ready,
  unsupported,
  missingPermissions,
  error,
}

class ArTrackingInfo extends Equatable {
  final ArTrackingState state;
  final ArLightingCondition lighting;
  final String? errorMessage;
  final bool isDeviceSupported;
  final double confidence;

  const ArTrackingInfo({
    required this.state,
    required this.lighting,
    this.errorMessage,
    required this.isDeviceSupported,
    required this.confidence,
  });

  @override
  List<Object?> get props => [
        state,
        lighting,
        errorMessage,
        isDeviceSupported,
        confidence,
      ];

  ArTrackingInfo copyWith({
    ArTrackingState? state,
    ArLightingCondition? lighting,
    String? errorMessage,
    bool? isDeviceSupported,
    double? confidence,
  }) {
    return ArTrackingInfo(
      state: state ?? this.state,
      lighting: lighting ?? this.lighting,
      errorMessage: errorMessage ?? this.errorMessage,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      confidence: confidence ?? this.confidence,
    );
  }
}

class ArDeviceCompatibility extends Equatable {
  final bool isSupported;
  final String? reason;
  final bool requiresArCore;
  final String? minimumArCoreVersion;

  const ArDeviceCompatibility({
    required this.isSupported,
    this.reason,
    required this.requiresArCore,
    this.minimumArCoreVersion,
  });

  @override
  List<Object?> get props => [
        isSupported,
        reason,
        requiresArCore,
        minimumArCoreVersion,
      ];
}