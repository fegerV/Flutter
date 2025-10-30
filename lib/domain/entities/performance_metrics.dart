import 'package:equatable/equatable.dart';

class PerformanceMetrics extends Equatable {
  final double fps;
  final double cpuUsage;
  final double gpuUsage;
  final double batteryLevel;
  final bool isCharging;
  final int memoryUsage;
  final int availableMemory;
  final DateTime timestamp;
  final String deviceModel;
  final String deviceBrand;

  const PerformanceMetrics({
    required this.fps,
    required this.cpuUsage,
    required this.gpuUsage,
    required this.batteryLevel,
    required this.isCharging,
    required this.memoryUsage,
    required this.availableMemory,
    required this.timestamp,
    required this.deviceModel,
    required this.deviceBrand,
  });

  double get batteryDrainRate => batteryLevel;

  int get totalMemory => memoryUsage + availableMemory;

  double get memoryUsagePercentage => totalMemory > 0 ? (memoryUsage / totalMemory) * 100 : 0;

  @override
  List<Object?> get props => [
        fps,
        cpuUsage,
        gpuUsage,
        batteryLevel,
        isCharging,
        memoryUsage,
        availableMemory,
        timestamp,
        deviceModel,
        deviceBrand,
      ];

  PerformanceMetrics copyWith({
    double? fps,
    double? cpuUsage,
    double? gpuUsage,
    double? batteryLevel,
    bool? isCharging,
    int? memoryUsage,
    int? availableMemory,
    DateTime? timestamp,
    String? deviceModel,
    String? deviceBrand,
  }) {
    return PerformanceMetrics(
      fps: fps ?? this.fps,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      gpuUsage: gpuUsage ?? this.gpuUsage,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      availableMemory: availableMemory ?? this.availableMemory,
      timestamp: timestamp ?? this.timestamp,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceBrand: deviceBrand ?? this.deviceBrand,
    );
  }

  @override
  String toString() {
    return 'PerformanceMetrics(fps: $fps, cpu: ${cpuUsage.toStringAsFixed(1)}%, '
        'gpu: ${gpuUsage.toStringAsFixed(1)}%, battery: ${batteryLevel.toStringAsFixed(1)}%, '
        'memory: ${memoryUsagePercentage.toStringAsFixed(1)}%)';
  }
}