import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/config/app_config.dart';
import '../../../core/error/exceptions.dart';
import '../../models/marker_definition_model.dart';

@lazySingleton
class MarkerApiClient {
  final Dio dio;

  MarkerApiClient(this.dio);

  Future<List<MarkerDefinitionModel>> getMarkers({
    String? accessToken,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '${AppConfig.apiBaseUrl}/markers',
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
        final List<dynamic> data = response.data['markers'] ?? response.data;
        return data
            .map((json) => MarkerDefinitionModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          'Failed to fetch markers with status: ${response.statusCode}',
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
      throw ServerException('Unexpected error fetching markers: $e');
    }
  }

  Future<MarkerDefinitionModel> getMarkerById({
    required String id,
    String? accessToken,
  }) async {
    try {
      final response = await dio.get(
        '${AppConfig.apiBaseUrl}/markers/$id',
        options: Options(
          headers: accessToken != null
              ? {'Authorization': 'Bearer $accessToken'}
              : null,
        ),
      );

      if (response.statusCode == 200) {
        return MarkerDefinitionModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to fetch marker with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized', 401);
      } else if (e.response?.statusCode == 404) {
        throw ServerException('Marker not found', 404);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error fetching marker: $e');
    }
  }
}
