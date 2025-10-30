import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math.dart';

import '../../domain/entities/ar_tracking.dart';
import '../providers/ar_providers.dart';

class ARVideoOverlayWidget extends ConsumerStatefulWidget {
  final String markerId;
  final VideoOverlayState videoState;
  final ARTrackingResult? trackingResult;

  const ARVideoOverlayWidget({
    super.key,
    required this.markerId,
    required this.videoState,
    this.trackingResult,
  });

  @override
  ConsumerState<ARVideoOverlayWidget> createState() => _ARVideoOverlayWidgetState();
}

class _ARVideoOverlayWidgetState extends ConsumerState<ARVideoOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(ARVideoOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger animations when tracking state changes
    final wasTracking = oldWidget.trackingResult?.isTracking ?? false;
    final isTracking = widget.trackingResult?.isTracking ?? false;
    
    if (wasTracking != isTracking) {
      if (isTracking) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _showOverlay() {
    _fadeController.forward();
    _scaleController.forward();
  }

  void _hideOverlay() {
    _fadeController.reverse();
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final trackingResult = widget.trackingResult;
    final videoState = widget.videoState;

    if (trackingResult == null || !trackingResult.isTracking) {
      return const SizedBox.shrink();
    }

    // Calculate screen position from 3D transform
    final screenPosition = _calculateScreenPosition(trackingResult.transformMatrix);
    if (screenPosition == null) {
      return const SizedBox.shrink();
    }

    // Calculate size based on distance and marker dimensions
    final size = _calculateOverlaySize(trackingResult);

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Positioned(
          left: screenPosition.dx - size.width / 2,
          top: screenPosition.dy - size.height / 2,
          width: size.width,
          height: size.height,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value * _calculateOpacity(trackingResult),
              child: child,
            ),
          ),
        );
      },
      child: _buildVideoOverlay(videoState, size),
    );
  }

  Widget _buildVideoOverlay(VideoOverlayState videoState, Size size) {
    if (videoState.hasError) {
      return _buildErrorWidget(size);
    }

    if (!videoState.isLoaded) {
      return _buildLoadingWidget(size);
    }

    return _buildVideoPlayer(size);
  }

  Widget _buildVideoPlayer(Size size) {
    // Get the video controller from the repository
    final videoRepository = ref.read(videoOverlayRepositoryProvider);
    
    // This would need to be implemented in the repository
    // For now, we'll show a placeholder
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildVideoContent(),
      ),
    );
  }

  Widget _buildVideoContent() {
    // This would integrate with the actual video player
    // For now, showing a placeholder with animation
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.8),
            Colors.purple.withOpacity(0.8),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.play_circle_filled,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Video Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset? _calculateScreenPosition(Matrix4 transformMatrix) {
    // This is a simplified calculation
    // In a real implementation, you would need to project the 3D coordinates
    // to 2D screen coordinates using the camera's projection matrix
    
    final translation = transformMatrix.getTranslation();
    
    // Simple projection (this would need proper 3D to 2D projection)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Map 3D position to screen coordinates
    final screenX = screenWidth / 2 + (translation.x * 100);
    final screenY = screenHeight / 2 - (translation.y * 100);
    
    // Check if the position is within screen bounds
    if (screenX < 0 || screenX > screenWidth || 
        screenY < 0 || screenY > screenHeight) {
      return null;
    }
    
    return Offset(screenX.toDouble(), screenY.toDouble());
  }

  Size _calculateOverlaySize(ARTrackingResult trackingResult) {
    // Calculate size based on distance and confidence
    final baseSize = 200.0;
    final distance = trackingResult.position.length;
    final confidence = trackingResult.confidence;
    
    // Size decreases with distance and increases with confidence
    final scaleFactor = (1.0 / (1.0 + distance * 0.5)) * confidence;
    final size = baseSize * scaleFactor;
    
    return Size(size, size * 0.75); // 4:3 aspect ratio
  }

  double _calculateOpacity(ARTrackingResult trackingResult) {
    // Calculate opacity based on confidence and tracking stability
    final confidence = trackingResult.confidence;
    
    // Fade in based on confidence threshold
    if (confidence < 0.5) return 0.0;
    if (confidence > 0.8) return 1.0;
    
    // Linear interpolation between 0.5 and 0.8 confidence
    return (confidence - 0.5) / 0.3;
  }
}