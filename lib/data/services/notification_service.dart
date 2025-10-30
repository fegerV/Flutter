import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../repositories/notification_repository.dart';

@singleton
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationRepository _notificationRepository;
  final Ref _ref;
  
  StreamSubscription<Uri>? _deepLinkSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  
  NotificationService(this._notificationRepository, this._ref);

  Future<void> initialize() async {
    try {
      // Request permission for iOS
      await _requestPermission();
      
      // Get initial message if app was opened from notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
      
      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle messages when app is in background but opened
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Initialize deep link handling
      await _initializeDeepLinks();
      
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _notificationRepository.saveFCMToken(token);
        debugPrint('FCM Token: $token');
      }
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _notificationRepository.saveFCMToken(token);
      });
      
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> requestNotificationPermission() async {
    if (Platform.isIOS) {
      await _requestPermission();
    } else {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        await _requestPermission();
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // Show a dialog or in-app notification
    _showInAppNotification(message);
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Handling message: ${message.messageId}');
    
    // Navigate based on message data
    _navigateFromMessage(message);
  }

  void _showInAppNotification(RemoteMessage message) {
    final context = _ref.read(appRouterProvider).routerDelegate.navigatorKey.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? 'New Notification';
    final body = message.notification?.body ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateFromMessage(message);
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  void _navigateFromMessage(RemoteMessage message) {
    final router = _ref.read(appRouterProvider);
    
    // Navigate based on message data
    final messageType = message.data['type'];
    final contentId = message.data['contentId'];
    
    switch (messageType) {
      case 'new_animation':
        router.go('/media?animation=$contentId');
        break;
      case 'ar_update':
        router.go('/ar');
        break;
      case 'general':
      default:
        router.go('/home');
        break;
    }
  }

  Future<void> _initializeDeepLinks() async {
    try {
      // Handle initial deep link
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(Uri.parse(initialLink));
      }

      // Handle subsequent deep links
      _deepLinkSubscription = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      });
    } catch (e) {
      debugPrint('Error initializing deep links: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Handling deep link: $uri');
    
    final router = _ref.read(appRouterProvider);
    
    switch (uri.path) {
      case '/ar':
        router.go('/ar');
        break;
      case '/media':
        final animationId = uri.queryParameters['animation'];
        if (animationId != null) {
          router.go('/media?animation=$animationId');
        } else {
          router.go('/media');
        }
        break;
      case '/settings':
        router.go('/settings');
        break;
      default:
        router.go('/home');
        break;
    }
  }

  Future<void> sendTestNotification() async {
    // This would typically be called from a backend service
    // For testing purposes, we'll create a local notification
    final router = _ref.read(appRouterProvider);
    final context = router.routerDelegate.navigatorKey.currentContext;
    
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void dispose() {
    _deepLinkSubscription?.cancel();
    _messageSubscription?.cancel();
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}