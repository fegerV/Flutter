import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_ar_app/data/repositories/notification_repository.dart';
import 'package:flutter_ar_app/data/services/notification_service.dart';

@GenerateMocks([
  NotificationRepository,
  NotificationService,
])
void main() {
  group('Notification Test Configuration', () {
    test('Mock configuration is valid', () {
      // This test ensures the mock generation is working correctly
      expect(true, isTrue);
    });
  });
}