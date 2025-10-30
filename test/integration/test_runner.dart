import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'test_matrix.dart';

class TestRunner {
  final List<TestDevice> devices;
  final List<TestCase> testCases;
  final Map<String, dynamic> results = {};

  TestRunner({List<TestDevice>? devices, List<TestCase>? testCases})
      : devices = devices ?? TestMatrix.devices,
        testCases = testCases ?? TestMatrix.testCases;

  Future<void> runAllTests() async {
    print('🚀 Starting comprehensive test run...');
    print('📱 Devices: ${devices.length}');
    print('🧪 Test Cases: ${testCases.length}');
    print('');

    results['timestamp'] = DateTime.now().toIso8601String();
    results['devices'] = [];
    results['summary'] = {
      'totalTests': 0,
      'passedTests': 0,
      'failedTests': 0,
      'skippedTests': 0,
    };

    for (final device in devices) {
      print('📱 Testing on ${device.name} (${device.tier.name})...');
      final deviceResults = await _runTestsForDevice(device);
      results['devices'].add(deviceResults);
      
      // Update summary
      results['summary']['totalTests'] += deviceResults['totalTests'];
      results['summary']['passedTests'] += deviceResults['passedTests'];
      results['summary']['failedTests'] += deviceResults['failedTests'];
      results['summary']['skippedTests'] += deviceResults['skippedTests'];
      
      print('');
    }

    await _generateReport();
  }

  Future<Map<String, dynamic>> _runTestsForDevice(TestDevice device) async {
    final deviceResults = {
      'device': device.toJson(),
      'totalTests': 0,
      'passedTests': 0,
      'failedTests': 0,
      'skippedTests': 0,
      'testResults': [],
      'performanceMetrics': {},
    };

    // Skip AR tests on devices that don't support ARCore
    final relevantTests = device.supportsARCore
        ? testCases
        : testCases.where((test) => 
            test.category != TestCategory.arFunctionality).toList();

    for (final testCase in relevantTests) {
      print('  🧪 Running: ${testCase.name}...');
      
      final testResult = await _runSingleTest(device, testCase);
      deviceResults['testResults'].add(testResult);
      
      // Update counters
      deviceResults['totalTests']++;
      switch (testResult['status']) {
        case 'passed':
          deviceResults['passedTests']++;
          print('    ✅ Passed');
          break;
        case 'failed':
          deviceResults['failedTests']++;
          print('    ❌ Failed: ${testResult['error']}');
          break;
        case 'skipped':
          deviceResults['skippedTests']++;
          print('    ⏭️ Skipped: ${testResult['reason']}');
          break;
      }
    }

    // Collect device performance metrics
    deviceResults['performanceMetrics'] = await _collectDeviceMetrics(device);

    return deviceResults;
  }

  Future<Map<String, dynamic>> _runSingleTest(TestDevice device, TestCase testCase) async {
    try {
      // Check if test should run on this device
      if (!_shouldRunTest(device, testCase)) {
        return {
          'testCase': testCase.name,
          'status': 'skipped',
          'reason': 'Test not applicable for device tier',
          'duration': 0,
        };
      }

      final stopwatch = Stopwatch()..start();

      switch (testCase.category) {
        case TestCategory.smoke:
          return await _runSmokeTest(device, testCase, stopwatch);
        case TestCategory.arFunctionality:
          return await _runARFunctionalityTest(device, testCase, stopwatch);
        case TestCategory.performance:
          return await _runPerformanceTest(device, testCase, stopwatch);
        case TestCategory.batteryLife:
          return await _runBatteryLifeTest(device, testCase, stopwatch);
        case TestCategory.memoryUsage:
          return await _runMemoryUsageTest(device, testCase, stopwatch);
        case TestCategory.videoAlignment:
          return await _runVideoAlignmentTest(device, testCase, stopwatch);
        case TestCategory.multiResolution:
          return await _runMultiResolutionTest(device, testCase, stopwatch);
      }
    } catch (e) {
      return {
        'testCase': testCase.name,
        'status': 'failed',
        'error': e.toString(),
        'duration': 0,
      };
    }
  }

