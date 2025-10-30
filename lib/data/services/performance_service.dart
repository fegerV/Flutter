import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ar_app/domain/entities/performance_metrics.dart';

class PerformanceService {
  final Battery _battery;
  final DeviceInfoPlugin _deviceInfo;
  
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  final StreamController<PerformanceMetrics> _metricsController = 
      StreamController<PerformanceMetrics>.broadcast();
  final StreamController<String> _alertsController = 
      StreamController<String>.broadcast();
  
  final List<PerformanceMetrics> _metricsHistory = [];
  DateTime? _sessionStartTime;
  double? _lastBatteryLevel;
  int _frameCount = 0;
  DateTime? _lastFpsUpdate;

  PerformanceService()
      : _battery = Battery(),
        _deviceInfo = DeviceInfoPlugin();

  Future<void> initialize() async {
    // Initialize performance monitoring
    // This method is called during dependency injection setup
  }

  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;
  Stream<String> get alertsStream => _alertsController.stream;

  Future<PerformanceMetrics> getCurrentMetrics() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      final androidInfo = await _deviceInfo.androidInfo;
      
      final memoryInfo = await _getMemoryInfo();
      final fps = await _getCurrentFPS();
      
      final metrics = PerformanceMetrics(
        fps: fps,
        cpuUsage: await _getCPUUsage(),
        gpuUsage: await _getGPUUsage(),
        batteryLevel: batteryLevel.toDouble(),
        isCharging: batteryState == BatteryState.charging ||
                   batteryState == BatteryState.full,
        memoryUsage: memoryInfo['used'] ?? 0,
        availableMemory: memoryInfo['available'] ?? 0,
        timestamp: DateTime.now(),
        deviceModel: androidInfo.model,
        deviceBrand: androidInfo.brand,
      );

