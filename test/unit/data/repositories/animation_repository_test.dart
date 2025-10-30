import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_ar_app/core/error/exceptions.dart';
import 'package:flutter_ar_app/core/error/failures.dart';
import 'package:flutter_ar_app/core/network/network_info.dart';
import 'package:flutter_ar_app/data/datasources/local/secure_storage_service.dart';
import 'package:flutter_ar_app/data/datasources/remote/animation_api_client.dart';
import 'package:flutter_ar_app/data/datasources/remote/minio_client.dart';
import 'package:flutter_ar_app/data/models/animation_metadata_model.dart';
import 'package:flutter_ar_app/data/repositories/animation_repository.dart';

import 'animation_repository_test.mocks.dart';

@GenerateMocks([
  AnimationApiClient,
  MinioClientService,
  SecureStorageService,
  NetworkInfo,
])
void main() {
  late AnimationRepositoryImpl repository;
  late MockAnimationApiClient mockApiClient;
  late MockMinioClientService mockMinioClient;
  late MockSecureStorageService mockSecureStorage;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockApiClient = MockAnimationApiClient();
    mockMinioClient = MockMinioClientService();
    mockSecureStorage = MockSecureStorageService();
    mockNetworkInfo = MockNetworkInfo();
    
    repository = AnimationRepositoryImpl(
      apiClient: mockApiClient,
      minioClient: mockMinioClient,
      secureStorage: mockSecureStorage,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getAnimations', () {
    final animationModels = [
      const AnimationMetadataModel(
        id: '1',
        name: 'Animation 1',
        description: 'Description 1',
        fileUrl: 'file1.mp4',
        thumbnailUrl: 'thumb1.jpg',
        fileSizeInMb: 10.5,
        durationInSeconds: 30,
        tags: ['tag1', 'tag2'],
        createdAt: '2024-01-01T00:00:00Z',
      ),
    ];

    test('should return list of AnimationMetadata when call is successful', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => 'token');
      when(mockApiClient.getAnimations(
        accessToken: anyNamed('accessToken'),
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => animationModels);

      final result = await repository.getAnimations();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (animations) {
          expect(animations.length, 1);
          expect(animations[0].id, '1');
          expect(animations[0].name, 'Animation 1');
        },
      );
    });

    test('should return NetworkFailure when there is no internet', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getAnimations();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'No internet connection');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ServerFailure when server returns error', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => 'token');
      when(mockApiClient.getAnimations(
        accessToken: anyNamed('accessToken'),
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenThrow(ServerException('Server error', 500));

      final result = await repository.getAnimations();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.statusCode, 500);
        },
        (_) => fail('Should not return success'),
      );
    });
  });

  group('getAnimationById', () {
    const animationModel = AnimationMetadataModel(
      id: '1',
      name: 'Animation 1',
      description: 'Description 1',
      fileUrl: 'file1.mp4',
      thumbnailUrl: 'thumb1.jpg',
      fileSizeInMb: 10.5,
      durationInSeconds: 30,
      tags: ['tag1', 'tag2'],
      createdAt: '2024-01-01T00:00:00Z',
    );

    test('should return AnimationMetadata when call is successful', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => 'token');
      when(mockApiClient.getAnimationById(
        id: anyNamed('id'),
        accessToken: anyNamed('accessToken'),
      )).thenAnswer((_) async => animationModel);

      final result = await repository.getAnimationById('1');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (animation) {
          expect(animation.id, '1');
          expect(animation.name, 'Animation 1');
        },
      );
    });
  });

  group('searchAnimations', () {
    final animationModels = [
      const AnimationMetadataModel(
        id: '1',
        name: 'Animation 1',
        description: 'Description 1',
        fileUrl: 'file1.mp4',
        thumbnailUrl: 'thumb1.jpg',
        fileSizeInMb: 10.5,
        durationInSeconds: 30,
        tags: ['tag1', 'tag2'],
        createdAt: '2024-01-01T00:00:00Z',
      ),
    ];

    test('should return list of AnimationMetadata when search is successful', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockSecureStorage.getAccessToken())
          .thenAnswer((_) async => 'token');
      when(mockApiClient.searchAnimations(
        query: anyNamed('query'),
        accessToken: anyNamed('accessToken'),
        tags: anyNamed('tags'),
      )).thenAnswer((_) async => animationModels);

      final result = await repository.searchAnimations(query: 'test');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (animations) {
          expect(animations.length, 1);
          expect(animations[0].id, '1');
        },
      );
    });
  });

  group('downloadAnimation', () {
    test('should successfully download animation', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockMinioClient.downloadObject(
        objectName: anyNamed('objectName'),
        destinationPath: anyNamed('destinationPath'),
        onProgress: anyNamed('onProgress'),
      )).thenAnswer((_) async => {});

      final result = await repository.downloadAnimation(
        objectName: 'animation.mp4',
        destinationPath: '/path/to/save',
      );

      expect(result.isRight(), true);
    });

    test('should return NetworkFailure when there is no internet', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.downloadAnimation(
        objectName: 'animation.mp4',
        destinationPath: '/path/to/save',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return StorageFailure when download fails', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockMinioClient.downloadObject(
        objectName: anyNamed('objectName'),
        destinationPath: anyNamed('destinationPath'),
        onProgress: anyNamed('onProgress'),
      )).thenThrow(StorageException('Download failed'));

      final result = await repository.downloadAnimation(
        objectName: 'animation.mp4',
        destinationPath: '/path/to/save',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (_) => fail('Should not return success'),
      );
    });
  });

  group('getAnimationStreamUrl', () {
    test('should return presigned URL when successful', () async {
      const url = 'https://minio.example.com/presigned-url';
      when(mockMinioClient.getPresignedUrl(
        objectName: anyNamed('objectName'),
        expiry: anyNamed('expiry'),
      )).thenAnswer((_) async => url);

      final result = await repository.getAnimationStreamUrl(
        objectName: 'animation.mp4',
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (resultUrl) => expect(resultUrl, url),
      );
    });

    test('should return StorageFailure when URL generation fails', () async {
      when(mockMinioClient.getPresignedUrl(
        objectName: anyNamed('objectName'),
        expiry: anyNamed('expiry'),
      )).thenThrow(StorageException('Failed to generate URL'));

      final result = await repository.getAnimationStreamUrl(
        objectName: 'animation.mp4',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (_) => fail('Should not return success'),
      );
    });
  });
}
