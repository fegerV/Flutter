enum DeviceTier {
  flagship,
  midTier,
  lowEnd,
}

enum TestCategory {
  smoke,
  arFunctionality,
  performance,
  batteryLife,
  memoryUsage,
  videoAlignment,
  multiResolution,
}

class TestDevice {
  final String name;
  final DeviceTier tier;
  final String model;
  final int ramGB;
  final String cpu;
  final String gpu;
  final String androidVersion;
  final int sdkVersion;
  final double screenSize;
  final String resolution;
  final bool supportsARCore;

  const TestDevice({
    required this.name,
    required this.tier,
    required this.model,
    required this.ramGB,
    required this.cpu,
    required this.gpu,
    required this.androidVersion,
    required this.sdkVersion,
    required this.screenSize,
    required this.resolution,
    required this.supportsARCore,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tier': tier.name,
      'model': model,
      'ramGB': ramGB,
      'cpu': cpu,
      'gpu': gpu,
      'androidVersion': androidVersion,
      'sdkVersion': sdkVersion,
      'screenSize': screenSize,
      'resolution': resolution,
      'supportsARCore': supportsARCore,
    };
  }
}

class TestCase {
  final String name;
  final TestCategory category;
  final String description;
  final List<String> steps;
  final Map<DeviceTier, Map<String, dynamic>> expectedResults;
  final Duration timeout;
  final bool isCritical;

  const TestCase({
    required this.name,
    required this.category,
    required this.description,
    required this.steps,
    required this.expectedResults,
    this.timeout = const Duration(minutes: 5),
    this.isCritical = false,
  });
}

class TestMatrix {
  static const List<TestDevice> devices = [
    // Flagship Devices
    TestDevice(
      name: 'Samsung Galaxy S23 Ultra',
      tier: DeviceTier.flagship,
      model: 'SM-S918B',
      ramGB: 12,
      cpu: 'Snapdragon 8 Gen 2',
      gpu: 'Adreno 740',
      androidVersion: '13',
      sdkVersion: 33,
      screenSize: 6.8,
      resolution: '1440x3088',
      supportsARCore: true,
    ),
    TestDevice(
      name: 'Google Pixel 7 Pro',
      tier: DeviceTier.flagship,
      model: 'GQML3',
      ramGB: 12,
      cpu: 'Google Tensor G2',
      gpu: 'Mali-G710 MP7',
      androidVersion: '13',
      sdkVersion: 33,
      screenSize: 6.7,
      resolution: '1440x3120',
      supportsARCore: true,
    ),
    TestDevice(
      name: 'OnePlus 11',
      tier: DeviceTier.flagship,
      model: 'PHB110',
      ramGB: 16,
      cpu: 'Snapdragon 8 Gen 2',
      gpu: 'Adreno 740',
      androidVersion: '13',
      sdkVersion: 33,
      screenSize: 6.7,
      resolution: '1440x3216',
      supportsARCore: true,
    ),

    // Mid-tier Devices
    TestDevice(
      name: 'Samsung Galaxy A54',
      tier: DeviceTier.midTier,
      model: 'SM-A546B',
      ramGB: 8,
      cpu: 'Exynos 1380',
      gpu: 'Mali-G68 MP4',
      androidVersion: '13',
      sdkVersion: 33,
      screenSize: 6.4,
      resolution: '1080x2340',
      supportsARCore: true,
    ),
    TestDevice(
      name: 'Google Pixel 7a',
      tier: DeviceTier.midTier,
      model: 'GAHL',
      ramGB: 8,
      cpu: 'Google Tensor G2',
      gpu: 'Mali-G710 MP7',
      androidVersion: '13',
      sdkVersion: 33,
      screenSize: 6.1,
      resolution: '1080x2400',
      supportsARCore: true,
    ),
    TestDevice(
      name: 'OnePlus Nord 3',
      tier: DeviceTier.midTier,
      model: 'CPH2491',
      ramGB: 8,
      cpu: 'Dimensity 9000',
      gpu: 'Mali-G710 MC10',
      androidVersion: '13',
      sdkVersion: 33,
      screenSize: 6.74,
      resolution: '1240x2772',
      supportsARCore: true,
    ),

    // Low-end Devices
    TestDevice(
      name: 'Samsung Galaxy A14',
      tier: DeviceTier.lowEnd,
      model: 'SM-A145F',
      ramGB: 4,
      cpu: 'Exynos 850',
      gpu: 'Mali-G52',
      androidVersion: '13',
      sdkVersion: 33,
      screenSize: 6.6,
      resolution: '720x1600',
      supportsARCore: false,
    ),
    TestDevice(
      name: 'Redmi Note 11',
      tier: DeviceTier.lowEnd,
      model: '2201117TG',
      ramGB: 4,
      cpu: 'Snapdragon 680',
      gpu: 'Adreno 610',
      androidVersion: '11',
      sdkVersion: 30,
      screenSize: 6.43,
      resolution: '1080x2400',
      supportsARCore: true,
    ),
    TestDevice(
      name: 'Moto G Play',
      tier: DeviceTier.lowEnd,
      model: 'XT2093DL',
      ramGB: 3,
      cpu: 'Snapdragon 460',
      gpu: 'Adreno 610',
      androidVersion: '10',
      sdkVersion: 29,
      screenSize: 6.5,
      resolution: '720x1600',
      supportsARCore: false,
    ),
  ];

