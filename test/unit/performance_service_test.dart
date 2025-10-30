import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_ar_app/data/services/performance_service.dart';
import 'package:flutter_ar_app/domain/entities/performance_metrics.dart';

@GenerateMocks([])
void main() {
  group('PerformanceService Tests', () {
    late PerformanceService performanceService;

    setUp(() {
      performanceService = PerformanceService();
    });

    tearDown(() async {
      await performanceService.dispose();
    });

    test('should initialize with correct default values', () {
      expect(performanceService.metricsStream, isNotNull);
      expect(performanceService.alertsStream, isNotNull);
    });

    test('should get current performance metrics', () async {
      final metrics = await performanceService.getCurrentMetrics();
      
      expect(metrics, isA<PerformanceMetrics>());
      expect(metrics.fps, greaterThanOrEqualTo(0.0));
      expect(metrics.cpuUsage, greaterThanOrEqualTo(0.0));
      expect(metrics.gpuUsage, greaterThanOrEqualTo(0.0));
      expect(metrics.batteryLevel, greaterThanOrEqualTo(0.0));
      expect(metrics.batteryLevel, lessThanOrEqualTo(100.0));
      expect(metrics.memoryUsage, greaterThanOrEqualTo(0));
      expect(metrics.availableMemory, greaterThanOrEqualTo(0));
      expect(metrics.deviceModel, isNotEmpty);
      expect(metrics.deviceBrand, isNotEmpty);
      expect(metrics.timestamp, isNotNull);
    });

    test('should start and stop monitoring', () async {
      // Start monitoring
      await performanceService.startMonitoring();
      
      // Wait a bit for monitoring to start
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Stop monitoring
      await performanceService.stopMonitoring();
      
      // Should not throw any exceptions
      expect(true, isTrue);
    });

    test('should emit metrics when monitoring is active', () async {
      final metricsList = <PerformanceMetrics>[];
      
      // Listen to metrics stream
      performanceService.metricsStream.listen(metricsList.add);
      
      // Start monitoring
      await performanceService.startMonitoring();
      
      // Wait for some metrics to be collected
      await Future.delayed(const Duration(seconds: 2));
      
      // Stop monitoring
      await performanceService.stopMonitoring();
      
      // Should have collected some metrics
      expect(metricsList.isNotEmpty, isTrue);
      
      // Verify metrics structure
      for (final metrics in metricsList) {
        expect(metrics.fps, greaterThanOrEqualTo(0.0));
        expect(metrics.cpuUsage, greaterThanOrEqualTo(0.0));
        expect(metrics.gpuUsage, greaterThanOrEqualTo(0.0));
        expect(metrics.batteryLevel, greaterThanOrEqualTo(0.0));
        expect(metrics.batteryLevel, lessThanOrEqualTo(100.0));
      }
    });

    test('should get metrics history', () async {
      // Start monitoring
      await performanceService.startMonitoring();
      
      // Wait for some metrics to be collected
      await Future.delayed(const Duration(seconds: 2));
      
      // Get metrics history
      final history = await performanceService.getMetricsHistory();
      
      // Should have some history
      expect(history, isNotEmpty);
      
      // Verify history structure
      for (final metrics in history) {
        expect(metrics, isA<PerformanceMetrics>());
      }
      
      // Stop monitoring
      await performanceService.stopMonitoring();
    });

    test('should limit metrics history size', () async {
      // Start monitoring
      await performanceService.startMonitoring();
      
      // Wait for metrics to be collected
      await Future.delayed(const Duration(seconds: 3));
      
      // Get limited history
      final limitedHistory = await performanceService.getMetricsHistory(limit: 5);
      
      // Should be limited to 5 items
      expect(limitedHistory.length, lessThanOrEqualTo(5));
      
      // Stop monitoring
      await performanceService.stopMonitoring();
    });

    test('should filter metrics history by duration', () async {
      // Start monitoring
      await performanceService.startMonitoring();
      
      // Wait for metrics to be collected
      await Future.delayed(const Duration(seconds: 2));
      
      // Get recent history (last 1 second)
      final recentHistory = await performanceService.getMetricsHistory(
        duration: const Duration(seconds: 1),
      );
      
      // Should have recent metrics
      expect(recentHistory, isNotEmpty);
      
      // Verify timestamps are recent
      final now = DateTime.now();
      for (final metrics in recentHistory) {
        final timeDiff = now.difference(metrics.timestamp);
        expect(timeDiff.inMilliseconds, lessThan(1500)); // Allow some margin
      }
      
      // Stop monitoring
      await performanceService.stopMonitoring();
    });

    test('should log performance events', () async {
      final metrics = await performanceService.getCurrentMetrics();
      
      // Should not throw when logging event
      await performanceService.logPerformanceEvent('test_event', metrics);
      
      // No exception means success
      expect(true, isTrue);
    });

    test('should emit alerts for performance issues', () async {
      final alerts = <String>[];
      
      // Listen to alerts stream
      performanceService.alertsStream.listen(alerts.add);
      
      // Start monitoring
      await performanceService.startMonitoring();
      
      // Wait for potential alerts
      await Future.delayed(const Duration(seconds: 3));
      
      // Stop monitoring
      await performanceService.stopMonitoring();
      
      // Alerts might be generated depending on system performance
      // We just verify the stream works correctly
      expect(alerts, isA<List<String>>());
    });

    test('should handle multiple start/stop cycles', () async {
      // Test multiple start/stop cycles
      for (int i = 0; i < 3; i++) {
        await performanceService.startMonitoring();
        await Future.delayed(const Duration(milliseconds: 500));
        await performanceService.stopMonitoring();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Should not throw any exceptions
      expect(true, isTrue);
    });

    test('should handle concurrent monitoring requests', () async {
      // Start monitoring multiple times
      await Future.wait([
        performanceService.startMonitoring(),
        performanceService.startMonitoring(),
        performanceService.startMonitoring(),
      ]);
      
      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stop monitoring multiple times
      await Future.wait([
        performanceService.stopMonitoring(),
        performanceService.stopMonitoring(),
        performanceService.stopMonitoring(),
      ]);
      
      // Should not throw any exceptions
      expect(true, isTrue);
    });

    test('should calculate memory usage percentage correctly', () async {
      final metrics = await performanceService.getCurrentMetrics();
      
      // Memory usage percentage should be between 0 and 100
      expect(metrics.memoryUsagePercentage, greaterThanOrEqualTo(0.0));
      expect(metrics.memoryUsagePercentage, lessThanOrEqualTo(100.0));
    });

    test('should calculate total memory correctly', () async {
      final metrics = await performanceService.getCurrentMetrics();
      
      // Total memory should be sum of used and available
      expect(metrics.totalMemory, metrics.memoryUsage + metrics.availableMemory);
    });

    test('should format metrics string correctly', () async {
      final metrics = await performanceService.getCurrentMetrics();
      
      final metricsString = metrics.toString();
      
      // Should contain key information
      expect(metricsString, contains('fps:'));
      expect(metricsString, contains('cpu:'));
      expect(metricsString, contains('gpu:'));
      expect(metricsString, contains('battery:'));
      expect(metricsString, contains('memory:'));
    });

    test('should copy metrics correctly', () async {
      final originalMetrics = await performanceService.getCurrentMetrics();
      
      final copiedMetrics = originalMetrics.copyWith(
        fps: 60.0,
        cpuUsage: 50.0,
      );
      
      // Should preserve original values
      expect(originalMetrics.fps, isNot(equals(60.0)));
      expect(originalMetrics.cpuUsage, isNot(equals(50.0)));
      
      // Should have new values
      expect(copiedMetrics.fps, equals(60.0));
      expect(copiedMetrics.cpuUsage, equals(50.0));
      
      // Should preserve other values
      expect(copiedMetrics.gpuUsage, equals(originalMetrics.gpuUsage));
      expect(copiedMetrics.batteryLevel, equals(originalMetrics.batteryLevel));
      expect(copiedMetrics.memoryUsage, equals(originalMetrics.memoryUsage));
      expect(copiedMetrics.availableMemory, equals(originalMetrics.availableMemory));
      expect(copiedMetrics.deviceModel, equals(originalMetrics.deviceModel));
      expect(copiedMetrics.deviceBrand, equals(originalMetrics.deviceBrand));
    });

    test('should handle disposal correctly', () async {
      // Create a new service for this test
      final testService = PerformanceService();
      
      // Start monitoring
      await testService.startMonitoring();
      
      // Dispose the service
      await testService.dispose();
      
      // Should not throw when trying to stop after disposal
      expect(() async => await testService.stopMonitoring(), returnsNormally);
    });
  });
}