      _checkForAlerts(metrics);
      return metrics;
    } catch (e) {
      throw Exception('Failed to get performance metrics: $e');
    }
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _sessionStartTime = DateTime.now();
    _lastBatteryLevel = null;
    _frameCount = 0;
    _lastFpsUpdate = DateTime.now();
    
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_isMonitoring) {
        try {
          final metrics = await getCurrentMetrics();
          _metricsHistory.add(metrics);
          
          // Keep only last 1000 metrics to prevent memory issues
          if (_metricsHistory.length > 1000) {
            _metricsHistory.removeAt(0);
          }
          
          _metricsController.add(metrics);
        } catch (e) {
          _alertsController.add('Error collecting metrics: $e');
        }
      }
    });

    // Start FPS monitoring
    _startFPSMonitoring();
  }

  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _sessionStartTime = null;
  }

  Future<List<PerformanceMetrics>> getMetricsHistory({
    Duration? duration,
    int? limit,
  }) async {
    var history = List<PerformanceMetrics>.from(_metricsHistory);
    
    if (duration != null) {
      final cutoff = DateTime.now().subtract(duration);
      history = history.where((m) => m.timestamp.isAfter(cutoff)).toList();
    }
    
    if (limit != null && history.length > limit) {
      history = history.sublist(history.length - limit);
    }
    
    return history;
  }

  Future<void> logPerformanceEvent(
    String eventName,
    PerformanceMetrics metrics,
  ) async {
    // Log to analytics or local storage
    debugPrint('Performance Event: $eventName - $metrics');
  }

  void _startFPSMonitoring() {
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (_isMonitoring) {
      _frameCount++;
      final now = DateTime.now();
      
      if (_lastFpsUpdate != null) {
        final timeDiff = now.difference(_lastFpsUpdate!).inMilliseconds;
        if (timeDiff >= 1000) { // Update FPS every second
          final fps = (_frameCount * 1000) / timeDiff;
          _currentFPS = fps;
          _frameCount = 0;
          _lastFpsUpdate = now;
        }
      }
      
      WidgetsBinding.instance.addPostFrameCallback(_onFrame);
    }
  }

  double _currentFPS = 0.0;

  Future<double> _getCurrentFPS() async {
    return _currentFPS;
  }

  Future<double> _getCPUUsage() async {
    try {
      // Simplified CPU usage calculation
      final result = await Process.run('cat', ['/proc/loadavg']);
      if (result.exitCode == 0) {
        final loadAvg = double.tryParse(result.stdout.toString().split(' ')[0]) ?? 0.0;
        return (loadAvg / Platform.numberOfProcessors) * 100;
      }
    } catch (e) {
      debugPrint('Failed to get CPU usage: $e');
    }
    return 0.0;
  }

  Future<double> _getGPUUsage() async {
    try {
      // GPU usage detection is complex and device-specific
      // This is a placeholder implementation
      final result = await Process.run('dumpsys', ['gfxinfo']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        // Parse GPU usage from gfxinfo (simplified)
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.contains('Janky frames')) {
            // Extract janky frame percentage and convert to GPU usage estimate
            final match = RegExp(r'(\d+\.?\d*)%').firstMatch(line);
            if (match != null) {
              final jankyPercent = double.tryParse(match.group(1)!) ?? 0.0;
              return (100.0 - jankyPercent) * 0.8; // Rough estimate
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to get GPU usage: $e');
    }
    return 0.0;
  }

  Future<Map<String, int>> _getMemoryInfo() async {
    try {
      final result = await Process.run('cat', ['/proc/meminfo']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        int? totalMem, freeMem, availableMem;
        
        for (final line in lines) {
          if (line.startsWith('MemTotal:')) {
            totalMem = int.tryParse(line.split(RegExp(r'\s+'))[1]) ?? 0;
          } else if (line.startsWith('MemFree:')) {
            freeMem = int.tryParse(line.split(RegExp(r'\s+'))[1]) ?? 0;
          } else if (line.startsWith('MemAvailable:')) {
            availableMem = int.tryParse(line.split(RegExp(r'\s+'))[1]) ?? 0;
          }
        }
        
        final used = (totalMem ?? 0) - (availableMem ?? freeMem ?? 0);
        return {
          'total': totalMem ?? 0,
          'used': used,
          'available': availableMem ?? freeMem ?? 0,
        };
      }
    } catch (e) {
      debugPrint('Failed to get memory info: $e');
    }
    return {'total': 0, 'used': 0, 'available': 0};
  }

  void _checkForAlerts(PerformanceMetrics metrics) {
    // FPS alerts
    if (metrics.fps < 15) {
      _alertsController.add('Critical: Very low FPS (${metrics.fps.toStringAsFixed(1)})');
    } else if (metrics.fps < 30) {
      _alertsController.add('Warning: Low FPS (${metrics.fps.toStringAsFixed(1)})');
    }

    // Memory alerts
    if (metrics.memoryUsagePercentage > 90) {
      _alertsController.add('Critical: Very high memory usage (${metrics.memoryUsagePercentage.toStringAsFixed(1)}%)');
    } else if (metrics.memoryUsagePercentage > 75) {
      _alertsController.add('Warning: High memory usage (${metrics.memoryUsagePercentage.toStringAsFixed(1)}%)');
    }

    // Battery alerts
    if (_lastBatteryLevel != null && !metrics.isCharging) {
      final batteryDrain = _lastBatteryLevel! - metrics.batteryLevel;
      if (batteryDrain > 2.0) {
        _alertsController.add('Warning: High battery drain (${batteryDrain.toStringAsFixed(1)}% in last minute)');
      }
    }
    _lastBatteryLevel = metrics.batteryLevel;

    // CPU alerts
    if (metrics.cpuUsage > 90) {
      _alertsController.add('Critical: Very high CPU usage (${metrics.cpuUsage.toStringAsFixed(1)}%)');
    } else if (metrics.cpuUsage > 75) {
      _alertsController.add('Warning: High CPU usage (${metrics.cpuUsage.toStringAsFixed(1)}%)');
    }

    // GPU alerts
    if (metrics.gpuUsage > 90) {
      _alertsController.add('Critical: Very high GPU usage (${metrics.gpuUsage.toStringAsFixed(1)}%)');
    } else if (metrics.gpuUsage > 75) {
      _alertsController.add('Warning: High GPU usage (${metrics.gpuUsage.toStringAsFixed(1)}%)');
    }
  }

  void dispose() {
    stopMonitoring();
    _metricsController.close();
    _alertsController.close();
  }
}