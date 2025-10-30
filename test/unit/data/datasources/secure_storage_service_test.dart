import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_ar_app/core/error/exceptions.dart';
import 'package:flutter_ar_app/data/datasources/local/secure_storage_service.dart';

import 'secure_storage_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late SecureStorageService service;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    service = SecureStorageService(mockSecureStorage);
  });

  group('saveAccessToken', () {
    test('should save access token successfully', () async {
      const token = 'access_token';
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      await service.saveAccessToken(token);

      verify(mockSecureStorage.write(
        key: 'access_token',
        value: token,
      )).called(1);
    });

    test('should throw StorageException when save fails', () async {
      const token = 'access_token';
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenThrow(Exception('Storage error'));

      expect(
        () => service.saveAccessToken(token),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getAccessToken', () {
    test('should return access token when it exists', () async {
      const token = 'access_token';
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => token);

      final result = await service.getAccessToken();

      expect(result, token);
      verify(mockSecureStorage.read(key: 'access_token')).called(1);
    });

    test('should return null when token does not exist', () async {
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      final result = await service.getAccessToken();

      expect(result, null);
    });
  });

  group('saveRefreshToken', () {
    test('should save refresh token successfully', () async {
      const token = 'refresh_token';
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      await service.saveRefreshToken(token);

      verify(mockSecureStorage.write(
        key: 'refresh_token',
        value: token,
      )).called(1);
    });
  });

  group('getRefreshToken', () {
    test('should return refresh token when it exists', () async {
      const token = 'refresh_token';
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => token);

      final result = await service.getRefreshToken();

      expect(result, token);
    });
  });

  group('saveTokenExpiry', () {
    test('should save token expiry successfully', () async {
      final expiry = DateTime.now().add(const Duration(hours: 1));
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      await service.saveTokenExpiry(expiry);

      verify(mockSecureStorage.write(
        key: 'token_expiry',
        value: expiry.toIso8601String(),
      )).called(1);
    });
  });

  group('getTokenExpiry', () {
    test('should return token expiry when it exists', () async {
      final expiry = DateTime.now().add(const Duration(hours: 1));
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => expiry.toIso8601String());

      final result = await service.getTokenExpiry();

      expect(result, isNotNull);
      expect(result!.difference(expiry).inSeconds, lessThan(1));
    });

    test('should return null when expiry does not exist', () async {
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      final result = await service.getTokenExpiry();

      expect(result, null);
    });
  });

  group('clearTokens', () {
    test('should clear all tokens successfully', () async {
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      await service.clearTokens();

      verify(mockSecureStorage.delete(key: 'access_token')).called(1);
      verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
      verify(mockSecureStorage.delete(key: 'token_expiry')).called(1);
      verify(mockSecureStorage.delete(key: 'token_type')).called(1);
    });
  });

  group('hasValidToken', () {
    test('should return true when valid token exists', () async {
      final expiry = DateTime.now().add(const Duration(hours: 1));
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'token');
      when(mockSecureStorage.read(key: 'token_expiry'))
          .thenAnswer((_) async => expiry.toIso8601String());

      final result = await service.hasValidToken();

      expect(result, true);
    });

    test('should return false when token is expired', () async {
      final expiry = DateTime.now().subtract(const Duration(hours: 1));
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'token');
      when(mockSecureStorage.read(key: 'token_expiry'))
          .thenAnswer((_) async => expiry.toIso8601String());

      final result = await service.hasValidToken();

      expect(result, false);
    });

    test('should return false when token does not exist', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      final result = await service.hasValidToken();

      expect(result, false);
    });
  });
}
