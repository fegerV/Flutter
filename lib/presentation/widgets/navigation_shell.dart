import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

class NavigationShell extends ConsumerWidget {
  final Widget child;

  const NavigationShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).location;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(location),
        onTap: (index) {
          _navigateToIndex(context, index);
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.view_in_ar),
            label: l10n.ar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.photo_library),
            label: l10n.media,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/ar':
        return 1;
      case '/media':
        return 2;
      case '/settings':
        return 3;
      default:
        return 0;
    }
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/ar');
        break;
      case 2:
        context.go('/media');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
