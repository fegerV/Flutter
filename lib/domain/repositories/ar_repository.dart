import '../entities/ar_entities.dart';

abstract class ArRepository {
  Stream<ArTrackingInfo> get trackingStateStream;
  
  Future<ArDeviceCompatibility> checkDeviceCompatibility();
  Future<bool> requestCameraPermission();
  Future<bool> isCameraPermissionGranted();
  Future<void> initializeArSession();
  Future<void> startArSession();
  Future<void> pauseArSession();
  Future<void> resumeArSession();
  Future<void> stopArSession();
  Future<void> disposeArSession();
  
  Future<void> enableImageTracking();
  Future<void> disableImageTracking();
  Future<bool> isImageTrackingEnabled();
}