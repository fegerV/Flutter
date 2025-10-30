import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_ar_app/domain/usecases/scan_qr_code_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/get_cache_info_usecase.dart';
import 'package:flutter_ar_app/domain/usecases/clear_cache_usecase.dart';
import 'package:flutter_ar_app/domain/repositories/qr_repository.dart';
import 'package:flutter_ar_app/domain/repositories/cache_repository.dart';
import 'package:flutter_ar_app/domain/entities/qr_code.dart';
import 'package:flutter_ar_app/domain/entities/cache_info.dart';

import 'usecases_test.mocks.dart';

@GenerateMocks([QRRepository, CacheRepository])
void main() {
  group('Use Cases', () {
    group('ScanQRCodeUseCase', () {
      late ScanQRCodeUseCase useCase;
      late MockQRRepository mockRepository;

      setUp(() {
        mockRepository = MockQRRepository();
        useCase = ScanQRCodeUseCase(mockRepository);
      });

      test('should scan QR code successfully', () async {
        // Arrange
        const rawValue = 'test_anim_123';
        final expectedQRCode = QRCode(
          rawValue: rawValue,
          animationId: 'test_anim_123',
          type: 'animation',
          scannedAt: DateTime.now(),
        );

        when(mockRepository.scanQRCode(rawValue))
            .thenAnswer((_) async => expectedQRCode);

        // Act
        final result = await useCase(const ScanQRCodeParams(rawValue));

        // Assert
        expect(result, expectedQRCode);
        verify(mockRepository.scanQRCode(rawValue)).called(1);
      });

      test('should handle scan error', () async {
        // Arrange
        const rawValue = 'invalid_qr';
        when(mockRepository.scanQRCode(rawValue))
            .thenThrow(Exception('Invalid QR code'));

        // Act & Assert
        expect(
          () async => await useCase(const ScanQRCodeParams(rawValue)),
          throwsException,
        );
        verify(mockRepository.scanQRCode(rawValue)).called(1);
      });
    });

    group('GetCacheInfoUseCase', () {
      late GetCacheInfoUseCase useCase;
      late MockCacheRepository mockRepository;

      setUp(() {
        mockRepository = MockCacheRepository();
        useCase = GetCacheInfoUseCase(mockRepository);
      });

      test('should get cache info successfully', () async {
        // Arrange
        final expectedCacheInfo = CacheInfo(
          totalSize: 100000000, // 100MB
          usedSize: 50000000, // 50MB
          itemCount: 10,
          lastCleanup: DateTime.now(),
          maxSizeLimit: 500000000, // 500MB
          ttl: const Duration(days: 7),
        );

        when(mockRepository.getCacheInfo())
            .thenAnswer((_) async => expectedCacheInfo);

        // Act
        final result = await useCase(const GetCacheInfoParams());

        // Assert
        expect(result, expectedCacheInfo);
        verify(mockRepository.getCacheInfo()).called(1);
      });

      test('should handle get cache info error', () async {
        // Arrange
        when(mockRepository.getCacheInfo())
            .thenThrow(Exception('Cache error'));

        // Act & Assert
        expect(
          () async => await useCase(const GetCacheInfoParams()),
          throwsException,
        );
        verify(mockRepository.getCacheInfo()).called(1);
      });
    });

    group('ClearCacheUseCase', () {
      late ClearCacheUseCase useCase;
      late MockCacheRepository mockRepository;

      setUp(() {
        mockRepository = MockCacheRepository();
        useCase = ClearCacheUseCase(mockRepository);
      });

      test('should clear all cache successfully', () async {
        // Arrange
        when(mockRepository.clearCache(animationId: null))
            .thenAnswer((_) async {});

        // Act
        await useCase(const ClearCacheParams(clearAll: true));

        // Assert
        verify(mockRepository.clearCache(animationId: null)).called(1);
      });

      test('should clear specific animation cache successfully', () async {
        // Arrange
        const animationId = 'test_anim_123';
        when(mockRepository.clearCache(animationId: animationId))
            .thenAnswer((_) async {});

        // Act
        await useCase(ClearCacheParams(animationId: animationId));

        // Assert
        verify(mockRepository.clearCache(animationId: animationId)).called(1);
      });

      test('should handle clear cache error', () async {
        // Arrange
        const animationId = 'test_anim_123';
        when(mockRepository.clearCache(animationId: animationId))
            .thenThrow(Exception('Clear cache error'));

        // Act & Assert
        expect(
          () async => await useCase(ClearCacheParams(animationId: animationId)),
          throwsException,
        );
        verify(mockRepository.clearCache(animationId: animationId)).called(1);
      });
    });
  });
}