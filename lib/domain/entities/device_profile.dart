import 'package:equatable/equatable.dart';

enum DeviceTier {
  flagship,
  midTier,
  lowEnd,
}

class DeviceProfile extends Equatable {
  final String model;
  final String brand;
  final DeviceTier tier;
  final int totalMemory;
  final int cpuCores;
  final String gpuRenderer;
  final double screenSize;
  final int screenWidth;
  final int screenHeight;
  final String androidVersion;
  final int sdkVersion;

  const DeviceProfile({
    required this.model,
    required this.brand,
    required this.tier,
    required this.totalMemory,
    required this.cpuCores,
    required this.gpuRenderer,
    required this.screenSize,
    required this.screenWidth,
    required this.screenHeight,
    required this.androidVersion,
    required this.sdkVersion,
  });

  bool get isHighPerformance => tier == DeviceTier.flagship;
  
  bool get isLowPerformance => tier == DeviceTier.lowEnd;
  
  bool get supportsAdvancedAR => !isLowPerformance;
  
  bool get supportsHighResolutionVideo => tier != DeviceTier.lowEnd;

  @override
  List<Object?> get props => [
        model,
        brand,
        tier,
        totalMemory,
        cpuCores,
        gpuRenderer,
        screenSize,
        screenWidth,
        screenHeight,
        androidVersion,
        sdkVersion,
      ];

  @override
  String toString() {
    return 'DeviceProfile($brand $model, tier: $tier, memory: ${totalMemory}MB, cores: $cpuCores)';
  }
}