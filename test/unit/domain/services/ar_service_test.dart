import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_ar_app/core/error/failures.dart';
import 'package:flutter_ar_app/data/repositories/animation_repository.dart';
import 'package:flutter_ar_app/data/repositories/auth_repository.dart';
import 'package:flutter_ar_app/data/repositories/marker_repository.dart';
import 'package:flutter_ar_app/data/repositories/user_asset_repository.dart';
import 'package:flutter_ar_app/domain/entities/animation_metadata.dart';
import 'package:flutter_ar_app/domain/entities/auth_token.dart';
import 'package:flutter_ar_app/domain/entities/marker_definition.dart';
import 'package:flutter_ar_app/domain/entities/user_asset.dart';
import 'package:flutter_ar_app/domain/services/ar_service.dart';

import 'ar_service_test.mocks.dart';

@GenerateMocks([
  AuthRepository,
  AnimationRepository,
  MarkerRepository,
  UserAssetRepository,
])
void main() {
  late ArService arService;
  late MockAuthRepository mockAuthRepository;
  late MockAnimationRepository mockAnimationRepository;
  late MockMarkerRepository mockMarkerRepository;
  late MockUserAssetRepository mockUserAssetRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAnimationRepository = MockAnimationRepository();
    mockMarkerRepository = MockMarkerRepository();
    mockUserAssetRepository = MockUserAssetRepository();

    arService = ArService(
      authRepository: mockAuthRepository,
      animationRepository: mockAnimationRepository,
      markerRepository: mockMarkerRepository,
      userAssetRepository: mockUserAssetRepository,
    );
  });

  group('authenticate', () {
    final authToken = AuthToken(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    test('should return AuthToken when authentication is successful', () async {
      when(mockAuthRepository.login(
        username: anyNamed('username'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(authToken));

      final result = await arService.authenticate(
        username: 'user',
        password: 'pass',
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (token) {
          expect(token.accessToken, 'access_token');
        },
      );
    });

    test('should return AuthFailure when authentication fails', () async {
      when(mockAuthRepository.login(
        username: anyNamed('username'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(AuthFailure('Invalid credentials', 401)));

      final result = await arService.authenticate(
        username: 'user',
        password: 'pass',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
        },
        (_) => fail('Should not return success'),
      );
    });
  });

  group('fetchAnimations', () {
    final token = AuthToken(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final animations = [
      AnimationMetadata(
        id: '1',
        name: 'Animation 1',
        description: 'Description',
        fileUrl: 'file.mp4',
        thumbnailUrl: 'thumb.jpg',
        fileSizeInMb: 10.5,
        durationInSeconds: 30,
        tags: const ['tag1'],
        createdAt: DateTime.now(),
      ),
    ];

    test('should return animations when token is valid', () async {
      when(mockAuthRepository.getCachedToken())
          .thenAnswer((_) async => Right(token));
      when(mockAnimationRepository.getAnimations(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => Right(animations));

      final result = await arService.fetchAnimations();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (anims) {
          expect(anims.length, 1);
          expect(anims[0].id, '1');
        },
      );
    });

    test('should refresh token when it is expiring soon', () async {
      final expiringToken = AuthToken(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      );

      final newToken = AuthToken(
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(mockAuthRepository.getCachedToken())
          .thenAnswer((_) async => Right(expiringToken));
      when(mockAuthRepository.refreshToken())
          .thenAnswer((_) async => Right(newToken));
      when(mockAnimationRepository.getAnimations(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => Right(animations));

      final result = await arService.fetchAnimations();

      expect(result.isRight(), true);
      verify(mockAuthRepository.refreshToken()).called(1);
    });
  });

  group('fetchMarkers', () {
    final token = AuthToken(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final markers = [
      const MarkerDefinition(
        id: '1',
        name: 'Marker 1',
        imageUrl: 'marker.jpg',
        width: 10.0,
        height: 10.0,
      ),
    ];

    test('should return markers when token is valid', () async {
      when(mockAuthRepository.getCachedToken())
          .thenAnswer((_) async => Right(token));
      when(mockMarkerRepository.getMarkers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => Right(markers));

      final result = await arService.fetchMarkers();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (mrks) {
          expect(mrks.length, 1);
          expect(mrks[0].id, '1');
        },
      );
    });
  });

  group('fetchUserAssets', () {
    final token = AuthToken(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final assets = [
      UserAsset(
        id: '1',
        userId: 'user1',
        assetType: 'image',
        name: 'Asset 1',
        fileUrl: 'file.jpg',
        fileSizeInMb: 5.0,
        uploadedAt: DateTime.now(),
      ),
    ];

    test('should return user assets when token is valid', () async {
      when(mockAuthRepository.getCachedToken())
          .thenAnswer((_) async => Right(token));
      when(mockUserAssetRepository.getUserAssets(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        assetType: anyNamed('assetType'),
      )).thenAnswer((_) async => Right(assets));

      final result = await arService.fetchUserAssets();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (assts) {
          expect(assts.length, 1);
          expect(assts[0].id, '1');
        },
      );
    });
  });

  group('isAuthenticated', () {
    test('should return true when user is authenticated', () async {
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);

      final result = await arService.isAuthenticated();

      expect(result, true);
    });

    test('should return false when user is not authenticated', () async {
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      final result = await arService.isAuthenticated();

      expect(result, false);
    });
  });

  group('signOut', () {
    test('should successfully sign out', () async {
      when(mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(null));

      final result = await arService.signOut();

      expect(result.isRight(), true);
      verify(mockAuthRepository.logout()).called(1);
    });
  });
}
