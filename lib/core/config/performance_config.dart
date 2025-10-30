class PerformanceConfig {
  static const Duration metricsUpdateInterval = Duration(seconds: 1);
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const int maxMetricsHistory = 1000;
  static const int maxAlertsHistory = 50;
  static const int maxConcurrentObjects = 5;

  // Performance thresholds by device tier
  static const Map<String, PerformanceThresholds> thresholds = {
    'flagship': PerformanceThresholds(
      minFps: 55.0,
      targetFps: 60.0,
      maxMemoryUsage: 500 * 1024 * 1024, // 500MB
      maxCpuUsage: 75.0,
      maxGpuUsage: 75.0,
      maxBatteryDrain: 15.0, // % per 30 minutes
      maxInitTime: 3, // seconds
    ),
    'midTier': PerformanceThresholds(
      minFps: 30.0,
      targetFps: 30.0,
      maxMemoryUsage: 400 * 1024 * 1024, // 400MB
      maxCpuUsage: 85.0,
      maxGpuUsage: 85.0,
      maxBatteryDrain: 20.0, // % per 30 minutes
      maxInitTime: 5, // seconds
    ),
    'lowEnd': PerformanceThresholds(
      minFps: 15.0,
      targetFps: 15.0,
      maxMemoryUsage: 300 * 1024 * 1024, // 300MB
      maxCpuUsage: 95.0,
      maxGpuUsage: 95.0,
      maxBatteryDrain: 25.0, // % per 30 minutes
      maxInitTime: 8, // seconds
    ),
  };

  // Quality settings by device tier
  static const Map<String, QualitySettings> qualitySettings = {
    'flagship': QualitySettings(
      videoQuality: '1080p',
      videoFrameRate: 30,
      arRefreshRate: 60,
      enableAdvancedEffects: true,
      textureQuality: 'high',
      shadowQuality: 'high',
      antiAliasing: true,
      maxConcurrentAnimations: 5,
      cacheSizeMB: 500,
    ),
    'midTier': QualitySettings(
      videoQuality: '720p',
      videoFrameRate: 30,
      arRefreshRate: 30,
      enableAdvancedEffects: false,
      textureQuality: 'medium',
      shadowQuality: 'medium',
      antiAliasing: true,
      maxConcurrentAnimations: 3,
      cacheSizeMB: 200,
    ),
    'lowEnd': QualitySettings(
      videoQuality: '480p',
      videoFrameRate: 30,
      arRefreshRate: 15,
      enableAdvancedEffects: false,
      textureQuality: 'low',
      shadowQuality: 'low',
      antiAliasing: false,
      maxConcurrentAnimations: 1,
      cacheSizeMB: 100,
    ),
  };

  // Alert thresholds
  static const AlertThresholds alertThresholds = AlertThresholds(
    criticalFps: 15.0,
    warningFps: 30.0,
    criticalMemory: 90.0, // percentage
    warningMemory: 75.0, // percentage
    criticalCpu: 90.0, // percentage
    warningCpu: 75.0, // percentage
    criticalGpu: 90.0, // percentage
    warningGpu: 75.0, // percentage
    criticalBatteryDrain: 2.0, // % per minute
    warningBatteryDrain: 1.0, // % per minute
    highTemperatureThreshold: 45.0, // Celsius
  );

  // Monitoring settings
  static const MonitoringSettings monitoring = MonitoringSettings(
    enableFpsMonitoring: true,
    enableMemoryMonitoring: true,
    enableCpuMonitoring: true,
    enableGpuMonitoring: true,
    enableBatteryMonitoring: true,
    enableTemperatureMonitoring: true,
    enableNetworkMonitoring: false,
    enableLocationMonitoring: false,
    metricsRetentionDays: 7,
    enableRealTimeAlerts: true,
    enablePerformanceOverlay: true,
  );

  // Debug settings
  static const DebugSettings debug = DebugSettings(
    enablePerformanceLogs: true,
    enableDetailedMetrics: false,
    enableStackTraceCollection: false,
    enableMemoryProfiling: false,
    enableFrameTimeAnalysis: false,
    logLevel: 'info', // debug, info, warning, error
    maxLogFileSize: 10 * 1024 * 1024, // 10MB
    enableRemoteLogging: false,
  );
}