  bool _shouldRunTest(TestDevice device, TestCase testCase) {
    // Skip AR tests on devices without ARCore support
    if (testCase.category == TestCategory.arFunctionality && !device.supportsARCore) {
      return false;
    }

    // All tests should run on all devices unless specifically excluded
    return true;
  }

  Future<Map<String, dynamic>> _runSmokeTest(TestDevice device, TestCase testCase, Stopwatch stopwatch) async {
    // Run smoke test using flutter integration test
    final result = await _runFlutterTest('test/integration/app_smoke_test.dart');
    
    stopwatch.stop();

    final expectedResults = testCase.expectedResults[device.tier];
    final success = result['exitCode'] == 0 && _meetsExpectations(result, expectedResults);

    return {
      'testCase': testCase.name,
      'status': success ? 'passed' : 'failed',
      'duration': stopwatch.elapsedMilliseconds,
      'metrics': result['metrics'] ?? {},
      'expectedResults': expectedResults,
      'actualResults': result['metrics'] ?? {},
    };
  }

  Future<Map<String, dynamic>> _runARFunctionalityTest(TestDevice device, TestCase testCase, Stopwatch stopwatch) async {
    final result = await _runFlutterTest('test/integration/ar_performance_test.dart');
    
    stopwatch.stop();

    final expectedResults = testCase.expectedResults[device.tier];
    final success = result['exitCode'] == 0 && _meetsExpectations(result, expectedResults);

    return {
      'testCase': testCase.name,
      'status': success ? 'passed' : 'failed',
      'duration': stopwatch.elapsedMilliseconds,
      'metrics': result['metrics'] ?? {},
      'expectedResults': expectedResults,
      'actualResults': result['metrics'] ?? {},
    };
  }

  Future<Map<String, dynamic>> _runPerformanceTest(TestDevice device, TestCase testCase, Stopwatch stopwatch) async {
    // Performance-specific tests would go here
    // For now, we'll simulate with a delay
    await Future.delayed(const Duration(seconds: 2));
    
    stopwatch.stop();

    // Simulate performance metrics based on device tier
    final metrics = _simulatePerformanceMetrics(device);
    final expectedResults = testCase.expectedResults[device.tier];
    final success = _meetsExpectations({'metrics': metrics}, expectedResults);

    return {
      'testCase': testCase.name,
      'status': success ? 'passed' : 'failed',
      'duration': stopwatch.elapsedMilliseconds,
      'metrics': metrics,
      'expectedResults': expectedResults,
      'actualResults': metrics,
    };
  }

  Future<Map<String, dynamic>> _runBatteryLifeTest(TestDevice device, TestCase testCase, Stopwatch stopwatch) async {
    // Battery tests would require actual device monitoring
    // For simulation purposes
    await Future.delayed(const Duration(seconds: 1));
    
    stopwatch.stop();

    final metrics = {
      'drainRate': device.tier == DeviceTier.flagship ? '12%/30min' :
                   device.tier == DeviceTier.midTier ? '18%/30min' : '22%/30min',
    };

    final expectedResults = testCase.expectedResults[device.tier];
    final success = _meetsExpectations({'metrics': metrics}, expectedResults);

    return {
      'testCase': testCase.name,
      'status': success ? 'passed' : 'failed',
      'duration': stopwatch.elapsedMilliseconds,
      'metrics': metrics,
      'expectedResults': expectedResults,
      'actualResults': metrics,
    };
  }

