import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../domain/entities/cache_info.dart';
import '../../domain/entities/animation.dart';
import '../../domain/repositories/cache_repository.dart';
import '../services/cache_service.dart';

@injectable
class CacheRepositoryImpl implements CacheRepository {
  final CacheService _cacheService;
  final StreamController<CacheInfo> _cacheInfoController = StreamController<CacheInfo>.broadcast();

  CacheRepositoryImpl(this._cacheService);

  @override
  Future<CacheInfo> getCacheInfo() async {
    final totalSize = await _cacheService.getCacheSize();
    final itemCount = await _cacheService.getCacheItemCount();
    final lastCleanup = await _cacheService.getLastCleanupTime();

    return CacheInfo(
      totalSize: totalSize,
      usedSize: totalSize,
      itemCount: itemCount,
      lastCleanup: lastCleanup,
      maxSizeLimit: 500 * 1024 * 1024, // 500MB
      ttl: const Duration(days: 7),
    );
  }

  @override
  Future<void> clearCache({String? animationId}) async {
    if (animationId != null) {
      await _cacheService.removeCachedAnimation(animationId);
    } else {
      await _cacheService.clearAllCache();
    }
    
    await _cacheService.updateLastCleanupTime();
    _notifyCacheInfoChange();
  }

  @override
  Future<void> cleanupExpiredCache() async {
    await _cacheService.cleanupExpiredCache();
    await _cacheService.updateLastCleanupTime();
    _notifyCacheInfoChange();
  }

  @override
  Future<void> enforceCacheSizeLimit() async {
    await _cacheService.enforceCacheSizeLimit();
    await _cacheService.updateLastCleanupTime();
    _notifyCacheInfoChange();
  }

  @override
  Future<Stream<CacheInfo>> getCacheInfoStream() async {
    // Initial cache info
    final initialInfo = await getCacheInfo();
    _cacheInfoController.add(initialInfo);
    
    return _cacheInfoController.stream;
  }

  @override
  Future<int> getCacheSize() async {
    return await _cacheService.getCacheSize();
  }

  @override
  Future<void> optimizeCache() async {
    await cleanupExpiredCache();
    await enforceCacheSizeLimit();
    _notifyCacheInfoChange();
  }

  void _notifyCacheInfoChange() {
    getCacheInfo().then(_cacheInfoController.add);
  }

  void dispose() {
    _cacheInfoController.close();
  }
}