import '../entities/animation.dart';

abstract class AnimationRepository {
  Future<List<Animation>> getAnimations();
  Future<Animation?> getAnimationById(String id);
  Future<Animation> downloadAnimation(Animation animation);
  Future<void> deleteCachedAnimation(String animationId);
  Future<List<Animation>> getCachedAnimations({bool onlyDownloaded = false});
  Future<bool> isAnimationCached(String animationId);
  Future<String?> getLocalAnimationPath(String animationId);
}