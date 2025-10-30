import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/config/app_config.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_asset_model.dart';

@lazySingleton
class UserAssetApiClient {
  final Dio dio;

  UserAssetApiClient(this.dio);

  Future<List<UserAssetModel>> getUserAssets({
    required String accessToken,
    int page = 1,
    int limit = 20,
    String? assetType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (assetType != null) {
        queryParams['asset_type'] = assetType;
      }

      final response = await dio.get(
        '${AppConfig.apiBaseUrl}/user/assets',
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['assets'] ?? response.data;
        return data.map((json) => UserAssetModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Failed to fetch user assets with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized', 401);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error fetching user assets: $e');
    }
  }

  Future<UserAssetModel> getUserAssetById({
    required String id,
    required String accessToken,
  }) async {
    try {
      final response = await dio.get(
        '${AppConfig.apiBaseUrl}/user/assets/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        return UserAssetModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to fetch user asset with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized', 401);
      } else if (e.response?.statusCode == 404) {
        throw ServerException('User asset not found', 404);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error fetching user asset: $e');
    }
  }
}
