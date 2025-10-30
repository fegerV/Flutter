import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ar_app/domain/entities/device_profile.dart';
import 'package:flutter_ar_app/domain/entities/performance_metrics.dart';
import 'package:flutter_ar_app/domain/repositories/performance_repository.dart';
import 'package:flutter_ar_app/domain/usecases/check_ar_requirements_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/get_device_profile_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/get_performance_metrics_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/start_performance_monitoring_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/stop_performance_monitoring_usecase.dart';

class PerformanceState {
  final bool isLoading;
  final String? error;
  final DeviceProfile? deviceProfile;
  final PerformanceMetrics? currentMetrics;
  final List<PerformanceMetrics> metricsHistory;
  final bool isMonitoring;
  final bool meetsARRequirements;
  final Map<String, dynamic>? recommendedSettings;
  final List<String> alerts;
  final Map<String, dynamic> settings;

  const PerformanceState({
    this.isLoading = false,
    this.error,
    this.deviceProfile,
    this.currentMetrics,
    this.metricsHistory = const [],
    this.isMonitoring = false,
    this.meetsARRequirements = false,
    this.recommendedSettings,
    this.alerts = const [],
    this.settings = const {},
  });

  PerformanceState copyWith({
    bool? isLoading,
    String? error,
    DeviceProfile? deviceProfile,
    PerformanceMetrics? currentMetrics,
    List<PerformanceMetrics>? metricsHistory,
    bool? isMonitoring,
    bool? meetsARRequirements,
    Map<String, dynamic>? recommendedSettings,
    List<String>? alerts,
    Map<String, dynamic>? settings,
  }) {
    return PerformanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      deviceProfile: deviceProfile ?? this.deviceProfile,
      currentMetrics: currentMetrics ?? this.currentMetrics,
      metricsHistory: metricsHistory ?? this.metricsHistory,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      meetsARRequirements: meetsARRequirements ?? this.meetsARRequirements,
      recommendedSettings: recommendedSettings ?? this.recommendedSettings,
      alerts: alerts ?? this.alerts,
      settings: settings ?? this.settings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceState &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.deviceProfile == deviceProfile &&
        other.currentMetrics == currentMetrics &&
        other.isMonitoring == isMonitoring &&
        other.meetsARRequirements == meetsARRequirements &&
        other.recommendedSettings == recommendedSettings &&
        other.settings == settings;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      error,
      deviceProfile,
      currentMetrics,
      isMonitoring,
      meetsARRequirements,
      recommendedSettings,
      settings,
    );
  }
}

class PerformanceNotifier extends StateNotifier<PerformanceState> {
  final GetDeviceProfileUseCase _getDeviceProfileUseCase;
  final GetPerformanceMetricsUseCase _getPerformanceMetricsUseCase;
  final StartPerformanceMonitoringUseCase _startPerformanceMonitoringUseCase;
  final StopPerformanceMonitoringUseCase _stopPerformanceMonitoringUseCase;
  final CheckARRequirementsUseCase _checkARRequirementsUseCase;
  final PerformanceRepository _repository;

  PerformanceNotifier(
    this._getDeviceProfileUseCase,
    this._getPerformanceMetricsUseCase,
    this._startPerformanceMonitoringUseCase,
    this._stopPerformanceMonitoringUseCase,
    this._checkARRequirementsUseCase,
    this._repository,
  ) : super(const PerformanceState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await getDeviceProfile();
    await checkARRequirements();
    _setupStreams();
  }

  Future<void> getDeviceProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _getDeviceProfileUseCase(NoParams());
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (profile) => state = state.copyWith(
        isLoading: false,
        deviceProfile: profile,
        settings: _getRecommendedSettings(profile),
      ),
    );
  }

  Future<void> getCurrentMetrics() async {
    final result = await _getPerformanceMetricsUseCase(NoParams());
    result.fold(
      (error) => state = state.copyWith(error: error),
      (metrics) => state = state.copyWith(currentMetrics: metrics),
    );
  }

  Future<void> startMonitoring() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _startPerformanceMonitoringUseCase(NoParams());
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (_) => state = state.copyWith(isLoading: false, isMonitoring: true),
    );
  }

  Future<void> stopMonitoring() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _stopPerformanceMonitoringUseCase(NoParams());
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (_) => state = state.copyWith(isLoading: false, isMonitoring: false),
    );
  }

  Future<void> checkARRequirements() async {
    final result = await _checkARRequirementsUseCase(NoParams());
    result.fold(
      (error) => state = state.copyWith(error: error),
      (meetsRequirements) => state = state.copyWith(
        meetsARRequirements: meetsRequirements,
      ),
    );
  }

  Future<void> getRecommendedSettings() async {
    if (state.deviceProfile == null) return;
    
    final settings = _getRecommendedSettings(state.deviceProfile!);
    state = state.copyWith(settings: settings);
  }

  void _setupStreams() {
    // Listen to metrics stream
    _repository.metricsStream.listen((metrics) {
      state = state.copyWith(
        currentMetrics: metrics,
        metricsHistory: [...state.metricsHistory, metrics].take(100).toList(),
      );
    });

    // Listen to alerts stream
    _repository.alertsStream.listen((alert) {
      state = state.copyWith(
        alerts: [...state.alerts, alert].take(50).toList(),
      );
    });
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

  void clearAlerts() {
    state = state.copyWith(alerts: []);
  }

  void updateSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(state.settings);
    updatedSettings[key] = value;
    state = state.copyWith(settings: updatedSettings);
  }
}