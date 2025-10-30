import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/ar_marker.dart';
import '../../domain/repositories/ar_repositories.dart';

@LazySingleton(as: ARMarkerRepository)
class ARMarkerRepositoryImpl implements ARMarkerRepository {
  final Dio _dio;
  final DefaultCacheManager _cacheManager;

  ARMarkerRepositoryImpl(this._dio, this._cacheManager);

  @override
  Future<Either<Exception, MarkerConfiguration>> getMarkerConfiguration(
    String configId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/ar/configurations/$configId',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final config = MarkerConfiguration.fromJson(response.data);
        return Right(config);
      } else {
        return Left(Exception('Failed to load marker configuration: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Exception('Network error: $e'));
    }
  }

  @override
  Future<Either<Exception, List<ARMarker>>> getAllMarkers() async {
    try {
      final response = await _dio.get(
        '/api/ar/markers',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final markers = data.map((json) => ARMarker.fromJson(json)).toList();
        return Right(markers);
      } else {
        return Left(Exception('Failed to load markers: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Exception('Network error: $e'));
    }
  }

  @override
  Future<Either<Exception, ARMarker>> getMarkerById(String markerId) async {
    try {
      final response = await _dio.get(
        '/api/ar/markers/$markerId',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final marker = ARMarker.fromJson(response.data);
        return Right(marker);
      } else {
        return Left(Exception('Failed to load marker: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Exception('Network error: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> downloadMarkerImage(
    String markerId,
    String imageUrl,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final markerDir = Directory(path.join(appDir.path, 'markers', markerId));
      
      if (!await markerDir.exists()) {
        await markerDir.create(recursive: true);
      }

      final file = File(path.join(markerDir.path, 'image.jpg'));
      
      await _cacheManager.downloadFile(imageUrl, file: file);
      
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to download marker image: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> downloadMarkerVideo(
    String markerId,
    String videoUrl,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final markerDir = Directory(path.join(appDir.path, 'markers', markerId));
      
      if (!await markerDir.exists()) {
        await markerDir.create(recursive: true);
      }

      final file = File(path.join(markerDir.path, 'video.mp4'));
      
      await _cacheManager.downloadFile(videoUrl, file: file);
      
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to download marker video: $e'));
    }
  }

  @override
  Future<Either<Exception, bool>> isMarkerImageCached(String markerId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagePath = path.join(appDir.path, 'markers', markerId, 'image.jpg');
      final file = File(imagePath);
      
      return Right(await file.exists());
    } catch (e) {
      return Left(Exception('Failed to check image cache: $e'));
    }
  }

  @override
  Future<Either<Exception, bool>> isMarkerVideoCached(String markerId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final videoPath = path.join(appDir.path, 'markers', markerId, 'video.mp4');
      final file = File(videoPath);
      
      return Right(await file.exists());
    } catch (e) {
      return Left(Exception('Failed to check video cache: $e'));
    }
  }

  @override
  Future<Either<Exception, String>> getCachedMarkerImagePath(String markerId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagePath = path.join(appDir.path, 'markers', markerId, 'image.jpg');
      final file = File(imagePath);
      
      if (await file.exists()) {
        return Right(imagePath);
      } else {
        return Left(Exception('Marker image not cached for $markerId'));
      }
    } catch (e) {
      return Left(Exception('Failed to get cached image path: $e'));
    }
  }

  @override
  Future<Either<Exception, String>> getCachedMarkerVideoPath(String markerId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final videoPath = path.join(appDir.path, 'markers', markerId, 'video.mp4');
      final file = File(videoPath);
      
      if (await file.exists()) {
        return Right(videoPath);
      } else {
        return Left(Exception('Marker video not cached for $markerId'));
      }
    } catch (e) {
      return Left(Exception('Failed to get cached video path: $e'));
    }
  }
}