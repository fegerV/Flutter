import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return await repository.areNotificationsEnabled();
});

final newAnimationsNotificationsFutureProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return await repository.areNewAnimationsNotificationsEnabled();
});

final arUpdatesNotificationsFutureProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return await repository.areArUpdatesNotificationsEnabled();
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return await repository.isOnboardingCompleted();
});

class NotificationSettingsNotifier extends StateNotifier<bool> {
  final NotificationRepository _repository;

  NotificationSettingsNotifier(this._repository) : super(true);

  Future<void> loadSettings() async {
    state = await _repository.areNotificationsEnabled();
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _repository.setNotificationsEnabled(enabled);
    state = enabled;
  }
}

class NewAnimationsNotificationsNotifier extends StateNotifier<bool> {
  final NotificationRepository _repository;

  NewAnimationsNotificationsNotifier(this._repository) : super(true);

  Future<void> loadSettings() async {
    state = await _repository.areNewAnimationsNotificationsEnabled();
  }

  Future<void> toggleNewAnimationsNotifications(bool enabled) async {
    await _repository.setNewAnimationsNotificationsEnabled(enabled);
    state = enabled;
  }
}

class ArUpdatesNotificationsNotifier extends StateNotifier<bool> {
  final NotificationRepository _repository;

  ArUpdatesNotificationsNotifier(this._repository) : super(true);

  Future<void> loadSettings() async {
    state = await _repository.areArUpdatesNotificationsEnabled();
  }

  Future<void> toggleArUpdatesNotifications(bool enabled) async {
    await _repository.setArUpdatesNotificationsEnabled(enabled);
    state = enabled;
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, bool>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  final notifier = NotificationSettingsNotifier(repository);
  notifier.loadSettings();
  return notifier;
});

final newAnimationsNotificationsProvider = StateNotifierProvider<NewAnimationsNotificationsNotifier, bool>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  final notifier = NewAnimationsNotificationsNotifier(repository);
  notifier.loadSettings();
  return notifier;
});

final arUpdatesNotificationsProvider = StateNotifierProvider<ArUpdatesNotificationsNotifier, bool>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  final notifier = ArUpdatesNotificationsNotifier(repository);
  notifier.loadSettings();
  return notifier;
});