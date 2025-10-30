import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../providers/ar_provider.dart';
import '../../widgets/ar_camera_view.dart';
import '../../widgets/ar_error_widgets.dart';
import '../../widgets/loading_indicator.dart';

class ArPage extends ConsumerStatefulWidget {
  const ArPage({super.key});

  @override
  ConsumerState<ArPage> createState() => _ArPageState();
}

class _ArPageState extends ConsumerState<ArPage> 
    with WidgetsBindingObserver, RouteAware {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAr();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final arState = ref.read(arNotifierProvider);
    
    switch (state) {
      case AppLifecycleState.paused:
        if (arState.isActive) {
          ref.read(arNotifierProvider.notifier).pauseSession();
        }
        break;
      case AppLifecycleState.resumed:
        if (arState.isPaused) {
          ref.read(arNotifierProvider.notifier).resumeSession();
        }
        break;
      case AppLifecycleState.detached:
        ref.read(arNotifierProvider.notifier).dispose();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeAr() async {
    if (_isInitialized) return;
    
    try {
      // Check permissions first
      await ref.read(arNotifierProvider.notifier).checkPermissions();
      
      // Wait for permission check to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      final arState = ref.read(arNotifierProvider);
      if (arState is! ArPermissionDenied) {
        // Check device compatibility
        await ref.read(arNotifierProvider.notifier).checkDeviceCompatibility();
        
        // Wait for compatibility check to complete
        await Future.delayed(const Duration(milliseconds: 500));
        
        final compatibilityState = ref.read(arNotifierProvider);
        if (compatibilityState is! ArDeviceUnsupported) {
          // Initialize AR session
          await ref.read(arNotifierProvider.notifier).initializeSession();
          
          // Start the session
          await ref.read(arNotifierProvider.notifier).startSession();
        }
      }
      
      _isInitialized = true;
    } catch (e) {
      // Error is handled by the notifier
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final arState = ref.watch(arNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ar),
        centerTitle: true,
        actions: [
          if (arState.isReady)
            IconButton(
              icon: Icon(
                arState.isActive ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                if (arState.isActive) {
                  ref.read(arNotifierProvider.notifier).pauseSession();
                } else if (arState.isPaused) {
                  ref.read(arNotifierProvider.notifier).resumeSession();
                } else {
                  ref.read(arNotifierProvider.notifier).startSession();
                }
              },
            ),
        ],
      ),
      body: _buildBody(arState, l10n),
    );
  }

  Widget _buildBody(arState, AppLocalizations l10n) {
    if (arState.isLoading) {
      return const LoadingIndicator();
    }

    if (arState is ArPermissionDenied) {
      return ArPermissionDeniedWidget(
        onRequestPermission: () {
          ref.read(arNotifierProvider.notifier).checkPermissions();
        },
      );
    }

    if (arState is ArDeviceUnsupported) {
      return ArDeviceUnsupportedWidget(reason: arState.reason);
    }

    if (arState is ArError) {
      return ArErrorWidget(
        title: 'AR Error',
        message: arState.message,
        onRetry: _initializeAr,
      );
    }

    if (arState is ArSessionReady || arState is ArSessionActive || arState is ArSessionPaused) {
      return _buildArContent(arState, l10n);
    }

    return _buildInitialState(l10n);
  }

  Widget _buildArContent(arState, AppLocalizations l10n) {
    final trackingInfo = arState.trackingInfo;
    final isImageTrackingEnabled = arState.isImageTrackingEnabled;

    return Column(
      children: [
        // AR Camera View
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: ArCameraView(
              trackingInfo: trackingInfo,
              isImageTrackingEnabled: isImageTrackingEnabled,
              onImageTrackingToggle: () {
                ref.read(arNotifierProvider.notifier).toggleImageTracking();
              },
            ),
          ),
        ),
        
        // Control Panel
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                // Status Summary
                _buildStatusSummary(trackingInfo, isImageTrackingEnabled),
                
                SizedBox(height: 16.h),
                
                // Action Buttons
                _buildActionButtons(l10n, arState),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSummary(trackingInfo, bool isImageTrackingEnabled) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Status',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Tracking',
                  trackingInfo.state.name,
                  _getTrackingColor(trackingInfo.state),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatusItem(
                  'Lighting',
                  trackingInfo.lighting.name,
                  _getLightingColor(trackingInfo.lighting),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Confidence',
                  '${(trackingInfo.confidence * 100).toInt()}%',
                  _getConfidenceColor(trackingInfo.confidence),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatusItem(
                  'Image Tracking',
                  isImageTrackingEnabled ? 'On' : 'Off',
                  isImageTrackingEnabled ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getTrackingColor(ArTrackingState state) {
    switch (state) {
      case ArTrackingState.tracking:
        return Colors.green;
      case ArTrackingState.initializing:
        return Colors.orange;
      case ArTrackingState.paused:
        return Colors.yellow;
      case ArTrackingState.stopped:
        return Colors.grey;
      case ArTrackingState.error:
        return Colors.red;
      case ArTrackingState.none:
        return Colors.grey;
    }
  }

  Color _getLightingColor(ArLightingCondition lighting) {
    switch (lighting) {
      case ArLightingCondition.bright:
      case ArLightingCondition.moderate:
        return Colors.green;
      case ArLightingCondition.dark:
        return Colors.orange;
      case ArLightingCondition.tooBright:
        return Colors.red;
      case ArLightingCondition.unknown:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.7) return Colors.green;
    if (confidence > 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActionButtons(AppLocalizations l10n, arState) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: arState.isActive
                ? () => ref.read(arNotifierProvider.notifier).stopSession()
                : () => ref.read(arNotifierProvider.notifier).startSession(),
            icon: Icon(arState.isActive ? Icons.stop : Icons.play_arrow),
            label: Text(arState.isActive ? 'Stop' : 'Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: arState.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(arNotifierProvider.notifier).toggleImageTracking();
            },
            icon: Icon(Icons.image_search),
            label: Text('Image Track'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar,
              size: 80.w,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Initializing AR...',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please wait while we set up your AR experience',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}