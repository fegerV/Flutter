import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cache_info.dart';
import '../../domain/usecases/get_cache_info_usecase.dart';
import '../../domain/usecases/clear_cache_usecase.dart';
import '../../domain/repositories/cache_repository.dart';
import '../../core/di/injection_container.dart';

final cacheProvider = StateNotifierProvider<CacheNotifier, CacheState>((ref) {
  final getCacheInfoUseCase = ref.read(getCacheInfoUseCaseProvider);
  final clearCacheUseCase = ref.read(clearCacheUseCaseProvider);
  final cacheRepository = ref.read(cacheRepositoryProvider);
  
  return CacheNotifier(
    getCacheInfoUseCase,
    clearCacheUseCase,
    cacheRepository,
  );
});

final getCacheInfoUseCaseProvider = Provider<GetCacheInfoUseCase>((ref) {
  return ref.read(getItProvider).get<GetCacheInfoUseCase>();
});

final clearCacheUseCaseProvider = Provider<ClearCacheUseCase>((ref) {
  return ref.read(getItProvider).get<ClearCacheUseCase>();
});

final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return ref.read(getItProvider).get<CacheRepository>();
});

class CacheNotifier extends StateNotifier<CacheState> {
  final GetCacheInfoUseCase _getCacheInfoUseCase;
  final ClearCacheUseCase _clearCacheUseCase;
  final CacheRepository _cacheRepository;
  StreamSubscription<CacheInfo>? _cacheInfoSubscription;

  CacheNotifier(
    this._getCacheInfoUseCase,
    this._clearCacheUseCase,
    this._cacheRepository,
  ) : super(const CacheState.initial()) {
    _initializeCacheStream();
  }

  Future<void> _initializeCacheStream() async {
    try {
      final stream = await _cacheRepository.getCacheInfoStream();
      _cacheInfoSubscription = stream.listen((cacheInfo) {
        state = CacheState.loaded(cacheInfo);
      });
    } catch (e) {
      // If stream fails, load initial data
      await loadCacheInfo();
    }
  }

  Future<void> loadCacheInfo() async {
    state = const CacheState.loading();
    
    try {
      final cacheInfo = await _getCacheInfoUseCase(const GetCacheInfoParams());
      state = CacheState.loaded(cacheInfo);
    } catch (e) {
      state = CacheState.error(e.toString());
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _clearCacheUseCase(const ClearCacheParams(clearAll: true));
      // Cache info will be updated via stream
    } catch (e) {
      state = CacheState.error(e.toString());
    }
  }

  Future<void> clearAnimationCache(String animationId) async {
    try {
      await _clearCacheUseCase(ClearCacheParams(animationId: animationId));
      // Cache info will be updated via stream
    } catch (e) {
      state = CacheState.error(e.toString());
    }
  }

  Future<void> optimizeCache() async {
    try {
      await _cacheRepository.optimizeCache();
      // Cache info will be updated via stream
    } catch (e) {
      state = CacheState.error(e.toString());
    }
  }

  @override
  void dispose() {
    _cacheInfoSubscription?.cancel();
    super.dispose();
  }
}

class CacheState {
  final CacheInfo? cacheInfo;
  final bool isLoading;
  final String? error;

  const CacheState._({
    this.cacheInfo,
    required this.isLoading,
    this.error,
  });

  const CacheState.initial() : this._(isLoading: false);

  const CacheState.loading() : this._(isLoading: true);

  const CacheState.loaded(CacheInfo cacheInfo)
      : this._(cacheInfo: cacheInfo, isLoading: false);

  const CacheState.error(String error)
      : this._(isLoading: false, error: error);

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(CacheInfo cacheInfo) loaded,
    required T Function(String error) error,
  }) {
    if (isLoading) {
      return loading();
    } else if (this.error != null) {
      return error(this.error!);
    } else if (cacheInfo != null) {
      return loaded(cacheInfo!);
    } else {
      return initial();
    }
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(CacheInfo cacheInfo)? loaded,
    T Function(String error)? error,
  }) {
    if (isLoading && loading != null) {
      return loading();
    } else if (this.error != null && error != null) {
      return error(this.error!);
    } else if (cacheInfo != null && loaded != null) {
      return loaded(cacheInfo!);
    } else if (initial != null) {
      return initial();
    }
    return null;
  }
}