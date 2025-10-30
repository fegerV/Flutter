import 'package:dartz/dartz.dart';
import 'package:flutter_ar_app/domain/entities/device_profile.dart';
import 'package:flutter_ar_app/domain/entities/performance_metrics.dart';

abstract class PerformanceRepository {
  /// Get current device profile and performance tier
  Future<Either<String, DeviceProfile>> getDeviceProfile();
  
  /// Get current performance metrics
  Future<Either<String, PerformanceMetrics>> getCurrentMetrics();
  
  /// Start performance monitoring session
  Future<Either<String, void>> startMonitoring();
  
  /// Stop performance monitoring session
  Future<Either<String, void>> stopMonitoring();
  
  /// Get performance metrics history for a session
  Future<Either<String, List<PerformanceMetrics>>> getMetricsHistory({
    Duration? duration,
    int? limit,
  });
  
  /// Log performance metrics with custom event name
  Future<Either<String, void>> logPerformanceEvent(
    String eventName,
    PerformanceMetrics metrics,
  );
  
  /// Check if device meets minimum requirements for AR features
  Future<Either<String, bool>> checkARRequirements();
  
  /// Get recommended settings based on device performance
  Future<Either<String, Map<String, dynamic>>> getRecommendedSettings();
  
  /// Stream of real-time performance metrics
  Stream<PerformanceMetrics> get metricsStream;
  
  /// Stream of performance alerts and warnings
  Stream<String> get alertsStream;
}