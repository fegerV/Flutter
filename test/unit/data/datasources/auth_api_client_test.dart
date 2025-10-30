import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_ar_app/core/error/exceptions.dart';
import 'package:flutter_ar_app/data/datasources/remote/auth_api_client.dart';
import 'package:flutter_ar_app/data/models/auth_token_model.dart';

import 'auth_api_client_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late AuthApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = AuthApiClient(mockDio);
  });

  group('login', () {
    const username = 'testuser';
    const password = 'testpass';

    test('should return AuthTokenModel when login is successful', () async {
      final responseData = {
        'access_token': 'access_token',
        'refresh_token': 'refresh_token',
        'expires_in': 3600,
        'token_type': 'Bearer',
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await apiClient.login(
        username: username,
        password: password,
      );

      expect(result, isA<AuthTokenModel>());
      expect(result.accessToken, 'access_token');
      expect(result.refreshToken, 'refresh_token');
      expect(result.expiresIn, 3600);
    });

    test('should throw AuthException when credentials are invalid', () async {
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: ''),
        ),
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
      ));

      expect(
        () => apiClient.login(username: username, password: password),
        throwsA(isA<AuthException>()),
      );
    });

    test('should throw NetworkException when connection times out', () async {
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => apiClient.login(username: username, password: password),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should throw NetworkException when there is no connection', () async {
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ));

      expect(
        () => apiClient.login(username: username, password: password),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('refreshToken', () {
    const refreshToken = 'refresh_token';

    test('should return AuthTokenModel when refresh is successful', () async {
      final responseData = {
        'access_token': 'new_access_token',
        'refresh_token': 'new_refresh_token',
        'expires_in': 3600,
        'token_type': 'Bearer',
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await apiClient.refreshToken(refreshToken);

      expect(result, isA<AuthTokenModel>());
      expect(result.accessToken, 'new_access_token');
      expect(result.refreshToken, 'new_refresh_token');
    });

    test('should throw AuthException when refresh token is invalid', () async {
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: ''),
        ),
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
      ));

      expect(
        () => apiClient.refreshToken(refreshToken),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('logout', () {
    const accessToken = 'access_token';

    test('should complete successfully when logout succeeds', () async {
      when(mockDio.post(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      expect(
        () => apiClient.logout(accessToken),
        returnsNormally,
      );
    });

    test('should throw NetworkException when connection fails', () async {
      when(mockDio.post(
        any,
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ));

      expect(
        () => apiClient.logout(accessToken),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
