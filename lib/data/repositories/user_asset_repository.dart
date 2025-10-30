import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user_asset.dart';
import '../datasources/local/secure_storage_service.dart';
import '../datasources/remote/user_asset_api_client.dart';

abstract class UserAssetRepository {
  Future<Either<Failure, List<UserAsset>>> getUserAssets({
    int page = 1,
    int limit = 20,
    String? assetType,
  });
  
  Future<Either<Failure, UserAsset>> getUserAssetById(String id);
}

@LazySingleton(as: UserAssetRepository)
class UserAssetRepositoryImpl implements UserAssetRepository {
  final UserAssetApiClient apiClient;
  final SecureStorageService secureStorage;
  final NetworkInfo networkInfo;

  UserAssetRepositoryImpl({
    required this.apiClient,
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
  Future<Either<Failure, List<UserAsset>>> getUserAssets({
    int page = 1,
    int limit = 20,
    String? assetType,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final accessToken = await _getAccessToken();
      
      if (accessToken == null) {
        return const Left(AuthFailure('No access token available'));
      }

      final models = await retry(
        () => apiClient.getUserAssets(
          accessToken: accessToken,
          page: page,
          limit: limit,
          assetType: assetType,
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
  Future<Either<Failure, UserAsset>> getUserAssetById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final accessToken = await _getAccessToken();
      
      if (accessToken == null) {
        return const Left(AuthFailure('No access token available'));
      }

      final model = await retry(
        () => apiClient.getUserAssetById(id: id, accessToken: accessToken),
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
}
