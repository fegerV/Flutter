import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/config/app_config.dart';
import '../../../core/error/exceptions.dart';
import '../../models/animation_metadata_model.dart';

@lazySingleton
class AnimationApiClient {
  final Dio dio;

  AnimationApiClient(this.dio);

  Future<List<AnimationMetadataModel>> getAnimations({
    String? accessToken,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '${AppConfig.apiBaseUrl}/animations',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: accessToken != null
              ? {'Authorization': 'Bearer $accessToken'}
              : null,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['animations'] ?? response.data;
        return data
            .map((json) => AnimationMetadataModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          'Failed to fetch animations with status: ${response.statusCode}',
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
      throw ServerException('Unexpected error fetching animations: $e');
    }
  }

  Future<AnimationMetadataModel> getAnimationById({
    required String id,
    String? accessToken,
  }) async {
    try {
      final response = await dio.get(
        '${AppConfig.apiBaseUrl}/animations/$id',
        options: Options(
          headers: accessToken != null
              ? {'Authorization': 'Bearer $accessToken'}
              : null,
        ),
      );

      if (response.statusCode == 200) {
        return AnimationMetadataModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to fetch animation with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized', 401);
      } else if (e.response?.statusCode == 404) {
        throw ServerException('Animation not found', 404);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error fetching animation: $e');
    }
  }

  Future<List<AnimationMetadataModel>> searchAnimations({
    required String query,
    String? accessToken,
    List<String>? tags,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'query': query,
      };

      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags.join(',');
      }

      final response = await dio.get(
        '${AppConfig.apiBaseUrl}/animations/search',
        queryParameters: queryParams,
        options: Options(
          headers: accessToken != null
              ? {'Authorization': 'Bearer $accessToken'}
              : null,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['animations'] ?? response.data;
        return data
            .map((json) => AnimationMetadataModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          'Failed to search animations with status: ${response.statusCode}',
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
      throw ServerException('Unexpected error searching animations: $e');
    }
  }
}
