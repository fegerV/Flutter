# Testing Guide

This guide explains how to run tests for the caching and QR scanner features.

## Test Structure

The test suite is organized into three main categories:

### 1. Unit Tests (`test/unit/`)
- **qr_service_test.dart**: Tests QR code parsing logic and history management
- **cache_service_test.dart**: Tests cache operations and size management
- **usecases_test.dart**: Tests business logic for use cases
- **app_config_test.dart**: Tests app configuration
- **di_test.dart**: Tests dependency injection
- **l10n_test.dart**: Tests localization

### 2. Widget Tests (`test/widget/`)
- **cache_status_widget_test.dart**: Tests cache status UI component
- **widget_test.dart**: Basic widget testing

### 3. Integration Tests
- End-to-end testing for complete workflows

## Running Tests

### Prerequisites
Make sure you have Flutter installed and your environment is set up.

### Run All Tests
```bash
flutter test
```

### Run Specific Test Files
```bash
# Run QR service tests
flutter test test/unit/qr_service_test.dart

# Run cache service tests
flutter test test/unit/cache_service_test.dart

# Run widget tests
flutter test test/widget/cache_status_widget_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Coverage Areas

### QR Service Tests
- ✅ JSON QR code parsing
- ✅ Simple ID parsing
- ✅ URL format parsing
- ✅ Invalid QR code handling
- ✅ Scan history management
- ✅ History size limits

### Cache Service Tests
- ✅ Cache initialization
- ✅ File download simulation
- ✅ Cache validation
- ✅ Size management
- ✅ TTL enforcement
- ✅ Cleanup operations

### Use Case Tests
- ✅ QR scanning workflow
- ✅ Cache info retrieval
- ✅ Cache clearing operations
- ✅ Error handling

### Widget Tests
- ✅ Cache status display
- ✅ Loading states
- ✅ Error states
- ✅ Progress indicators
- ✅ Warning displays

## Mock Strategy

The tests use mockito for mocking dependencies:

### Key Mocks
- `MockSharedPreferences`: For shared preferences
- `MockCacheManager`: For cache operations
- `MockQRRepository`: For QR repository operations
- `MockCacheRepository`: For cache repository operations

### Example Mock Usage
```dart
// Mock QR repository
final mockRepository = MockQRRepository();
when(mockRepository.scanQRCode('test_value'))
    .thenAnswer((_) async => expectedQRCode);

// Test the use case
final result = await useCase(ScanQRCodeParams('test_value'));
expect(result, expectedQRCode);
```

## Test Data

### Sample QR Codes
```dart
// JSON format
const jsonQR = '{"animation_id": "test_anim_123", "type": "animation"}';

// Simple ID format
const simpleQR = 'anim_123';

// URL format
const urlQR = 'https://example.com/animation/anim_123';
```

### Sample Cache Info
```dart
final cacheInfo = CacheInfo(
  totalSize: 100000000, // 100MB
  usedSize: 50000000, // 50MB
  itemCount: 10,
  lastCleanup: DateTime.now(),
  maxSizeLimit: 500000000, // 500MB
  ttl: Duration(days: 7),
);
```

## Integration Testing Scenarios

### 1. QR Scanner Workflow
1. Navigate to QR scanner page
2. Simulate QR scan with valid animation ID
3. Verify animation download is triggered
4. Verify navigation to AR page

### 2. Cache Management Workflow
1. Navigate to cache management page
2. Verify cache status display
3. Test cache optimization
4. Test individual item deletion

### 3. Offline Behavior
1. Download animations while online
2. Verify cache persistence
3. Test offline playback

## Performance Testing

### Cache Performance
- Test cache operations with large file counts
- Measure cleanup operation times
- Verify memory usage limits

### QR Scanner Performance
- Test QR parsing speed
- Verify camera performance
- Test memory usage during scanning

## Troubleshooting

### Common Test Issues

1. **Permission Tests Failing**
   - Ensure test environment has proper permissions
   - Mock permission handlers appropriately

2. **File System Tests Failing**
   - Check temp directory permissions
   - Ensure cleanup in test teardown

3. **Widget Tests Failing**
   - Verify ScreenUtil initialization
   - Check theme and localization setup

### Debugging Tests
```bash
# Run tests with verbose output
flutter test --verbose

# Run specific test with debugging
flutter test test/unit/qr_service_test.dart --plain-name "parseQRCode"
```

## Continuous Integration

### GitHub Actions
Tests are configured to run on:
- Pull requests
- Push to main branch
- Release branches

### Test Requirements
- All tests must pass
- Minimum 80% code coverage
- No static analysis warnings

## Best Practices

### Writing Tests
1. **Arrange-Act-Assert Pattern**
   ```dart
   // Arrange
   final mockRepo = MockRepository();
   final useCase = MyUseCase(mockRepo);
   
   // Act
   final result = await useCase(params);
   
   // Assert
   expect(result, expectedValue);
   ```

2. **Descriptive Test Names**
   ```dart
   test('should parse JSON QR code with animation ID', () async {
     // Test implementation
   });
   ```

3. **Test Edge Cases**
   - Empty inputs
   - Null values
   - Network errors
   - File system errors

4. **Mock Verification**
   ```dart
   verify(mockRepository.scanQRCode('test_value')).called(1);
   ```

### Test Organization
- Group related tests with `group()`
- Use `setUp()` and `tearDown()` for common setup
- Keep test files focused and small
- Use descriptive comments for complex scenarios

## Future Test Enhancements

### Planned Additions
1. **Integration Tests**: Full user journey testing
2. **Performance Tests**: Memory and CPU usage
3. **Accessibility Tests**: Screen reader and contrast
4. **Localization Tests**: Multiple language support

### Test Tools to Consider
1. **Golden Tests**: Visual regression testing
2. **Mockito Generators**: Automated mock creation
3. **Test Fixtures**: Reusable test data
4. **Property Testing**: Fuzz testing for edge cases

This testing guide provides comprehensive coverage for the caching and QR scanner functionality, ensuring reliability and maintainability of the codebase.