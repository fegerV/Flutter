import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_ar_app/core/error/exceptions.dart';
import 'package:flutter_ar_app/core/error/failures.dart';
import 'package:flutter_ar_app/core/network/network_info.dart';
import 'package:flutter_ar_app/data/datasources/local/secure_storage_service.dart';
import 'package:flutter_ar_app/data/datasources/remote/auth_api_client.dart';
import 'package:flutter_ar_app/data/models/auth_token_model.dart';
import 'package:flutter_ar_app/data/repositories/auth_repository.dart';
import 'package:flutter_ar_app/domain/entities/auth_token.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([
  AuthApiClient,
  SecureStorageService,
  NetworkInfo,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthApiClient mockApiClient;
  late MockSecureStorageService mockSecureStorage;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockApiClient = MockAuthApiClient();
    mockSecureStorage = MockSecureStorageService();
    mockNetworkInfo = MockNetworkInfo();
    
    repository = AuthRepositoryImpl(
      apiClient: mockApiClient,
      secureStorage: mockSecureStorage,
      networkInfo: mockNetworkInfo,
    );
  });

  group('login', () {
    const username = 'testuser';
    const password = 'testpass';
    final tokenModel = AuthTokenModel(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresIn: 3600,
    );

    test('should return AuthToken when login is successful', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockApiClient.login(
        username: username,
        password: password,
      )).thenAnswer((_) async => tokenModel);
      when(mockSecureStorage.saveAccessToken(any)).thenAnswer((_) async => {});
      when(mockSecureStorage.saveRefreshToken(any)).thenAnswer((_) async => {});
      when(mockSecureStorage.saveTokenExpiry(any)).thenAnswer((_) async => {});
      when(mockSecureStorage.saveTokenType(any)).thenAnswer((_) async => {});

      final result = await repository.login(
        username: username,
        password: password,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (token) {
          expect(token.accessToken, 'access_token');
          expect(token.refreshToken, 'refresh_token');
        },
      );
      
      verify(mockSecureStorage.saveAccessToken('access_token')).called(1);
      verify(mockSecureStorage.saveRefreshToken('refresh_token')).called(1);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.login(
        username: username,
        password: password,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'No internet connection');
        },
        (_) => fail('Should not return success'),
      );
      
      verifyNever(mockApiClient.login(
        username: anyNamed('username'),
        password: anyNamed('password'),
      ));
    });

    test('should return AuthFailure when credentials are invalid', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockApiClient.login(
        username: username,
        password: password,
      )).thenThrow(AuthException('Invalid credentials', 401));

      final result = await repository.login(
        username: username,
        password: password,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Invalid credentials');
          expect(failure.statusCode, 401);
        },
        (_) => fail('Should not return success'),
      );
    });
  });

  group('refreshToken', () {
    const refreshToken = 'refresh_token';
    final tokenModel = AuthTokenModel(
      accessToken: 'new_access_token',
      refreshToken: 'new_refresh_token',
      expiresIn: 3600,
    );

    test('should return new AuthToken when refresh is successful', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSecureStorage.getRefreshToken())
          .thenAnswer((_) async => refreshToken);
      when(mockApiClient.refreshToken(refreshToken))
          .thenAnswer((_) async => tokenModel);
      when(mockSecureStorage.saveAccessToken(any)).thenAnswer((_) async => {});
      when(mockSecureStorage.saveRefreshToken(any)).thenAnswer((_) async => {});
      when(mockSecureStorage.saveTokenExpiry(any)).thenAnswer((_) async => {});
      when(mockSecureStorage.saveTokenType(any)).thenAnswer((_) async => {});

      final result = await repository.refreshToken();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (token) {
          expect(token.accessToken, 'new_access_token');
          expect(token.refreshToken, 'new_refresh_token');
        },
      );
    });

    test('should return AuthFailure when refresh token is not available', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSecureStorage.getRefreshToken()).thenAnswer((_) async => null);

      final result = await repository.refreshToken();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'No refresh token available');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should clear tokens when refresh fails with AuthException', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSecureStorage.getRefreshToken())
          .thenAnswer((_) async => refreshToken);
      when(mockApiClient.refreshToken(refreshToken))
          .thenThrow(AuthException('Invalid or expired refresh token', 401));
      when(mockSecureStorage.clearTokens()).thenAnswer((_) async => {});

      final result = await repository.refreshToken();

      expect(result.isLeft(), true);
      verify(mockSecureStorage.clearTokens()).called(1);
    });
  });

  group('logout', () {
    test('should successfully logout and clear tokens', () async {
      const accessToken = 'access_token';
      when(mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => accessToken);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockApiClient.logout(accessToken)).thenAnswer((_) async => {});
      when(mockSecureStorage.clearTokens()).thenAnswer((_) async => {});

      final result = await repository.logout();

      expect(result.isRight(), true);
      verify(mockSecureStorage.clearTokens()).called(1);
    });

    test('should clear tokens even when API call fails', () async {
      const accessToken = 'access_token';
      when(mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => accessToken);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockApiClient.logout(accessToken))
          .thenThrow(NetworkException('Network error'));
      when(mockSecureStorage.clearTokens()).thenAnswer((_) async => {});

      final result = await repository.logout();

      expect(result.isRight(), true);
      verify(mockSecureStorage.clearTokens()).called(1);
    });
  });

  group('getCachedToken', () {
    test('should return AuthToken when cached token exists', () async {
      final expiry = DateTime.now().add(const Duration(hours: 1));
      when(mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => 'access_token');
      when(mockSecureStorage.getRefreshToken())
          .thenAnswer((_) async => 'refresh_token');
      when(mockSecureStorage.getTokenExpiry()).thenAnswer((_) async => expiry);
      when(mockSecureStorage.getTokenType()).thenAnswer((_) async => 'Bearer');

      final result = await repository.getCachedToken();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (token) {
          expect(token, isNotNull);
          expect(token!.accessToken, 'access_token');
          expect(token.refreshToken, 'refresh_token');
        },
      );
    });

    test('should return null when no cached token exists', () async {
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);
      when(mockSecureStorage.getRefreshToken()).thenAnswer((_) async => null);
      when(mockSecureStorage.getTokenExpiry()).thenAnswer((_) async => null);

      final result = await repository.getCachedToken();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (token) => expect(token, isNull),
      );
    });
  });

  group('isAuthenticated', () {
    test('should return true when valid token exists', () async {
      when(mockSecureStorage.hasValidToken()).thenAnswer((_) async => true);

      final result = await repository.isAuthenticated();

      expect(result, true);
    });

    test('should return false when no valid token exists', () async {
      when(mockSecureStorage.hasValidToken()).thenAnswer((_) async => false);

      final result = await repository.isAuthenticated();

      expect(result, false);
    });
  });
}
