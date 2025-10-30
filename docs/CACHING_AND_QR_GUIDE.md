# Caching and QR Scanner Guide

This guide explains how to use the caching and QR scanner features in the Flutter AR app.

## Overview

The app includes:
- **Local caching** for downloaded animations with size and TTL policies
- **QR scanner** workflow to resolve animation identifiers
- **Cache management** UI with status indicators
- **Offline fallback** behavior

## Features

### 1. Animation Caching

#### Cache Configuration
- **Maximum cache size**: 500MB
- **TTL (Time To Live)**: 7 days
- **Maximum items**: 100 animations
- **Automatic cleanup**: Expired items are removed automatically

#### Cache Policies
- **Size-based cleanup**: When cache exceeds 500MB, oldest items are removed
- **TTL-based cleanup**: Items older than 7 days are automatically removed
- **Manual cleanup**: Users can clear cache manually

#### Cache Locations
- **Android**: `{app_dir}/app_flutter/animations/`
- **iOS**: `{app_dir}/Documents/animations/`

### 2. QR Scanner

#### Supported QR Code Formats

1. **JSON Format** (Recommended):
   ```json
   {
     "animation_id": "anim_123",
     "type": "animation",
     "title": "My Animation",
     "metadata": {}
   }
   ```

2. **Simple ID Format**:
   ```
   anim_123
   ```

3. **URL Format**:
   ```
   https://example.com/animation/anim_123
   ```
   ```
   https://example.com/anim/anim_123
   ```

#### QR Scanner Features
- **Real-time scanning** with camera overlay
- **Flashlight toggle** support
- **Scan history** with timestamps
- **Automatic animation detection**
- **Error handling** for invalid QR codes

### 3. Cache Management UI

#### Cache Status Indicators
- **Storage usage** visual progress bar
- **Item count** display
- **TTL information**
- **Warning indicators** when cache is near limit

#### Cache Actions
- **Clear all cache**: Remove all cached animations
- **Optimize cache**: Clean up expired and old items
- **Individual item management**: Delete specific animations

## Usage Scenarios

### Scenario 1: Downloading and Playing Animations

1. **From Media Page**:
   - Navigate to Media tab
   - Browse available animations
   - Tap on any animation to download
   - Downloaded animations show in blue
   - Tap downloaded animations to play

2. **From QR Scanner**:
   - Scan a QR code containing animation ID
   - If valid, animation is automatically downloaded
   - User is redirected to AR page with the animation

### Scenario 2: Managing Cache

1. **View Cache Status**:
   - Navigate to Media → Cache
   - View current cache usage and item count
   - Check for warnings about cache limits

2. **Optimize Cache**:
   - Tap "Optimize Cache" button
   - System removes expired items
   - Enforces size limits if needed

3. **Clear Specific Animation**:
   - In cache management, find the animation
   - Tap delete icon to remove specific item
   - Confirmation dialog shows before deletion

### Scenario 3: QR Code Scanning

1. **Basic Scanning**:
   - Navigate to Media → QR Scanner
   - Point camera at QR code
   - Wait for automatic detection
   - Valid animation QR codes trigger download

2. **View Scan History**:
   - Tap history button in scanner
   - View all previous scans with timestamps
   - Tap valid animations to play again
   - Clear history if needed

### Scenario 4: Offline Usage

1. **Downloaded Animations**:
   - Download animations when online
   - Access downloaded content offline
   - Cache persists across app restarts

2. **Cache Persistence**:
   - Cache survives app updates
   - Items respect TTL even offline
   - Manual cache clearing works offline

## Technical Implementation

### Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │    │     Domain      │    │      Data       │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Pages     │ │    │ │  Entities   │ │    │ │ Repositories│ │
│ │ Providers   │ │    │ │ Use Cases   │ │    │ │ Services    │ │
│ │ Widgets     │ │    │ │ Repositories│ │    │ │ DataSources │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Components

#### Domain Layer
- `Animation` entity: Represents animation with caching info
- `QRCode` entity: Represents scanned QR codes
- `CacheInfo` entity: Cache statistics and status
- Use cases: Business logic for operations

