import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/config/app_config.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as custom;
import 'ar_marker_video_page.dart';

class ArPage extends ConsumerStatefulWidget {
  const ArPage({super.key});

  @override
  ConsumerState<ArPage> createState() => _ArPageState();
}

class _ArPageState extends ConsumerState<ArPage> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cameraStatus = await Permission.camera.status;
      
      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          setState(() {
            _errorMessage = 'Camera permission is required for AR features';
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check permissions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ar),
        centerTitle: true,
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return custom.ErrorWidget(
        message: _errorMessage!,
        onRetry: _checkPermissions,
      );
    }

    if (!AppConfig.enableArFeatures) {
      return _buildDisabledFeature(l10n);
    }

    return _buildArContent(l10n);
  }

  Widget _buildDisabledFeature(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80.w,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.arNotSupported,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.arNotSupportedMessage,
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

  Widget _buildArContent(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.view_in_ar,
                          size: 80.w,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'AR View',
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'AR functionality will be implemented here',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ARMarkerVideoPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.video_library),
                  label: const Text('Marker Videos'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AR settings coming soon')),
                    );
                  },
                  icon: const Icon(Icons.tune),
                  label: const Text('Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
