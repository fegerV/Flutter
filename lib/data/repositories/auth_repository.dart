import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/auth_token.dart';
import '../datasources/local/secure_storage_service.dart';
import '../datasources/remote/auth_api_client.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  });
  
  Future<Either<Failure, AuthToken>> refreshToken();
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, AuthToken?>> getCachedToken();
  
  Future<bool> isAuthenticated();
}

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiClient apiClient;
  final SecureStorageService secureStorage;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.secureStorage,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final tokenModel = await retry(
        () => apiClient.login(username: username, password: password),
        retryIf: (e) => e is NetworkException,
        maxAttempts: 3,
      );

      final token = tokenModel.toEntity();
      
      await secureStorage.saveAccessToken(token.accessToken);
      await secureStorage.saveRefreshToken(token.refreshToken);
      await secureStorage.saveTokenExpiry(token.expiresAt);
      await secureStorage.saveTokenType(token.tokenType);

      return Right(token);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final refreshToken = await secureStorage.getRefreshToken();
      
      if (refreshToken == null) {
        return const Left(AuthFailure('No refresh token available'));
      }

      final tokenModel = await retry(
        () => apiClient.refreshToken(refreshToken),
        retryIf: (e) => e is NetworkException,
        maxAttempts: 3,
      );

      final token = tokenModel.toEntity();
      
      await secureStorage.saveAccessToken(token.accessToken);
      await secureStorage.saveRefreshToken(token.refreshToken);
      await secureStorage.saveTokenExpiry(token.expiresAt);
      await secureStorage.saveTokenType(token.tokenType);

      return Right(token);
    } on AuthException catch (e) {
      await secureStorage.clearTokens();
      return Left(AuthFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final accessToken = await secureStorage.getAccessToken();
      
      if (accessToken != null && await networkInfo.isConnected) {
        try {
          await apiClient.logout(accessToken);
        } catch (e) {
        }
      }

      await secureStorage.clearTokens();
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken?>> getCachedToken() async {
    try {
      final accessToken = await secureStorage.getAccessToken();
      final refreshToken = await secureStorage.getRefreshToken();
      final expiry = await secureStorage.getTokenExpiry();
      final tokenType = await secureStorage.getTokenType();

      if (accessToken == null || refreshToken == null || expiry == null) {
        return const Right(null);
      }

      final token = AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiry,
        tokenType: tokenType ?? 'Bearer',
      );

      return Right(token);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await secureStorage.hasValidToken();
    } catch (e) {
      return false;
    }
  }
}
