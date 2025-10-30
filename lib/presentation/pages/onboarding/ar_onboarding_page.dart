import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../providers/notification_provider.dart';

class AROnboardingPage extends ConsumerStatefulWidget {
  const AROnboardingPage({super.key});

  @override
  ConsumerState<AROnboardingPage> createState() => _AROnboardingPageState();
}

class _AROnboardingPageState extends ConsumerState<AROnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _nextPage();
    } else {
      _showPermissionDialog('camera');
    }
  }

  Future<void> _requestNotificationPermission() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.requestNotificationPermission();
    _nextPage();
  }

  void _showPermissionDialog(String permissionType) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(permissionType == 'camera' 
            ? l10n.cameraPermission 
            : l10n.notificationPermissionRequired),
        content: Text(permissionType == 'camera'
            ? l10n.cameraPermissionRationale
            : l10n.notificationPermissionRationale),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.grantPermission),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.setOnboardingCompleted(true);
    
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return _buildLayout(orientation, l10n);
        },
      ),
    );
  }

  Widget _buildLayout(Orientation orientation, AppLocalizations l10n) {
    if (orientation == Orientation.landscape) {
      return _buildLandscapeLayout(l10n);
    } else {
      return _buildPortraitLayout(l10n);
    }
  }

  Widget _buildPortraitLayout(AppLocalizations l10n) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              itemCount: _onboardingItems.length,
              itemBuilder: (context, index) {
                return _buildPortraitOnboardingItem(_onboardingItems[index], l10n);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildNavigationControls(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(AppLocalizations l10n) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              itemCount: _onboardingItems.length,
              itemBuilder: (context, index) {
                return _buildLandscapeOnboardingItem(_onboardingItems[index], l10n);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPageIndicator(),
                  SizedBox(height: 32.h),
                  _buildNavigationButtons(l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitOnboardingItem(OnboardingItem item, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.lottieAsset != null)
              Lottie.asset(
                item.lottieAsset!,
                width: 200.w,
                height: 200.h,
                fit: BoxFit.contain,
              )
            else
              Icon(
                item.icon,
                size: 120.w,
                color: Theme.of(context).primaryColor,
              ),
            SizedBox(height: 32.h),
            Text(
              item.getTitle(l10n),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              item.getDescription(l10n),
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (item.features.isNotEmpty) ...[
              SizedBox(height: 24.h),
              ...item.features.map((feature) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20.w,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        feature(l10n),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            if (item.safetyTips.isNotEmpty) ...[
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.safetyTips,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...item.safetyTips.map((tip) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 16.w,
                            color: Colors.orange.shade600,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              tip(l10n),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
            if (item.requiresPermission) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: item.permissionType == 'camera'
                    ? _requestCameraPermission
                    : _requestNotificationPermission,
                icon: Icon(item.permissionType == 'camera' 
                    ? Icons.camera_alt 
                    : Icons.notifications),
                label: Text(item.permissionType == 'camera'
                    ? l10n.grantCameraPermission
                    : l10n.grantNotificationPermission),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeOnboardingItem(OnboardingItem item, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.lottieAsset != null)
              Lottie.asset(
                item.lottieAsset!,
                width: 150.w,
                height: 150.h,
                fit: BoxFit.contain,
              )
            else
              Icon(
                item.icon,
                size: 80.w,
                color: Theme.of(context).primaryColor,
              ),
            SizedBox(height: 24.h),
            Text(
              item.getTitle(l10n),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              item.getDescription(l10n),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageIndicator(),
          SizedBox(height: 32.h),
          _buildNavigationButtons(l10n),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _onboardingItems.asMap().entries.map((entry) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentPage == entry.key ? 24.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == entry.key
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons(AppLocalizations l10n) {
    final currentItem = _onboardingItems[_currentPage];
    
    if (currentItem.requiresPermission) {
      return const SizedBox.shrink(); // Permission button is in the content
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentPage > 0)
          TextButton(
            onPressed: _previousPage,
            child: Text(l10n.skip),
          ),
        if (_currentPage > 0) SizedBox(width: 16.w),
        ElevatedButton(
          onPressed: _nextPage,
          child: Text(_currentPage == _onboardingItems.length - 1 
              ? l10n.finish 
              : l10n.next),
        ),
      ],
    );
  }
}

class OnboardingItem {
  final IconData? icon;
  final String? lottieAsset;
  final String titleKey;
  final String descriptionKey;
  final List<AppLocalizations Function(AppLocalizations)> features;
  final List<AppLocalizations Function(AppLocalizations)> safetyTips;
  final bool requiresPermission;
  final String permissionType;

  OnboardingItem({
    this.icon,
    this.lottieAsset,
    required this.titleKey,
    required this.descriptionKey,
    this.features = const [],
    this.safetyTips = const [],
    this.requiresPermission = false,
    this.permissionType = '',
  });

  String getTitle(AppLocalizations l10n) {
    switch (titleKey) {
      case 'onboardingWelcome':
        return l10n.onboardingWelcome;
      case 'onboardingPermissions':
        return l10n.onboardingPermissions;
      case 'onboardingSafety':
        return l10n.onboardingSafety;
      case 'onboardingGetStarted':
        return l10n.onboardingGetStarted;
      default:
        return titleKey;
    }
  }

  String getDescription(AppLocalizations l10n) {
    switch (descriptionKey) {
      case 'onboardingWelcomeDesc':
        return l10n.onboardingWelcomeDesc;
      case 'onboardingPermissionsDesc':
        return l10n.onboardingPermissionsDesc;
      case 'onboardingSafetyDesc':
        return l10n.onboardingSafetyDesc;
      case 'onboardingGetStartedDesc':
        return l10n.onboardingGetStartedDesc;
      default:
        return descriptionKey;
    }
  }
}

final List<OnboardingItem> _onboardingItems = [
  OnboardingItem(
    icon: Icons.view_in_ar,
    titleKey: 'onboardingWelcome',
    descriptionKey: 'onboardingWelcomeDesc',
    features: [
      (l10n) => l10n.arFeature1,
      (l10n) => l10n.arFeature2,
      (l10n) => l10n.arFeature3,
      (l10n) => l10n.arFeature4,
    ],
  ),
  OnboardingItem(
    icon: Icons.camera_alt,
    titleKey: 'onboardingPermissions',
    descriptionKey: 'onboardingPermissionsDesc',
    requiresPermission: true,
    permissionType: 'camera',
  ),
  OnboardingItem(
    icon: Icons.notifications,
    titleKey: 'notifications',
    descriptionKey: 'notificationPermissionRationale',
    requiresPermission: true,
    permissionType: 'notification',
  ),
  OnboardingItem(
    icon: Icons.security,
    titleKey: 'onboardingSafety',
    descriptionKey: 'onboardingSafetyDesc',
    safetyTips: [
      (l10n) => l10n.safetyTip1,
      (l10n) => l10n.safetyTip2,
      (l10n) => l10n.safetyTip3,
      (l10n) => l10n.safetyTip4,
    ],
  ),
  OnboardingItem(
    icon: Icons.rocket_launch,
    titleKey: 'onboardingGetStarted',
    descriptionKey: 'onboardingGetStartedDesc',
  ),
];