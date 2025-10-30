import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../lib/core/l10n/app_localizations.dart';
import '../../lib/presentation/pages/onboarding/ar_onboarding_page.dart';

void main() {
  group('AR Onboarding Page Localization Tests', () {
    late ProviderContainer container;
    late AppLocalizations enL10n;
    late AppLocalizations ruL10n;

    setUpAll(() async {
      // Initialize Flutter bindings
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize ScreenUtil
      await ScreenUtil.ensureScreenSize();
      
      // Setup localization
      enL10n = await AppLocalizations.delegate.load(const Locale('en', ''));
      ruL10n = await AppLocalizations.delegate.load(const Locale('ru', ''));
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('English localization displays correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
            ],
            home: const AROnboardingPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check welcome screen
      expect(find.text(enL10n.onboardingWelcome), findsOneWidget);
      expect(find.text(enL10n.onboardingWelcomeDesc), findsOneWidget);
      
      // Check AR features
      expect(find.text(enL10n.arFeature1), findsOneWidget);
      expect(find.text(enL10n.arFeature2), findsOneWidget);
      expect(find.text(enL10n.arFeature3), findsOneWidget);
      expect(find.text(enL10n.arFeature4), findsOneWidget);
    });

    testWidgets('Russian localization displays correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            locale: const Locale('ru', ''),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
            ],
            home: const AROnboardingPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check welcome screen in Russian
      expect(find.text(ruL10n.onboardingWelcome), findsOneWidget);
      expect(find.text(ruL10n.onboardingWelcomeDesc), findsOneWidget);
      
      // Check AR features in Russian
      expect(find.text(ruL10n.arFeature1), findsOneWidget);
      expect(find.text(ruL10n.arFeature2), findsOneWidget);
      expect(find.text(ruL10n.arFeature3), findsOneWidget);
      expect(find.text(ruL10n.arFeature4), findsOneWidget);
    });

    testWidgets('Permission screens display correct localized text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
            ],
            home: const AROnboardingPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to permissions screen
      final nextButton = find.text('Next');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Check permission screen text
      expect(find.text(enL10n.onboardingPermissions), findsOneWidget);
      expect(find.text(enL10n.onboardingPermissionsDesc), findsOneWidget);
      expect(find.text(enL10n.grantCameraPermission), findsOneWidget);
    });

    testWidgets('Safety tips screen displays correct localized text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
            ],
            home: const AROnboardingPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate through screens to safety tips
      for (int i = 0; i < 3; i++) {
        final nextButton = find.text('Next');
        expect(nextButton, findsOneWidget);
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }

      // Check safety tips text
      expect(find.text(enL10n.onboardingSafety), findsOneWidget);
      expect(find.text(enL10n.onboardingSafetyDesc), findsOneWidget);
      expect(find.text(enL10n.safetyTips), findsOneWidget);
      expect(find.text(enL10n.safetyTip1), findsOneWidget);
      expect(find.text(enL10n.safetyTip2), findsOneWidget);
      expect(find.text(enL10n.safetyTip3), findsOneWidget);
      expect(find.text(enL10n.safetyTip4), findsOneWidget);
    });

    testWidgets('Navigation controls display correct localized text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
            ],
            home: const AROnboardingPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that navigation buttons have correct text
      expect(find.text(enL10n.next), findsOneWidget);
      
      // Navigate to last page
      for (int i = 0; i < 4; i++) {
        final nextButton = find.text('Next');
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
        }
      }

      // Check finish button
      expect(find.text(enL10n.finish), findsOneWidget);
    });
  });

  group('Localization Content Validation', () {
    test('All English localization keys exist', () {
      final requiredKeys = [
        'onboardingWelcome',
        'onboardingWelcomeDesc',
        'onboardingPermissions',
        'onboardingPermissionsDesc',
        'onboardingSafety',
        'onboardingSafetyDesc',
        'onboardingGetStarted',
        'onboardingGetStartedDesc',
        'grantCameraPermission',
        'cameraPermissionRationale',
        'safetyTips',
        'safetyTip1',
        'safetyTip2',
        'safetyTip3',
        'safetyTip4',
        'arFeatures',
        'arFeature1',
        'arFeature2',
        'arFeature3',
        'arFeature4',
      ];

      // This test ensures all required keys are present in the localization file
      for (final key in requiredKeys) {
        expect(enL10n.toString().contains(key), true, reason: 'Missing key: $key');
      }
    });

    test('All Russian localization keys exist', () {
      final requiredKeys = [
        'onboardingWelcome',
        'onboardingWelcomeDesc',
        'onboardingPermissions',
        'onboardingPermissionsDesc',
        'onboardingSafety',
        'onboardingSafetyDesc',
        'onboardingGetStarted',
        'onboardingGetStartedDesc',
        'grantCameraPermission',
        'cameraPermissionRationale',
        'safetyTips',
        'safetyTip1',
        'safetyTip2',
        'safetyTip3',
        'safetyTip4',
        'arFeatures',
        'arFeature1',
        'arFeature2',
        'arFeature3',
        'arFeature4',
      ];

      // This test ensures all required keys are present in the Russian localization file
      for (final key in requiredKeys) {
        expect(ruL10n.toString().contains(key), true, reason: 'Missing key: $key');
      }
    });
  });
}