import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/ar_entities.dart';

class ArErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ArErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80.w,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ArPermissionDeniedWidget extends StatelessWidget {
  final VoidCallback onRequestPermission;

  const ArPermissionDeniedWidget({
    super.key,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return ArErrorWidget(
      title: 'Camera Permission Required',
      message: 'Camera permission is required for AR features. Please grant permission to continue.',
      icon: Icons.camera_alt_outlined,
      onRetry: onRequestPermission,
    );
  }
}

class ArDeviceUnsupportedWidget extends StatelessWidget {
  final String reason;

  const ArDeviceUnsupportedWidget({
    super.key,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return ArErrorWidget(
      title: 'Device Not Supported',
      message: reason,
      icon: Icons.block,
    );
  }
}

class ArCalibrationWidget extends StatelessWidget {
  final VoidCallback? onCalibrationComplete;

  const ArCalibrationWidget({
    super.key,
    this.onCalibrationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.center_focus_strong,
            size: 60.w,
            color: Colors.white,
          ),
          SizedBox(height: 16.h),
          Text(
            'Calibrating Camera',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Move your device slowly in different directions to calibrate the camera for better tracking.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          if (onCalibrationComplete != null)
            ElevatedButton(
              onPressed: onCalibrationComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: const Text('Calibration Complete'),
            ),
        ],
      ),
    );
  }
}