  static const List<TestCase> testCases = [
    // Smoke Tests
    TestCase(
      name: 'App Launch',
      category: TestCategory.smoke,
      description: 'Verify app launches successfully without crashes',
      steps: [
        'Install the app',
        'Launch the app from home screen',
        'Wait for splash screen to complete',
        'Verify home screen loads',
      ],
      expectedResults: {
        DeviceTier.flagship: {'launchTime': '<2s', 'memoryUsage': '<200MB'},
        DeviceTier.midTier: {'launchTime': '<3s', 'memoryUsage': '<250MB'},
        DeviceTier.lowEnd: {'launchTime': '<5s', 'memoryUsage': '<300MB'},
      },
      isCritical: true,
    ),
    TestCase(
      name: 'Basic Navigation',
      category: TestCategory.smoke,
      description: 'Verify basic navigation between screens works',
      steps: [
        'Navigate to AR screen',
        'Navigate to Media screen',
        'Navigate to Settings screen',
        'Navigate back to Home',
      ],
      expectedResults: {
        DeviceTier.flagship: {'transitionTime': '<300ms'},
        DeviceTier.midTier: {'transitionTime': '<500ms'},
        DeviceTier.lowEnd: {'transitionTime': '<800ms'},
      },
      isCritical: true,
    ),

    // AR Functionality Tests
    TestCase(
      name: 'AR Core Initialization',
      category: TestCategory.arFunctionality,
      description: 'Verify ARCore initializes correctly on supported devices',
      steps: [
        'Navigate to AR screen',
        'Grant camera permissions',
        'Wait for ARCore initialization',
        'Verify AR camera view appears',
      ],
      expectedResults: {
        DeviceTier.flagship: {'initTime': '<3s', 'successRate': '100%'},
        DeviceTier.midTier: {'initTime': '<5s', 'successRate': '95%'},
        DeviceTier.lowEnd: {'initTime': '<8s', 'successRate': '80%'},
      },
      isCritical: true,
    ),
    TestCase(
      name: 'AR Object Placement',
      category: TestCategory.arFunctionality,
      description: 'Verify AR objects can be placed and tracked',
      steps: [
        'Initialize AR session',
        'Tap screen to place object',
        'Move device around',
        'Verify object stays in place',
      ],
      expectedResults: {
        DeviceTier.flagship: {'trackingAccuracy': '<1cm', 'fps': '>55'},
        DeviceTier.midTier: {'trackingAccuracy': '<2cm', 'fps': '>30'},
        DeviceTier.lowEnd: {'trackingAccuracy': '<3cm', 'fps': '>15'},
      },
    ),

    // Performance Tests
    TestCase(
      name: 'Frame Rate Stability',
      category: TestCategory.performance,
      description: 'Verify consistent frame rates during AR usage',
      steps: [
        'Start AR session',
        'Place multiple objects',
        'Move around for 2 minutes',
        'Monitor FPS stability',
      ],
      expectedResults: {
        DeviceTier.flagship: {'avgFps': '>55', 'minFps': '>45', 'stability': '<10% variance'},
        DeviceTier.midTier: {'avgFps': '>30', 'minFps': '>25', 'stability': '<15% variance'},
        DeviceTier.lowEnd: {'avgFps': '>15', 'minFps': '>10', 'stability': '<20% variance'},
      },
    ),
    TestCase(
      name: 'Memory Usage',
      category: TestCategory.performance,
      description: 'Monitor memory usage during extended AR sessions',
      steps: [
        'Start memory monitoring',
        'Use AR features for 10 minutes',
        'Place and remove objects',
        'Check for memory leaks',
      ],
      expectedResults: {
        DeviceTier.flagship: {'peakMemory': '<500MB', 'memoryGrowth': '<10MB/min'},
        DeviceTier.midTier: {'peakMemory': '<400MB', 'memoryGrowth': '<15MB/min'},
        DeviceTier.lowEnd: {'peakMemory': '<300MB', 'memoryGrowth': '<20MB/min'},
      },
    ),

    // Battery Life Tests
    TestCase(
      name: 'Battery Drain',
      category: TestCategory.batteryLife,
      description: 'Measure battery consumption during AR usage',
      steps: [
        'Start with 100% battery',
        'Use AR features continuously for 30 minutes',
        'Measure battery percentage drop',
      ],
      expectedResults: {
        DeviceTier.flagship: {'drainRate': '<15%/30min'},
        DeviceTier.midTier: {'drainRate': '<20%/30min'},
        DeviceTier.lowEnd: {'drainRate': '<25%/30min'},
      },
    ),

    // Video Alignment Tests
    TestCase(
      name: 'Camera-Video Alignment',
      category: TestCategory.videoAlignment,
      description: 'Verify camera feed aligns correctly with recorded video',
      steps: [
        'Start video recording in AR mode',
        'Move device in various patterns',
        'Stop recording and playback',
        'Verify alignment consistency',
      ],
      expectedResults: {
        DeviceTier.flagship: {'alignmentError': '<2px', 'latency': '<50ms'},
        DeviceTier.midTier: {'alignmentError': '<5px', 'latency': '<100ms'},
        DeviceTier.lowEnd: {'alignmentError': '<10px', 'latency': '<200ms'},
      },
    ),

    // Multi-resolution Tests
    TestCase(
      name: 'Resolution Adaptation',
      category: TestCategory.multiResolution,
      description: 'Verify app adapts to different screen resolutions',
      steps: [
        'Test on different device resolutions',
        'Check UI scaling and layout',
        'Verify AR tracking accuracy',
        'Test video recording quality',
      ],
      expectedResults: {
        DeviceTier.flagship: {'maxResolution': '1080p', 'uiScaling': 'Perfect'},
        DeviceTier.midTier: {'maxResolution': '720p', 'uiScaling': 'Good'},
        DeviceTier.lowEnd: {'maxResolution': '480p', 'uiScaling': 'Acceptable'},
      },
    ),
  ];

  static List<TestDevice> getDevicesByTier(DeviceTier tier) {
    return devices.where((device) => device.tier == tier).toList();
  }

  static List<TestCase> getTestsByCategory(TestCategory category) {
    return testCases.where((test) => test.category == category).toList();
  }

  static List<TestCase> getCriticalTests() {
    return testCases.where((test) => test.isCritical).toList();
  }

  static Map<String, dynamic> generateTestReport() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'devices': devices.map((d) => d.toJson()).toList(),
      'testCases': testCases.map((test) => {
        'name': test.name,
        'category': test.category.name,
        'description': test.description,
        'steps': test.steps,
        'expectedResults': test.expectedResults.map((tier, results) => 
          MapEntry(tier.name, results)),
        'timeout': test.timeout.inSeconds,
        'isCritical': test.isCritical,
      }).toList(),
      'summary': {
        'totalDevices': devices.length,
        'totalTests': testCases.length,
        'criticalTests': getCriticalTests().length,
        'flagshipDevices': getDevicesByTier(DeviceTier.flagship).length,
        'midTierDevices': getDevicesByTier(DeviceTier.midTier).length,
        'lowEndDevices': getDevicesByTier(DeviceTier.lowEnd).length,
      },
    };
  }
}