import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/data/repositories/notification_repository.dart';
import '../../lib/data/services/notification_service.dart';
import '../../lib/presentation/providers/notification_provider.dart';
import '../../lib/core/l10n/app_localizations.dart';

import 'notification_flow_test.mocks.dart';

@GenerateMocks([NotificationRepository, NotificationService])
void main() {
  group('Notification Flow Tests', () {
    late MockNotificationRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockNotificationRepository();
      container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Notification Settings Management', () {
      test('should toggle notifications enabled state', () async {
        // Arrange
        when(mockRepository.areNotificationsEnabled())
            .thenAnswer((_) async => true);
        when(mockRepository.setNotificationsEnabled(any))
            .thenAnswer((_) async {});

        // Act
        final notifier = container.read(notificationSettingsProvider.notifier);
        await notifier.toggleNotifications(false);

        // Assert
        verify(mockRepository.setNotificationsEnabled(false)).called(1);
      });

      test('should toggle new animations notifications', () async {
        // Arrange
        when(mockRepository.areNewAnimationsNotificationsEnabled())
            .thenAnswer((_) async => true);
        when(mockRepository.setNewAnimationsNotificationsEnabled(any))
            .thenAnswer((_) async {});

        // Act
        final notifier = container.read(newAnimationsNotificationsProvider.notifier);
        await notifier.toggleNewAnimationsNotifications(false);

        // Assert
        verify(mockRepository.setNewAnimationsNotificationsEnabled(false)).called(1);
      });

      test('should toggle AR updates notifications', () async {
        // Arrange
        when(mockRepository.areArUpdatesNotificationsEnabled())
            .thenAnswer((_) async => true);
        when(mockRepository.setArUpdatesNotificationsEnabled(any))
            .thenAnswer((_) async {});

        // Act
        final notifier = container.read(arUpdatesNotificationsProvider.notifier);
        await notifier.toggleArUpdatesNotifications(false);

        // Assert
        verify(mockRepository.setArUpdatesNotificationsEnabled(false)).called(1);
      });
    });

    group('Onboarding State Management', () {
      test('should mark onboarding as completed', () async {
        // Arrange
        when(mockRepository.setOnboardingCompleted(true))
            .thenAnswer((_) async {});

        // Act
        await mockRepository.setOnboardingCompleted(true);

        // Assert
        verify(mockRepository.setOnboardingCompleted(true)).called(1);
      });

      test('should check if onboarding is completed', () async {
        // Arrange
        when(mockRepository.isOnboardingCompleted())
            .thenAnswer((_) async => true);

        // Act
        final isCompleted = await mockRepository.isOnboardingCompleted();

        // Assert
        expect(isCompleted, true);
        verify(mockRepository.isOnboardingCompleted()).called(1);
      });

      test('should reset onboarding state', () async {
        // Arrange
        when(mockRepository.resetOnboarding())
            .thenAnswer((_) async {});

        // Act
        await mockRepository.resetOnboarding();

        // Assert
        verify(mockRepository.resetOnboarding()).called(1);
      });
    });

    group('FCM Token Management', () {
      test('should save FCM token', () async {
        // Arrange
        const testToken = 'test_fcm_token_12345';
        when(mockRepository.saveFCMToken(testToken))
            .thenAnswer((_) async {});

        // Act
        await mockRepository.saveFCMToken(testToken);

        // Assert
        verify(mockRepository.saveFCMToken(testToken)).called(1);
      });

      test('should retrieve FCM token', () async {
        // Arrange
        const testToken = 'test_fcm_token_12345';
        when(mockRepository.getFCMToken())
            .thenAnswer((_) async => testToken);

        // Act
        final token = await mockRepository.getFCMToken();

        // Assert
        expect(token, testToken);
        verify(mockRepository.getFCMToken()).called(1);
      });
    });

    group('Notification Provider States', () {
      test('notificationsEnabledProvider should return correct value', () async {
        // Arrange
        when(mockRepository.areNotificationsEnabled())
            .thenAnswer((_) async => true);

        // Act
        final result = await container.read(notificationsEnabledProvider.future);

        // Assert
        expect(result, true);
        verify(mockRepository.areNotificationsEnabled()).called(1);
      });

      test('newAnimationsNotificationsFutureProvider should return correct value', () async {
        // Arrange
        when(mockRepository.areNewAnimationsNotificationsEnabled())
            .thenAnswer((_) async => false);

        // Act
        final result = await container.read(newAnimationsNotificationsFutureProvider.future);

        // Assert
        expect(result, false);
        verify(mockRepository.areNewAnimationsNotificationsEnabled()).called(1);
      });

      test('arUpdatesNotificationsFutureProvider should return correct value', () async {
        // Arrange
        when(mockRepository.areArUpdatesNotificationsEnabled())
            .thenAnswer((_) async => true);

        // Act
        final result = await container.read(arUpdatesNotificationsFutureProvider.future);

        // Assert
        expect(result, true);
        verify(mockRepository.areArUpdatesNotificationsEnabled()).called(1);
      });

      test('onboardingCompletedProvider should return correct value', () async {
        // Arrange
        when(mockRepository.isOnboardingCompleted())
            .thenAnswer((_) async => false);

        // Act
        final result = await container.read(onboardingCompletedProvider.future);

        // Assert
        expect(result, false);
        verify(mockRepository.isOnboardingCompleted()).called(1);
      });
    });
  });

  group('Notification Content Tests', () {
    late AppLocalizations enL10n;
    late AppLocalizations ruL10n;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      enL10n = await AppLocalizations.delegate.load(const Locale('en', ''));
      ruL10n = await AppLocalizations.delegate.load(const Locale('ru', ''));
    });

    test('English notification strings should be non-empty', () {
      expect(enL10n.notifications.isNotEmpty, true);
      expect(enL10n.notificationSettings.isNotEmpty, true);
      expect(enL10n.enableNotifications.isNotEmpty, true);
      expect(enL10n.newAnimationsNotification.isNotEmpty, true);
      expect(enL10n.newAnimationsNotificationDesc.isNotEmpty, true);
      expect(enL10n.arUpdatesNotification.isNotEmpty, true);
      expect(enL10n.arUpdatesNotificationDesc.isNotEmpty, true);
      expect(enL10n.notificationNewAnimation.isNotEmpty, true);
      expect(enL10n.notificationNewAnimationBody.isNotEmpty, true);
      expect(enL10n.notificationArUpdate.isNotEmpty, true);
      expect(enL10n.notificationArUpdateBody.isNotEmpty, true);
      expect(enL10n.notificationOpenApp.isNotEmpty, true);
      expect(enL10n.notificationViewContent.isNotEmpty, true);
    });

    test('Russian notification strings should be non-empty', () {
      expect(ruL10n.notifications.isNotEmpty, true);
      expect(ruL10n.notificationSettings.isNotEmpty, true);
      expect(ruL10n.enableNotifications.isNotEmpty, true);
      expect(ruL10n.newAnimationsNotification.isNotEmpty, true);
      expect(ruL10n.newAnimationsNotificationDesc.isNotEmpty, true);
      expect(ruL10n.arUpdatesNotification.isNotEmpty, true);
      expect(ruL10n.arUpdatesNotificationDesc.isNotEmpty, true);
      expect(ruL10n.notificationNewAnimation.isNotEmpty, true);
      expect(ruL10n.notificationNewAnimationBody.isNotEmpty, true);
      expect(ruL10n.notificationArUpdate.isNotEmpty, true);
      expect(ruL10n.notificationArUpdateBody.isNotEmpty, true);
      expect(ruL10n.notificationOpenApp.isNotEmpty, true);
      expect(ruL10n.notificationViewContent.isNotEmpty, true);
    });

    test('Onboarding strings should be non-empty in both languages', () {
      // English
      expect(enL10n.onboardingSettings.isNotEmpty, true);
      expect(enL10n.replayOnboarding.isNotEmpty, true);
      expect(enL10n.replayOnboardingDesc.isNotEmpty, true);
      expect(enL10n.resetOnboarding.isNotEmpty, true);
      expect(enL10n.resetOnboardingDesc.isNotEmpty, true);

      // Russian
      expect(ruL10n.onboardingSettings.isNotEmpty, true);
      expect(ruL10n.replayOnboarding.isNotEmpty, true);
      expect(ruL10n.replayOnboardingDesc.isNotEmpty, true);
      expect(ruL10n.resetOnboarding.isNotEmpty, true);
      expect(ruL10n.resetOnboardingDesc.isNotEmpty, true);
    });
  });
}