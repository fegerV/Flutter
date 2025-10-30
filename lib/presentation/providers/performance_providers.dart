import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ar_app/data/repositories/performance_repository_impl.dart';
import 'package:flutter_ar_app/data/services/performance_service.dart';
import 'package:flutter_ar_app/domain/repositories/performance_repository.dart';
import 'package:flutter_ar_app/domain/usecases/check_ar_requirements_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/get_device_profile_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/get_performance_metrics_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/start_performance_monitoring_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/stop_performance_monitoring_usecase.dart';
import 'package:flutter_ar_app/presentation/providers/performance_provider.dart';

// Service providers
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

final performanceRepositoryProvider = Provider<PerformanceRepository>((ref) {
  final performanceService = ref.watch(performanceServiceProvider);
  return PerformanceRepositoryImpl(
    performanceService,
    // DeviceInfoPlugin and Battery will be created internally
  );
});

// Use case providers
final getDeviceProfileUseCaseProvider = Provider<GetDeviceProfileUseCase>((ref) {
  final repository = ref.watch(performanceRepositoryProvider);
  return GetDeviceProfileUseCase(repository);
});

final getPerformanceMetricsUseCaseProvider = Provider<GetPerformanceMetricsUseCase>((ref) {
  final repository = ref.watch(performanceRepositoryProvider);
  return GetPerformanceMetricsUseCase(repository);
});

final startPerformanceMonitoringUseCaseProvider = Provider<StartPerformanceMonitoringUseCase>((ref) {
  final repository = ref.watch(performanceRepositoryProvider);
  return StartPerformanceMonitoringUseCase(repository);
});

final stopPerformanceMonitoringUseCaseProvider = Provider<StopPerformanceMonitoringUseCase>((ref) {
  final repository = ref.watch(performanceRepositoryProvider);
  return StopPerformanceMonitoringUseCase(repository);
});

final checkARRequirementsUseCaseProvider = Provider<CheckARRequirementsUseCase>((ref) {
  final repository = ref.watch(performanceRepositoryProvider);
  return CheckARRequirementsUseCase(repository);
});

// Main provider
final performanceProvider = StateNotifierProvider<PerformanceNotifier, PerformanceState>((ref) {
  return PerformanceNotifier(
    ref.watch(getDeviceProfileUseCaseProvider),
    ref.watch(getPerformanceMetricsUseCaseProvider),
    ref.watch(startPerformanceMonitoringUseCaseProvider),
    ref.watch(stopPerformanceMonitoringUseCaseProvider),
    ref.watch(checkARRequirementsUseCaseProvider),
    ref.watch(performanceRepositoryProvider),
  );
});