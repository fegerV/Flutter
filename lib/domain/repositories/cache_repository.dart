import '../entities/cache_info.dart';
import '../entities/animation.dart';

abstract class CacheRepository {
  Future<CacheInfo> getCacheInfo();
  Future<void> clearCache({String? animationId});
  Future<void> cleanupExpiredCache();
  Future<void> enforceCacheSizeLimit();
  Future<Stream<CacheInfo>> getCacheInfoStream();
  Future<int> getCacheSize();
  Future<void> optimizeCache();
}