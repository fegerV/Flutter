import 'package:equatable/equatable.dart';
import '../entities/ar_entities.dart';

abstract class ArState extends Equatable {
  const ArState();
  
  @override
  List<Object?> get props => [];
}

class ArInitial extends ArState {
  const ArInitial();
}

class ArLoading extends ArState {
  const ArLoading();
}

class ArPermissionChecking extends ArState {
  const ArPermissionChecking();
}

class ArPermissionDenied extends ArState {
  final String message;
  
  const ArPermissionDenied(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ArDeviceChecking extends ArState {
  const ArDeviceChecking();
}

class ArDeviceUnsupported extends ArState {
  final String reason;
  
  const ArDeviceUnsupported(this.reason);
  
  @override
  List<Object?> get props => [reason];
}

class ArSessionInitializing extends ArState {
  const ArSessionInitializing();
}

class ArSessionReady extends ArState {
  final ArTrackingInfo trackingInfo;
  final bool isImageTrackingEnabled;
  
  const ArSessionReady({
    required this.trackingInfo,
    this.isImageTrackingEnabled = false,
  });
  
  @override
  List<Object?> get props => [trackingInfo, isImageTrackingEnabled];
}

class ArSessionActive extends ArState {
  final ArTrackingInfo trackingInfo;
  final bool isImageTrackingEnabled;
  
  const ArSessionActive({
    required this.trackingInfo,
    this.isImageTrackingEnabled = false,
  });
  
  @override
  List<Object?> get props => [trackingInfo, isImageTrackingEnabled];
}

class ArSessionPaused extends ArState {
  final ArTrackingInfo trackingInfo;
  final bool isImageTrackingEnabled;
  
  const ArSessionPaused({
    required this.trackingInfo,
    this.isImageTrackingEnabled = false,
  });
  
  @override
  List<Object?> get props => [trackingInfo, isImageTrackingEnabled];
}

class ArError extends ArState {
  final String message;
  final String? code;
  
  const ArError(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
}