class PerformanceThresholds {
  final double minFps;
  final double targetFps;
  final int maxMemoryUsage;
  final double maxCpuUsage;
  final double maxGpuUsage;
  final double maxBatteryDrain;
  final int maxInitTime;

  const PerformanceThresholds({
    required this.minFps,
    required this.targetFps,
    required this.maxMemoryUsage,
    required this.maxCpuUsage,
    required this.maxGpuUsage,
    required this.maxBatteryDrain,
    required this.maxInitTime,
  });
}

class QualitySettings {
  final String videoQuality;
  final int videoFrameRate;
  final int arRefreshRate;
  final bool enableAdvancedEffects;
  final String textureQuality;
  final String shadowQuality;
  final bool antiAliasing;
  final int maxConcurrentAnimations;
  final int cacheSizeMB;

  const QualitySettings({
    required this.videoQuality,
    required this.videoFrameRate,
    required this.arRefreshRate,
    required this.enableAdvancedEffects,
    required this.textureQuality,
    required this.shadowQuality,
    required this.antiAliasing,
    required this.maxConcurrentAnimations,
    required this.cacheSizeMB,
  });
}

class AlertThresholds {
  final double criticalFps;
  final double warningFps;
  final double criticalMemory;
  final double warningMemory;
  final double criticalCpu;
  final double warningCpu;
  final double criticalGpu;
  final double warningGpu;
  final double criticalBatteryDrain;
  final double warningBatteryDrain;
  final double highTemperatureThreshold;

  const AlertThresholds({
    required this.criticalFps,
    required this.warningFps,
    required this.criticalMemory,
    required this.warningMemory,
    required this.criticalCpu,
    required this.warningCpu,
    required this.criticalGpu,
    required this.warningGpu,
    required this.criticalBatteryDrain,
    required this.warningBatteryDrain,
    required this.highTemperatureThreshold,
  });
}

class MonitoringSettings {
  final bool enableFpsMonitoring;
  final bool enableMemoryMonitoring;
  final bool enableCpuMonitoring;
  final bool enableGpuMonitoring;
  final bool enableBatteryMonitoring;
  final bool enableTemperatureMonitoring;
  final bool enableNetworkMonitoring;
  final bool enableLocationMonitoring;
  final int metricsRetentionDays;
  final bool enableRealTimeAlerts;
  final bool enablePerformanceOverlay;

  const MonitoringSettings({
    required this.enableFpsMonitoring,
    required this.enableMemoryMonitoring,
    required this.enableCpuMonitoring,
    required this.enableGpuMonitoring,
    required this.enableBatteryMonitoring,
    required this.enableTemperatureMonitoring,
    required this.enableNetworkMonitoring,
    required this.enableLocationMonitoring,
    required this.metricsRetentionDays,
    required this.enableRealTimeAlerts,
    required this.enablePerformanceOverlay,
  });
}

class DebugSettings {
  final bool enablePerformanceLogs;
  final bool enableDetailedMetrics;
  final bool enableStackTraceCollection;
  final bool enableMemoryProfiling;
  final bool enableFrameTimeAnalysis;
  final String logLevel;
  final int maxLogFileSize;
  final bool enableRemoteLogging;

  const DebugSettings({
    required this.enablePerformanceLogs,
    required this.enableDetailedMetrics,
    required this.enableStackTraceCollection,
    required this.enableMemoryProfiling,
    required this.enableFrameTimeAnalysis,
    required this.logLevel,
    required this.maxLogFileSize,
    required this.enableRemoteLogging,
  });
}