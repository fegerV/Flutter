import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/animation.dart';
import '../../domain/usecases/get_cached_animations_usecase.dart';
import '../../domain/usecases/download_animation_usecase.dart';
import '../../core/di/injection_container.dart';

final animationProvider = StateNotifierProvider<AnimationNotifier, AnimationState>((ref) {
  final getCachedAnimationsUseCase = ref.read(getCachedAnimationsUseCaseProvider);
  final downloadAnimationUseCase = ref.read(downloadAnimationUseCaseProvider);
  
  return AnimationNotifier(
    getCachedAnimationsUseCase,
    downloadAnimationUseCase,
  );
});

final getCachedAnimationsUseCaseProvider = Provider<GetCachedAnimationsUseCase>((ref) {
  return ref.read(getItProvider).get<GetCachedAnimationsUseCase>();
});

final downloadAnimationUseCaseProvider = Provider<DownloadAnimationUseCase>((ref) {
  return ref.read(getItProvider).get<DownloadAnimationUseCase>();
});

class AnimationNotifier extends StateNotifier<AnimationState> {
  final GetCachedAnimationsUseCase _getCachedAnimationsUseCase;
  final DownloadAnimationUseCase _downloadAnimationUseCase;

  AnimationNotifier(
    this._getCachedAnimationsUseCase,
    this._downloadAnimationUseCase,
  ) : super(const AnimationState.initial());

  Future<void> loadAnimations({bool onlyDownloaded = false}) async {
    state = const AnimationState.loading();
    
    try {
      final animations = await _getCachedAnimationsUseCase(
        GetCachedAnimationsParams(onlyDownloaded: onlyDownloaded),
      );
      state = AnimationState.loaded(animations);
    } catch (e) {
      state = AnimationState.error(e.toString());
    }
  }

  Future<void> downloadAnimation(Animation animation) async {
    final currentAnimations = state.whenOrNull(
      loaded: (animations) => animations,
    ) ?? <Animation>[];

    // Update animation state to downloading
    final updatedAnimations = currentAnimations.map((a) {
      if (a.id == animation.id) {
        return a.copyWith(isDownloaded: true);
      }
      return a;
    }).toList();

    state = AnimationState.loaded(updatedAnimations);

    try {
      final downloadedAnimation = await _downloadAnimationUseCase(
        DownloadAnimationParams(animation),
      );

      // Update animation with download info
      final finalAnimations = updatedAnimations.map((a) {
        if (a.id == downloadedAnimation.id) {
          return downloadedAnimation;
        }
        return a;
      }).toList();

      state = AnimationState.loaded(finalAnimations);
    } catch (e) {
      // Revert to original state on error
      state = AnimationState.loaded(currentAnimations);
      state = AnimationState.error(e.toString());
    }
  }

  void refresh() {
    loadAnimations(onlyDownloaded: state.whenOrNull(
      loaded: (animations) => animations.every((a) => a.isDownloaded),
    ) ?? false);
  }
}

class AnimationState {
  final List<Animation> animations;
  final bool isLoading;
  final String? error;

  const AnimationState._({
    required this.animations,
    required this.isLoading,
    this.error,
  });

  const AnimationState.initial() : this._(animations: [], isLoading: false);

  const AnimationState.loading() : this._(animations: [], isLoading: true);

  const AnimationState.loaded(List<Animation> animations)
      : this._(animations: animations, isLoading: false);

  const AnimationState.error(String error)
      : this._(animations: [], isLoading: false, error: error);

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Animation> animations) loaded,
    required T Function(String error) error,
  }) {
    if (isLoading) {
      return loading();
    } else if (this.error != null) {
      return error(this.error!);
    } else if (animations.isEmpty && !isLoading) {
      return initial();
    } else {
      return loaded(animations);
    }
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Animation> animations)? loaded,
    T Function(String error)? error,
  }) {
    if (isLoading && loading != null) {
      return loading();
    } else if (this.error != null && error != null) {
      return error(this.error!);
    } else if (animations.isEmpty && !isLoading && initial != null) {
      return initial();
    } else if (loaded != null) {
      return loaded(animations);
    }
    return null;
  }
}