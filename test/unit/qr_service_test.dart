import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_ar_app/data/services/qr_service.dart';
import 'package:flutter_ar_app/domain/entities/qr_code.dart';

import 'qr_service_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group('QRService', () {
    late QRService qrService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      qrService = QRService();
    });

    setUpAll(() async {
      // Initialize QRService with mock
      SharedPreferences.setMockInitialValues({});
      await qrService.initialize();
    });

    group('parseQRCode', () {
      test('should parse JSON QR code with animation ID', () async {
        // Arrange
        const rawValue = '{"animation_id": "test_anim_123", "type": "animation"}';

        // Act
        final result = await qrService.parseQRCode(rawValue);

        // Assert
        expect(result.rawValue, rawValue);
        expect(result.animationId, 'test_anim_123');
        expect(result.type, 'animation');
        expect(result.isValidAnimationQR, isTrue);
      });

      test('should parse simple animation ID', () async {
        // Arrange
        const rawValue = 'anim_123';

        // Act
        final result = await qrService.parseQRCode(rawValue);

        // Assert
        expect(result.rawValue, rawValue);
        expect(result.animationId, 'anim_123');
        expect(result.type, 'animation');
        expect(result.isValidAnimationQR, isTrue);
      });

      test('should parse URL with animation ID', () async {
        // Arrange
        const rawValue = 'https://example.com/animation/anim_456';

        // Act
        final result = await qrService.parseQRCode(rawValue);

        // Assert
        expect(result.rawValue, rawValue);
        expect(result.animationId, 'anim_456');
        expect(result.type, 'animation');
        expect(result.isValidAnimationQR, isTrue);
      });

      test('should return invalid QR code for invalid content', () async {
        // Arrange
        const rawValue = 'invalid content';

        // Act
        final result = await qrService.parseQRCode(rawValue);

        // Assert
        expect(result.rawValue, rawValue);
        expect(result.animationId, isNull);
        expect(result.type, 'unknown');
        expect(result.isValidAnimationQR, isFalse);
        expect(result.metadata?['parse_error'], isTrue);
      });

      test('should parse JSON without animation ID', () async {
        // Arrange
        const rawValue = '{"type": "other", "data": "test"}';

        // Act
        final result = await qrService.parseQRCode(rawValue);

        // Assert
        expect(result.rawValue, rawValue);
        expect(result.animationId, isNull);
        expect(result.type, 'other');
        expect(result.isValidAnimationQR, isFalse);
      });
    });

    group('saveQRCode and getScanHistory', () {
      test('should save and retrieve QR code history', () async {
        // Arrange
        final qrCode = QRCode(
          rawValue: 'test_anim_123',
          animationId: 'test_anim_123',
          type: 'animation',
          scannedAt: DateTime.now(),
        );

        // Act
        await qrService.saveQRCode(qrCode);
        final history = await qrService.getScanHistory();

        // Assert
        expect(history, isNotEmpty);
        expect(history.last.rawValue, qrCode.rawValue);
        expect(history.last.animationId, qrCode.animationId);
        expect(history.last.type, qrCode.type);
      });

      test('should limit history to 100 items', () async {
        // Arrange
        final qrCodes = List.generate(105, (index) => QRCode(
          rawValue: 'test_$index',
          animationId: 'test_$index',
          type: 'animation',
          scannedAt: DateTime.now(),
        ));

        // Act
        for (final qrCode in qrCodes) {
          await qrService.saveQRCode(qrCode);
        }
        final history = await qrService.getScanHistory();

        // Assert
        expect(history.length, 100);
        expect(history.last.rawValue, 'test_104');
      });

      test('should clear scan history', () async {
        // Arrange
        final qrCode = QRCode(
          rawValue: 'test_anim_123',
          animationId: 'test_anim_123',
          type: 'animation',
          scannedAt: DateTime.now(),
        );
        await qrService.saveQRCode(qrCode);

        // Act
        await qrService.clearScanHistory();
        final history = await qrService.getScanHistory();

        // Assert
        expect(history, isEmpty);
      });
    });
  });
}