import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ar_entities.dart';
import '../../core/services/ar_energy_optimizer.dart';
import '../../core/di/injection_container.dart';

class ArCameraView extends StatefulWidget {
  final ArTrackingInfo trackingInfo;
  final bool isImageTrackingEnabled;
  final VoidCallback? onImageTrackingToggle;

  const ArCameraView({
    super.key,
    required this.trackingInfo,
    this.isImageTrackingEnabled = false,
    this.onImageTrackingToggle,
  });

  @override
  State<ArCameraView> createState() => _ArCameraViewState();
}

class _ArCameraViewState extends State<ArCameraView> {
  late ArEnergyOptimizer _energyOptimizer;
  
  @override
  void initState() {
    super.initState();
    _energyOptimizer = getIt<ArEnergyOptimizer>();
  }
  
  void _recordInteraction() {
    _energyOptimizer.recordInteraction();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _recordInteraction,
      onPanStart: (_) => _recordInteraction(),
      onScaleStart: (_) => _recordInteraction(),
      child: Stack(
        children: [
          // AR Camera View
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const ARView(
                planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
              ),
            ),
          ),
          
          // Status Indicators Overlay
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            child: _buildStatusIndicators(),
          ),
          
          // Image Tracking Toggle
          if (widget.onImageTrackingToggle != null)
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: _buildImageTrackingToggle(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TrackingStatusIndicator(trackingInfo: widget.trackingInfo),
        SizedBox(height: 8.h),
        _LightingIndicator(lighting: widget.trackingInfo.lighting),
        SizedBox(height: 8.h),
        _ConfidenceIndicator(confidence: widget.trackingInfo.confidence),
      ],
    );
  }

  Widget _buildImageTrackingToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_search,
            color: widget.isImageTrackingEnabled ? Colors.green : Colors.white54,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Switch(
            value: widget.isImageTrackingEnabled,
            onChanged: (_) => widget.onImageTrackingToggle?.call(),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _TrackingStatusIndicator extends StatelessWidget {
  final ArTrackingInfo trackingInfo;

  const _TrackingStatusIndicator({required this.trackingInfo});

  @override
  Widget build(BuildContext context) {
    final (color, text, icon) = _getTrackingStatusData();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.w),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String, IconData) _getTrackingStatusData() {
    switch (trackingInfo.state) {
      case ArTrackingState.tracking:
        return (Colors.green, 'Tracking', Icons.check_circle);
      case ArTrackingState.initializing:
        return (Colors.orange, 'Initializing', Icons.refresh);
      case ArTrackingState.paused:
        return (Colors.yellow, 'Paused', Icons.pause_circle);
      case ArTrackingState.stopped:
        return (Colors.grey, 'Stopped', Icons.stop_circle);
      case ArTrackingState.error:
        return (Colors.red, 'Error', Icons.error);
      case ArTrackingState.none:
        return (Colors.grey, 'Not Tracking', Icons.help_outline);
    }
  }
}

class _LightingIndicator extends StatelessWidget {
  final ArLightingCondition lighting;

  const _LightingIndicator({required this.lighting});

  @override
  Widget build(BuildContext context) {
    final (color, text, icon) = _getLightingData();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.w),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String, IconData) _getLightingData() {
    switch (lighting) {
      case ArLightingCondition.bright:
        return (Colors.yellow, 'Bright', Icons.wb_sunny);
      case ArLightingCondition.moderate:
        return (Colors.green, 'Good', Icons.wb_sunny_outlined);
      case ArLightingCondition.dark:
        return (Colors.orange, 'Dark', Icons.nights_stay);
      case ArLightingCondition.tooBright:
        return (Colors.red, 'Too Bright', Icons.flash_on);
      case ArLightingCondition.unknown:
        return (Colors.grey, 'Unknown', Icons.help_outline);
    }
  }
}

class _ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const _ConfidenceIndicator({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final color = confidence > 0.7 
        ? Colors.green 
        : confidence > 0.4 
            ? Colors.orange 
            : Colors.red;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_cellular_alt,
            color: color,
            size: 16.w,
          ),
          SizedBox(width: 6.w),
          Text(
            '${(confidence * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}