import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/marker_definition.dart';
import '../datasources/local/secure_storage_service.dart';
import '../datasources/remote/marker_api_client.dart';

abstract class MarkerRepository {
  Future<Either<Failure, List<MarkerDefinition>>> getMarkers({
    int page = 1,
    int limit = 20,
  });
  
  Future<Either<Failure, MarkerDefinition>> getMarkerById(String id);
}

@LazySingleton(as: MarkerRepository)
class MarkerRepositoryImpl implements MarkerRepository {
  final MarkerApiClient apiClient;
  final SecureStorageService secureStorage;
  final NetworkInfo networkInfo;

  MarkerRepositoryImpl({
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
  Future<Either<Failure, List<MarkerDefinition>>> getMarkers({
    int page = 1,
    int limit = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final accessToken = await _getAccessToken();
      
      final models = await retry(
        () => apiClient.getMarkers(
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
  Future<Either<Failure, MarkerDefinition>> getMarkerById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final accessToken = await _getAccessToken();
      
      final model = await retry(
        () => apiClient.getMarkerById(id: id, accessToken: accessToken),
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
