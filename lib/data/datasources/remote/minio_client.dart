import 'dart:io';
import 'dart:typed_data';
import 'package:minio/minio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/config/app_config.dart';
import '../../../core/error/exceptions.dart';

typedef ProgressCallback = void Function(int received, int total);

@lazySingleton
class MinioClientService {
  late final Minio _minio;

  MinioClientService() {
    _initializeClient();
  }

  void _initializeClient() {
    _minio = Minio(
      endPoint: AppConfig.minioEndpoint,
      port: AppConfig.minioPort,
      accessKey: AppConfig.minioAccessKey,
      secretKey: AppConfig.minioSecretKey,
      useSSL: AppConfig.minioUseSSL,
    );
  }

  Future<Stream<Uint8List>> streamObject({
    required String objectName,
    String? bucket,
  }) async {
    try {
      final bucketName = bucket ?? AppConfig.minioBucket;
      
      final exists = await _minio.bucketExists(bucketName);
      if (!exists) {
        throw StorageException('Bucket $bucketName does not exist');
      }

      return _minio.getObject(bucketName, objectName);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to stream object: $e');
    }
  }

  Future<void> downloadObject({
    required String objectName,
    required String destinationPath,
    String? bucket,
    ProgressCallback? onProgress,
  }) async {
    try {
      final bucketName = bucket ?? AppConfig.minioBucket;
      
      final exists = await _minio.bucketExists(bucketName);
      if (!exists) {
        throw StorageException('Bucket $bucketName does not exist');
      }

      final stat = await _minio.statObject(bucketName, objectName);
      final totalSize = stat.size ?? 0;

      final stream = await streamObject(objectName: objectName, bucket: bucket);
      final file = File(destinationPath);
      final sink = file.openWrite();

      int receivedBytes = 0;

      await for (final chunk in stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        
        if (onProgress != null && totalSize > 0) {
          onProgress(receivedBytes, totalSize);
        }
      }

      await sink.close();
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to download object: $e');
    }
  }

  Future<Uint8List> getObjectBytes({
    required String objectName,
    String? bucket,
  }) async {
    try {
      final bucketName = bucket ?? AppConfig.minioBucket;
      
      final exists = await _minio.bucketExists(bucketName);
      if (!exists) {
        throw StorageException('Bucket $bucketName does not exist');
      }

      final stream = await streamObject(objectName: objectName, bucket: bucket);
      final bytes = <int>[];

      await for (final chunk in stream) {
        bytes.addAll(chunk);
      }

      return Uint8List.fromList(bytes);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to get object bytes: $e');
    }
  }

  Future<String> getPresignedUrl({
    required String objectName,
    String? bucket,
    Duration expiry = const Duration(hours: 1),
  }) async {
    try {
      final bucketName = bucket ?? AppConfig.minioBucket;
      
      final exists = await _minio.bucketExists(bucketName);
      if (!exists) {
        throw StorageException('Bucket $bucketName does not exist');
      }

      return await _minio.presignedGetObject(
        bucketName,
        objectName,
        expires: expiry.inSeconds,
      );
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to generate presigned URL: $e');
    }
  }

  Future<bool> objectExists({
    required String objectName,
    String? bucket,
  }) async {
    try {
      final bucketName = bucket ?? AppConfig.minioBucket;
      
      final exists = await _minio.bucketExists(bucketName);
      if (!exists) {
        return false;
      }

      await _minio.statObject(bucketName, objectName);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int?> getObjectSize({
    required String objectName,
    String? bucket,
  }) async {
    try {
      final bucketName = bucket ?? AppConfig.minioBucket;
      
      final exists = await _minio.bucketExists(bucketName);
      if (!exists) {
        throw StorageException('Bucket $bucketName does not exist');
      }

      final stat = await _minio.statObject(bucketName, objectName);
      return stat.size;
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to get object size: $e');
    }
  }
}
