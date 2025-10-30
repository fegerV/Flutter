import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/exceptions.dart';

@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _tokenTypeKey = 'token_type';

  SecureStorageService(this.secureStorage);

  Future<void> saveAccessToken(String token) async {
    try {
      await secureStorage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      throw StorageException('Failed to save access token: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      throw StorageException('Failed to read access token: $e');
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await secureStorage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw StorageException('Failed to save refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      throw StorageException('Failed to read refresh token: $e');
    }
  }

  Future<void> saveTokenExpiry(DateTime expiry) async {
    try {
      await secureStorage.write(
        key: _tokenExpiryKey,
        value: expiry.toIso8601String(),
      );
    } catch (e) {
      throw StorageException('Failed to save token expiry: $e');
    }
  }

  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = await secureStorage.read(key: _tokenExpiryKey);
      return expiryString != null ? DateTime.parse(expiryString) : null;
    } catch (e) {
      throw StorageException('Failed to read token expiry: $e');
    }
  }

  Future<void> saveTokenType(String tokenType) async {
    try {
      await secureStorage.write(key: _tokenTypeKey, value: tokenType);
    } catch (e) {
      throw StorageException('Failed to save token type: $e');
    }
  }

  Future<String?> getTokenType() async {
    try {
      return await secureStorage.read(key: _tokenTypeKey);
    } catch (e) {
      throw StorageException('Failed to read token type: $e');
    }
  }

  Future<void> clearTokens() async {
    try {
      await secureStorage.delete(key: _accessTokenKey);
      await secureStorage.delete(key: _refreshTokenKey);
      await secureStorage.delete(key: _tokenExpiryKey);
      await secureStorage.delete(key: _tokenTypeKey);
    } catch (e) {
      throw StorageException('Failed to clear tokens: $e');
    }
  }

  Future<bool> hasValidToken() async {
    try {
      final accessToken = await getAccessToken();
      final expiry = await getTokenExpiry();

      if (accessToken == null || expiry == null) {
        return false;
      }

      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }
}