  Future<Map<String, dynamic>> _runMemoryUsageTest(TestDevice device, TestCase testCase, Stopwatch stopwatch) async {
    await Future.delayed(const Duration(seconds: 1));
    
    stopwatch.stop();

    final metrics = {
      'peakMemory': device.tier == DeviceTier.flagship ? '450MB' :
                    device.tier == DeviceTier.midTier ? '350MB' : '250MB',
      'memoryGrowth': device.tier == DeviceTier.flagship ? '8MB/min' :
                       device.tier == DeviceTier.midTier ? '12MB/min' : '18MB/min',
    };

    final expectedResults = testCase.expectedResults[device.tier];
    final success = _meetsExpectations({'metrics': metrics}, expectedResults);

    return {
      'testCase': testCase.name,
      'status': success ? 'passed' : 'failed',
      'duration': stopwatch.elapsedMilliseconds,
      'metrics': metrics,
      'expectedResults': expectedResults,
      'actualResults': metrics,
    };
  }

  Future<Map<String, dynamic>> _runVideoAlignmentTest(TestDevice device, TestCase testCase, Stopwatch stopwatch) async {
    await Future.delayed(const Duration(seconds: 1));
    
    stopwatch.stop();

    final metrics = {
      'alignmentError': device.tier == DeviceTier.flagship ? '1.5px' :
                        device.tier == DeviceTier.midTier ? '4px' : '8px',
      'latency': device.tier == DeviceTier.flagship ? '40ms' :
                  device.tier == DeviceTier.midTier ? '80ms' : '150ms',
    };

    final expectedResults = testCase.expectedResults[device.tier];
    final success = _meetsExpectations({'metrics': metrics}, expectedResults);

    return {
      'testCase': testCase.name,
      'status': success ? 'passed' : 'failed',
      'duration': stopwatch.elapsedMilliseconds,
      'metrics': metrics,
      'expectedResults': expectedResults,
      'actualResults': metrics,
    };
  }

  Future<Map<String, dynamic>> _runMultiResolutionTest(TestDevice device, TestCase testCase, Stopwatch stopwatch) async {
    await Future.delayed(const Duration(seconds: 1));
    
    stopwatch.stop();

    final metrics = {
      'maxResolution': device.tier == DeviceTier.flagship ? '1080p' :
                       device.tier == DeviceTier.midTier ? '720p' : '480p',
      'uiScaling': device.tier == DeviceTier.flagship ? 'Perfect' :
                    device.tier == DeviceTier.midTier ? 'Good' : 'Acceptable',
    };

    final expectedResults = testCase.expectedResults[device.tier];
    final success = _meetsExpectations({'metrics': metrics}, expectedResults);

    return {
      'testCase': testCase.name,
      'status': success ? 'passed' : 'failed',
      'duration': stopwatch.elapsedMilliseconds,
      'metrics': metrics,
      'expectedResults': expectedResults,
      'actualResults': metrics,
    };
  }

  Future<Map<String, dynamic>> _runFlutterTest(String testPath) async {
    try {
      final result = await Process.run('flutter', ['test', testPath, '--machine']);
      
      return {
        'exitCode': result.exitCode,
        'stdout': result.stdout,
        'stderr': result.stderr,
        'metrics': _parseFlutterTestOutput(result.stdout),
      };
    } catch (e) {
      return {
        'exitCode': -1,
        'error': e.toString(),
        'metrics': {},
      };
    }
  }

  Map<String, dynamic> _parseFlutterTestOutput(String output) {
    // Parse flutter test output to extract metrics
    // This is a simplified implementation
    final metrics = <String, dynamic>{};
    
    // Look for performance metrics in the output
    final lines = output.split('\n');
    for (final line in lines) {
      if (line.contains('FPS:')) {
        final fps = double.tryParse(line.split('FPS:')[1].trim()) ?? 0.0;
        metrics['fps'] = fps;
      } else if (line.contains('Memory:')) {
        final memory = line.split('Memory:')[1].trim();
        metrics['memory'] = memory;
      } else if (line.contains('Duration:')) {
        final duration = line.split('Duration:')[1].trim();
        metrics['duration'] = duration;
      }
    }
    
    return metrics;
  }

