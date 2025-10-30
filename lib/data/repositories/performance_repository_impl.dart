import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_ar_app/data/services/performance_service.dart';
import 'package:flutter_ar_app/domain/entities/device_profile.dart';
import 'package:flutter_ar_app/domain/entities/performance_metrics.dart';
import 'package:flutter_ar_app/domain/repositories/performance_repository.dart';

class PerformanceRepositoryImpl implements PerformanceRepository {
  final PerformanceService _performanceService;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final Battery _battery;
  
  StreamSubscription<PerformanceMetrics>? _metricsSubscription;
  StreamSubscription<String>? _alertsSubscription;

  PerformanceRepositoryImpl(
    this._performanceService,
    this._deviceInfoPlugin,
    this._battery,
  );

  @override
  Future<Either<String, DeviceProfile>> getDeviceProfile() async {
    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      final tier = _determineDeviceTier(androidInfo);
      
      final deviceProfile = DeviceProfile(
        model: androidInfo.model,
        brand: androidInfo.brand,
        tier: tier,
        totalMemory: androidInfo.totalMemory ?? 0,
        cpuCores: Platform.numberOfProcessors,
        gpuRenderer: 'Unknown', // Would need additional GPU detection
        screenSize: 0.0, // Would need additional screen detection
        screenWidth: androidInfo.displayMetrics.widthPx.toInt(),
        screenHeight: androidInfo.displayMetrics.heightPx.toInt(),
        androidVersion: androidInfo.version.release,
        sdkVersion: androidInfo.version.sdkInt,
      );

      return Right(deviceProfile);
    } catch (e) {
      return Left('Failed to get device profile: $e');
    }
  }

  @override
  Future<Either<String, PerformanceMetrics>> getCurrentMetrics() async {
    try {
      final metrics = await _performanceService.getCurrentMetrics();
      return Right(metrics);
    } catch (e) {
      return Left('Failed to get performance metrics: $e');
    }
  }

  @override
  Future<Either<String, void>> startMonitoring() async {
    try {
      await _performanceService.startMonitoring();
      return const Right(null);
    } catch (e) {
      return Left('Failed to start performance monitoring: $e');
    }
  }

  @override
  Future<Either<String, void>> stopMonitoring() async {
    try {
      await _performanceService.stopMonitoring();
      return const Right(null);
    } catch (e) {
      return Left('Failed to stop performance monitoring: $e');
    }
  }

  @override
  Future<Either<String, List<PerformanceMetrics>>> getMetricsHistory({
    Duration? duration,
    int? limit,
  }) async {
    try {
      final metrics = await _performanceService.getMetricsHistory(
        duration: duration,
        limit: limit,
      );
      return Right(metrics);
    } catch (e) {
      return Left('Failed to get metrics history: $e');
    }
  }

  @override
  Future<Either<String, void>> logPerformanceEvent(
    String eventName,
    PerformanceMetrics metrics,
  ) async {
    try {
      await _performanceService.logPerformanceEvent(eventName, metrics);
      return const Right(null);
    } catch (e) {
      return Left('Failed to log performance event: $e');
    }
  }

  @override
  Future<Either<String, bool>> checkARRequirements() async {
    try {
      final deviceProfileResult = await getDeviceProfile();
      return deviceProfileResult.fold(
        (error) => Left(error),
        (profile) => Right(_checkARRequirements(profile)),
      );
    } catch (e) {
      return Left('Failed to check AR requirements: $e');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getRecommendedSettings() async {
    try {
      final deviceProfileResult = await getDeviceProfile();
      return deviceProfileResult.fold(
        (error) => Left(error),
        (profile) => Right(_getRecommendedSettings(profile)),
      );
    } catch (e) {
      return Left('Failed to get recommended settings: $e');
    }
  }

  @override
  Stream<PerformanceMetrics> get metricsStream {
    return _performanceService.metricsStream;
  }

  @override
  Stream<String> get alertsStream {
    return _performanceService.alertsStream;
  }

  DeviceTier _determineDeviceTier(AndroidDeviceInfo androidInfo) {
    final totalMemoryGB = (androidInfo.totalMemory ?? 0) / (1024 * 1024 * 1024);
    final sdkVersion = androidInfo.version.sdkInt;
    
    // Flagship devices: 8GB+ RAM, recent Android version
    if (totalMemoryGB >= 8 && sdkVersion >= 30) {
      return DeviceTier.flagship;
    }
    
    // Mid-tier devices: 4-8GB RAM, reasonably recent Android
    if (totalMemoryGB >= 4 && sdkVersion >= 28) {
      return DeviceTier.midTier;
    }
    
    // Low-end devices: less than 4GB RAM or older Android
    return DeviceTier.lowEnd;
  }

  bool _checkARRequirements(DeviceProfile profile) {
    // Minimum requirements for AR functionality
    return profile.sdkVersion >= 24 && // Android 7.0+
           profile.totalMemory >= 2 * 1024 * 1024 * 1024 && // 2GB RAM minimum
           profile.cpuCores >= 4; // Quad-core minimum
  }

  Map<String, dynamic> _getRecommendedSettings(DeviceProfile profile) {
    switch (profile.tier) {
      case DeviceTier.flagship:
        return {
          'video_quality': '1080p',
          'ar_refresh_rate': 60,
          'enable_advanced_effects': true,
          'max_concurrent_animations': 5,
          'cache_size_mb': 500,
        };
      case DeviceTier.midTier:
        return {
          'video_quality': '720p',
          'ar_refresh_rate': 30,
          'enable_advanced_effects': false,
          'max_concurrent_animations': 3,
          'cache_size_mb': 200,
        };
      case DeviceTier.lowEnd:
        return {
          'video_quality': '480p',
          'ar_refresh_rate': 15,
          'enable_advanced_effects': false,
          'max_concurrent_animations': 1,
          'cache_size_mb': 100,
        };
    }
  }
}