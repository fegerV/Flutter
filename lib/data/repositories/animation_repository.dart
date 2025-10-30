import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/animation_metadata.dart';
import '../datasources/local/secure_storage_service.dart';
import '../datasources/remote/animation_api_client.dart';
import '../datasources/remote/minio_client.dart';

abstract class AnimationRepository {
  Future<Either<Failure, List<AnimationMetadata>>> getAnimations({
    int page = 1,
    int limit = 20,
  });
  
  Future<Either<Failure, AnimationMetadata>> getAnimationById(String id);
  
  Future<Either<Failure, List<AnimationMetadata>>> searchAnimations({
    required String query,
    List<String>? tags,
  });
  
  Future<Either<Failure, void>> downloadAnimation({
    required String objectName,
    required String destinationPath,
    ProgressCallback? onProgress,
  });
  
  Future<Either<Failure, String>> getAnimationStreamUrl({
    required String objectName,
    Duration expiry = const Duration(hours: 1),
  });
}

@LazySingleton(as: AnimationRepository)
class AnimationRepositoryImpl implements AnimationRepository {
  final AnimationApiClient apiClient;
  final MinioClientService minioClient;
  final SecureStorageService secureStorage;
  final NetworkInfo networkInfo;

  AnimationRepositoryImpl({
    required this.apiClient,
    required this.minioClient,
    required this.secureStorage,
    required this.networkInfo,
  });

  Future<String?> _getAccessToken() async {
    try {
      return await secureStorage.getAccessToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, List<AnimationMetadata>>> getAnimations({
    int page = 1,
    int limit = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final accessToken = await _getAccessToken();
      
      final models = await retry(
        () => apiClient.getAnimations(
          accessToken: accessToken,
          page: page,
          limit: limit,
        ),
        retryIf: (e) => e is NetworkException,
        maxAttempts: 3,
      );

      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnimationMetadata>> getAnimationById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final accessToken = await _getAccessToken();
      
      final model = await retry(
        () => apiClient.getAnimationById(id: id, accessToken: accessToken),
        retryIf: (e) => e is NetworkException,
        maxAttempts: 3,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnimationMetadata>>> searchAnimations({
    required String query,
    List<String>? tags,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final accessToken = await _getAccessToken();
      
      final models = await retry(
        () => apiClient.searchAnimations(
          query: query,
          accessToken: accessToken,
          tags: tags,
        ),
        retryIf: (e) => e is NetworkException,
        maxAttempts: 3,
      );

      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> downloadAnimation({
    required String objectName,
    required String destinationPath,
    ProgressCallback? onProgress,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await retry(
        () => minioClient.downloadObject(
          objectName: objectName,
          destinationPath: destinationPath,
          onProgress: onProgress,
        ),
        retryIf: (e) => e is StorageException && e.message.contains('timeout'),
        maxAttempts: 3,
      );

      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getAnimationStreamUrl({
    required String objectName,
    Duration expiry = const Duration(hours: 1),
  }) async {
    try {
      final url = await minioClient.getPresignedUrl(
        objectName: objectName,
        expiry: expiry,
      );

      return Right(url);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
