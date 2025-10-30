import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _cacheKey = 'animation_cache_info';
  static const int _maxCacheSize = 500 * 1024 * 1024; // 500MB
  static const Duration _defaultTtl = Duration(days: 7);

  late final SharedPreferences _prefs;
  late final Directory _cacheDir;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    final appDir = Directory.systemTemp;
    _cacheDir = Directory('${appDir.path}/animations');
    
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
  }

  Future<File> downloadAnimation(String url, String key) async {
    // Simplified implementation - in real app, use HTTP client to download
    final file = File('${_cacheDir.path}/$key.mp4');
    
    // Simulate download
    if (!await file.exists()) {
      await file.writeAsString('Simulated animation content for $key');
    }
    
    return file;
  }

  Future<File?> getCachedAnimation(String key) async {
    final file = File('${_cacheDir.path}/$key.mp4');
    return await file.exists() ? file : null;
  }

  Future<bool> isAnimationCached(String key) async {
    final file = File('${_cacheDir.path}/$key.mp4');
    if (!await file.exists()) return false;
    
    final stat = await file.stat();
    final age = DateTime.now().difference(stat.modified);
    return age < _defaultTtl;
  }

  Future<void> removeCachedAnimation(String key) async {
    final file = File('${_cacheDir.path}/$key.mp4');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clearAllCache() async {
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
      await _cacheDir.create(recursive: true);
    }
  }

  Future<int> getCacheSize() async {
    try {
      if (!await _cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in _cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getCacheItemCount() async {
    try {
      if (!await _cacheDir.exists()) return 0;

      int count = 0;
      await for (final entity in _cacheDir.list()) {
        if (entity is File) {
          count++;
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  Future<void> cleanupExpiredCache() async {
    if (!await _cacheDir.exists()) return;

    await for (final entity in _cacheDir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        final age = DateTime.now().difference(stat.modified);
        if (age > _defaultTtl) {
          try {
            await entity.delete();
          } catch (e) {
            // Skip files that can't be deleted
          }
        }
      }
    }
  }

  Future<void> enforceCacheSizeLimit() async {
    final currentSize = await getCacheSize();
    
    if (currentSize > _maxCacheSize) {
      final files = <FileSystemEntity>[];
      
      await for (final entity in _cacheDir.list()) {
        if (entity is File) {
          files.add(entity);
        }
      }
      
      // Sort files by last modified time (oldest first)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return aStat.modified.compareTo(bStat.modified);
      });
      
      // Remove oldest files until under the limit
      int sizeToFree = currentSize - _maxCacheSize;
      for (final file in files) {
        if (sizeToFree <= 0) break;
        
        try {
          final fileSize = await file.length();
          await file.delete();
          sizeToFree -= fileSize;
        } catch (e) {
          // Skip files that can't be deleted
        }
      }
    }
  }

  Future<DateTime> getLastCleanupTime() async {
    final timestamp = _prefs.getInt(_cacheKey) ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> updateLastCleanupTime() async {
    await _prefs.setInt(_cacheKey, DateTime.now().millisecondsSinceEpoch);
  }
}