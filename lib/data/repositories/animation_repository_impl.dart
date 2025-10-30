import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/animation.dart';
import '../../domain/repositories/animation_repository.dart';
import '../services/cache_service.dart';
import '../datasources/animation_remote_data_source.dart';

@injectable
class AnimationRepositoryImpl implements AnimationRepository {
  final AnimationRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;
  final Dio _dio;

  AnimationRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
    this._dio,
  );

  @override
  Future<List<Animation>> getAnimations() async {
    return await _remoteDataSource.getAnimations();
  }

  @override
  Future<Animation?> getAnimationById(String id) async {
    return await _remoteDataSource.getAnimationById(id);
  }

  @override
  Future<Animation> downloadAnimation(Animation animation) async {
    try {
      // Download the animation file
      final file = await _cacheService.downloadAnimation(
        animation.fileUrl,
        animation.id,
      );

      // Update animation with download info
      return animation.copyWith(
        isDownloaded: true,
        downloadedAt: DateTime.now(),
        localPath: file.path,
      );
    } catch (e) {
      throw Exception('Failed to download animation: $e');
    }
  }

  @override
  Future<void> deleteCachedAnimation(String animationId) async {
    await _cacheService.removeCachedAnimation(animationId);
  }

  @override
  Future<List<Animation>> getCachedAnimations({bool onlyDownloaded = false}) async {
    final allAnimations = await _remoteDataSource.getAnimations();
    final cachedAnimations = <Animation>[];

    for (final animation in allAnimations) {
      final isCached = await isAnimationCached(animation.id);
      if (isCached) {
        final localPath = await getLocalAnimationPath(animation.id);
        cachedAnimations.add(animation.copyWith(
          isDownloaded: true,
          downloadedAt: DateTime.now(), // We don't store this info, so use current time
          localPath: localPath,
        ));
      } else if (!onlyDownloaded) {
        cachedAnimations.add(animation);
      }
    }

    return cachedAnimations;
  }

  @override
  Future<bool> isAnimationCached(String animationId) async {
    return await _cacheService.isAnimationCached(animationId);
  }

  @override
  Future<String?> getLocalAnimationPath(String animationId) async {
    final file = await _cacheService.getCachedAnimation(animationId);
    return file?.path;
  }
}