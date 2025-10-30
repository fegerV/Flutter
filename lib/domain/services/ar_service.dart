import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../data/datasources/remote/minio_client.dart';
import '../../data/repositories/animation_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/marker_repository.dart';
import '../../data/repositories/user_asset_repository.dart';
import '../entities/animation_metadata.dart';
import '../entities/auth_token.dart';
import '../entities/marker_definition.dart';
import '../entities/user_asset.dart';

@lazySingleton
class ArService {
  final AuthRepository authRepository;
  final AnimationRepository animationRepository;
  final MarkerRepository markerRepository;
  final UserAssetRepository userAssetRepository;

  ArService({
    required this.authRepository,
    required this.animationRepository,
    required this.markerRepository,
    required this.userAssetRepository,
  });

  Future<Either<Failure, AuthToken>> authenticate({
    required String username,
    required String password,
  }) async {
    return await authRepository.login(username: username, password: password);
  }

  Future<Either<Failure, AuthToken>> refreshAuthentication() async {
    return await authRepository.refreshToken();
  }

  Future<bool> isAuthenticated() async {
    return await authRepository.isAuthenticated();
  }

  Future<Either<Failure, AuthToken?>> getCurrentToken() async {
    return await authRepository.getCachedToken();
  }

  Future<Either<Failure, void>> signOut() async {
    return await authRepository.logout();
  }

  Future<Either<Failure, List<AnimationMetadata>>> fetchAnimations({
    int page = 1,
    int limit = 20,
  }) async {
    final cachedTokenResult = await authRepository.getCachedToken();
    
    return cachedTokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        if (token != null && token.isExpiringSoon) {
          await authRepository.refreshToken();
        }
        
        return await animationRepository.getAnimations(page: page, limit: limit);
      },
    );
  }

  Future<Either<Failure, AnimationMetadata>> fetchAnimationById(String id) async {
    final cachedTokenResult = await authRepository.getCachedToken();
    
    return cachedTokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        if (token != null && token.isExpiringSoon) {
          await authRepository.refreshToken();
        }
        
        return await animationRepository.getAnimationById(id);
      },
    );
  }

  Future<Either<Failure, List<AnimationMetadata>>> searchAnimations({
    required String query,
    List<String>? tags,
  }) async {
    final cachedTokenResult = await authRepository.getCachedToken();
    
    return cachedTokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        if (token != null && token.isExpiringSoon) {
          await authRepository.refreshToken();
        }
        
        return await animationRepository.searchAnimations(
          query: query,
          tags: tags,
        );
      },
    );
  }

  Future<Either<Failure, void>> downloadAnimation({
    required String objectName,
    required String destinationPath,
    ProgressCallback? onProgress,
  }) async {
    return await animationRepository.downloadAnimation(
      objectName: objectName,
      destinationPath: destinationPath,
      onProgress: onProgress,
    );
  }

  Future<Either<Failure, String>> getAnimationStreamUrl({
    required String objectName,
    Duration expiry = const Duration(hours: 1),
  }) async {
    return await animationRepository.getAnimationStreamUrl(
      objectName: objectName,
      expiry: expiry,
    );
  }

  Future<Either<Failure, List<MarkerDefinition>>> fetchMarkers({
    int page = 1,
    int limit = 20,
  }) async {
    final cachedTokenResult = await authRepository.getCachedToken();
    
    return cachedTokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        if (token != null && token.isExpiringSoon) {
          await authRepository.refreshToken();
        }
        
        return await markerRepository.getMarkers(page: page, limit: limit);
      },
    );
  }

  Future<Either<Failure, MarkerDefinition>> fetchMarkerById(String id) async {
    final cachedTokenResult = await authRepository.getCachedToken();
    
    return cachedTokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        if (token != null && token.isExpiringSoon) {
          await authRepository.refreshToken();
        }
        
        return await markerRepository.getMarkerById(id);
      },
    );
  }

  Future<Either<Failure, List<UserAsset>>> fetchUserAssets({
    int page = 1,
    int limit = 20,
    String? assetType,
  }) async {
    final cachedTokenResult = await authRepository.getCachedToken();
    
    return cachedTokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        if (token != null && token.isExpiringSoon) {
          await authRepository.refreshToken();
        }
        
        return await userAssetRepository.getUserAssets(
          page: page,
          limit: limit,
          assetType: assetType,
        );
      },
    );
  }

  Future<Either<Failure, UserAsset>> fetchUserAssetById(String id) async {
    final cachedTokenResult = await authRepository.getCachedToken();
    
    return cachedTokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        if (token != null && token.isExpiringSoon) {
          await authRepository.refreshToken();
        }
        
        return await userAssetRepository.getUserAssetById(id);
      },
    );
  }
}
