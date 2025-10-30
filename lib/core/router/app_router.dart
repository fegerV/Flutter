import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/ar/ar_page.dart';
import '../../presentation/pages/media/media_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/onboarding/ar_onboarding_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/qr/qr_scanner_page.dart';
import '../../presentation/pages/qr/qr_history_page.dart';
import '../../presentation/pages/cache/cache_management_page.dart';
import '../../presentation/widgets/navigation_shell.dart';
import '../../data/repositories/notification_repository.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter(ref);
});

GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashPage(
          onRoutingComplete: () async {
            final repository = NotificationRepository();
            final onboardingCompleted = await repository.isOnboardingCompleted();
            
            if (!onboardingCompleted) {
              context.go('/ar-onboarding');
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/ar-onboarding',
        builder: (context, state) => const AROnboardingPage(),
      ),
      GoRoute(
        path: '/qr/scanner',
        builder: (context, state) => const QRScannerPage(),
      ),
      GoRoute(
        path: '/qr/history',
        builder: (context, state) => const QRHistoryPage(),
      ),
      GoRoute(
        path: '/cache/management',
        builder: (context, state) => const CacheManagementPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return NavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/ar',
            builder: (context, state) {
              final animationId = state.extra as Map<String, String>?;
              return ArPage(animationId: animationId?['animationId']);
            },
          ),
          GoRoute(
            path: '/media',
            builder: (context, state) {
              final animationId = state.uri.queryParameters['animation'];
              return MediaPage(animationId: animationId);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