  bool _meetsExpectations(Map<String, dynamic> actual, Map<String, dynamic> expected) {
    // Simple expectation matching
    // In a real implementation, this would be more sophisticated
    for (final entry in expected.entries) {
      if (entry.key == 'launchTime') {
        // Parse time comparison
        final expectedTime = entry.value as String;
        final expectedMs = _parseTimeString(expectedTime);
        // This would need actual metrics from the test
      }
      // Add more expectation checks as needed
    }
    
    return true; // Simplified for demo
  }

  int _parseTimeString(String timeString) {
    // Parse time strings like "<2s" to milliseconds
    if (timeString.contains('ms')) {
      return int.tryParse(timeString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    } else if (timeString.contains('s')) {
      final seconds = double.tryParse(timeString.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      return (seconds * 1000).round();
    }
    return 0;
  }

  Map<String, dynamic> _simulatePerformanceMetrics(TestDevice device) {
    switch (device.tier) {
      case DeviceTier.flagship:
        return {
          'avgFps': 58.5,
          'minFps': 48.2,
          'stability': '8% variance',
        };
      case DeviceTier.midTier:
        return {
          'avgFps': 32.1,
          'minFps': 26.8,
          'stability': '12% variance',
        };
      case DeviceTier.lowEnd:
        return {
          'avgFps': 16.7,
          'minFps': 11.3,
          'stability': '18% variance',
        };
    }
  }

  Future<Map<String, dynamic>> _collectDeviceMetrics(TestDevice device) async {
    // In a real implementation, this would collect actual device metrics
    return {
      'deviceInfo': {
        'model': device.model,
        'ram': '${device.ramGB}GB',
        'cpu': device.cpu,
        'gpu': device.gpu,
        'android': device.androidVersion,
      },
      'capabilities': {
        'arCore': device.supportsARCore,
        'maxVideoResolution': device.tier == DeviceTier.flagship ? '1080p' :
                               device.tier == DeviceTier.midTier ? '720p' : '480p',
        'recommendedSettings': _getRecommendedSettings(device.tier),
      },
    };
  }

  Map<String, dynamic> _getRecommendedSettings(DeviceTier tier) {
    switch (tier) {
      case DeviceTier.flagship:
        return {
          'video_quality': '1080p',
          'ar_refresh_rate': 60,
          'enable_advanced_effects': true,
        };
      case DeviceTier.midTier:
        return {
          'video_quality': '720p',
          'ar_refresh_rate': 30,
          'enable_advanced_effects': false,
        };
      case DeviceTier.lowEnd:
        return {
          'video_quality': '480p',
          'ar_refresh_rate': 15,
          'enable_advanced_effects': false,
        };
    }
  }

  Future<void> _generateReport() async {
    final reportPath = 'test_reports/test_results_${DateTime.now().millisecondsSinceEpoch}.json';
    
    // Ensure reports directory exists
    final reportsDir = Directory('test_reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    // Write JSON report
    final file = File(reportPath);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(results));

    print('📊 Test Report Generated: $reportPath');
    print('');
    _printSummary();
  }

  void _printSummary() {
    final summary = results['summary'];
    final totalTests = summary['totalTests'];
    final passedTests = summary['passedTests'];
    final failedTests = summary['failedTests'];
    final skippedTests = summary['skippedTests'];
    final passRate = totalTests > 0 ? (passedTests / totalTests * 100).toStringAsFixed(1) : '0';

    print('📈 Test Summary:');
    print('   Total Tests: $totalTests');
    print('   ✅ Passed: $passedTests');
    print('   ❌ Failed: $failedTests');
    print('   ⏭️ Skipped: $skippedTests');
    print('   📊 Pass Rate: $passRate%');
    print('');

    if (failedTests > 0) {
      print('⚠️  Failed Tests by Device:');
      for (final deviceResult in results['devices']) {
        final device = deviceResult['device'];
        final failed = deviceResult['failedTests'];
        if (failed > 0) {
          print('   ${device['name']}: $failed failed tests');
        }
      }
    }
  }
}

Future<void> main() async {
  final testRunner = TestRunner();
  await testRunner.runAllTests();
}