#### Data Layer
- `CacheService`: Manages local file caching
- `QRService`: Handles QR parsing and history
- Repositories: Implement domain interfaces
- Data Sources: Remote API communication

#### Presentation Layer
- Providers: Riverpod state management
- Pages: UI screens for each feature
- Widgets: Reusable UI components

### Caching Strategy

1. **Download Process**:
   ```dart
   final file = await cacheService.downloadAnimation(url, animationId);
   animation = animation.copyWith(
     isDownloaded: true,
     localPath: file.path,
     downloadedAt: DateTime.now(),
   );
   ```

2. **Cache Validation**:
   ```dart
   final isCached = await cacheService.isAnimationCache(animationId);
   final isValid = isCached && !isExpired;
   ```

3. **Size Management**:
   ```dart
   if (currentSize > maxSizeLimit) {
     await cacheService.enforceCacheSizeLimit();
   }
   ```

### QR Parsing Logic

1. **JSON Parsing**:
   ```dart
   final jsonData = jsonDecode(rawValue);
   return QRCode(
     animationId: jsonData['animation_id'],
     type: jsonData['type'],
     metadata: jsonData,
   );
   ```

2. **Pattern Matching**:
   ```dart
   final urlMatch = RegExp(r'animation[/:]([a-zA-Z0-9_-]+)').firstMatch(rawValue);
   if (urlMatch != null) {
     return QRCode(animationId: urlMatch.group(1));
   }
   ```

## Error Handling

### Cache Errors
- **Storage full**: Automatic cleanup triggered
- **Network errors**: Retry mechanism with exponential backoff
- **File corruption**: Cache validation and cleanup

### QR Scanner Errors
- **Invalid format**: Graceful degradation to unknown QR type
- **Camera permissions**: Request and handle denial
- **Scanning failures**: User feedback and retry options

## Testing

### Unit Tests
- QR parsing logic validation
- Cache service operations
- Use case business logic
- Repository implementations

### Integration Tests
- End-to-end QR scanning workflow
- Cache management UI interactions
- Download and playback scenarios

## Performance Considerations

### Cache Optimization
- Lazy loading of animation metadata
- Background cache cleanup
- Efficient file I/O operations
- Memory-conscious image loading

### QR Scanner Performance
- Real-time frame processing
- Optimized pattern matching
- Minimal UI thread blocking
- Battery-efficient camera usage

## Security Considerations

### Cache Security
- Encrypted storage for sensitive animations
- Cache isolation between app versions
- Secure file deletion

### QR Security
- Input validation for QR content
- Prevention of malicious code execution
- Safe URL handling

## Future Enhancements

### Planned Features
- **Cloud sync**: Synchronize cache across devices
- **Smart preloading**: Predictive content downloading
- **Advanced QR formats**: Support for more complex data
- **Cache analytics**: Usage statistics and insights

### Performance Improvements
- **Delta updates**: Only download changed portions
- **Compression**: Reduce cache footprint
- **Background processing**: Non-blocking operations

## Troubleshooting

### Common Issues

1. **Cache not clearing**:
   - Check app permissions
   - Verify storage availability
   - Restart the app

2. **QR scanner not working**:
   - Check camera permissions
   - Ensure good lighting
   - Clean camera lens

3. **Animations not downloading**:
   - Check network connection
   - Verify QR code validity
   - Check available storage

### Debug Information

Enable debug mode to see:
- Cache operation logs
- QR parsing details
- Network request status
- Error stack traces

## API Reference

### CacheService
```dart
// Download animation
Future<File> downloadAnimation(String url, String key);

// Check if cached
Future<bool> isAnimationCached(String key);

// Get cached file
Future<File?> getCachedAnimation(String key);

// Clear cache
Future<void> clearAllCache();
```

### QRService
```dart
// Parse QR code
Future<QRCode> parseQRCode(String rawValue);

// Get scan history
Future<List<QRCode>> getScanHistory();

// Clear history
Future<void> clearScanHistory();
```

This comprehensive guide covers all aspects of the caching and QR scanner functionality, providing both user-facing documentation and technical implementation details.