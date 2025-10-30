import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/config/app_config.dart';
import '../../../core/error/exceptions.dart';
import '../../models/auth_token_model.dart';

@lazySingleton
class AuthApiClient {
  final Dio dio;

  AuthApiClient(this.dio);

  Future<AuthTokenModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${AppConfig.apiBaseUrl}${AppConfig.authTokenEndpoint}',
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
        },
      );

      if (response.statusCode == 200) {
        return AuthTokenModel.fromJson(response.data);
      } else {
        throw AuthException(
          'Login failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid credentials', 401);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error during login: $e');
    }
  }

  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '${AppConfig.apiBaseUrl}${AppConfig.authRefreshEndpoint}',
        data: {
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        return AuthTokenModel.fromJson(response.data);
      } else {
        throw AuthException(
          'Token refresh failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid or expired refresh token', 401);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error during token refresh: $e');
    }
  }

  Future<void> logout(String accessToken) async {
    try {
      final response = await dio.post(
        '${AppConfig.apiBaseUrl}/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Logout failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error during logout: $e');
    }
  }
}
