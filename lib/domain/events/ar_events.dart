import 'package:equatable/equatable.dart';
import '../entities/ar_entities.dart';

abstract class ArEvent extends Equatable {
  const ArEvent();
}

class ArPermissionRequested extends ArEvent {
  const ArPermissionRequested();
  
  @override
  List<Object> get props => [];
}

class ArPermissionGranted extends ArEvent {
  const ArPermissionGranted();
  
  @override
  List<Object> get props => [];
}

class ArPermissionDenied extends ArEvent {
  const ArPermissionDenied();
  
  @override
  List<Object> get props => [];
}

class ArDeviceCompatibilityChecked extends ArEvent {
  final ArDeviceCompatibility compatibility;
  
  const ArDeviceCompatibilityChecked(this.compatibility);
  
  @override
  List<Object> get props => [compatibility];
}

class ArSessionInitialized extends ArEvent {
  const ArSessionInitialized();
  
  @override
  List<Object> get props => [];
}

class ArSessionStarted extends ArEvent {
  const ArSessionStarted();
  
  @override
  List<Object> get props => [];
}

class ArSessionPaused extends ArEvent {
  const ArSessionPaused();
  
  @override
  List<Object> get props => [];
}

class ArSessionResumed extends ArEvent {
  const ArSessionResumed();
  
  @override
  List<Object> get props => [];
}

class ArSessionStopped extends ArEvent {
  const ArSessionStopped();
  
  @override
  List<Object> get props => [];
}

class ArTrackingStateChanged extends ArEvent {
  final ArTrackingInfo trackingInfo;
  
  const ArTrackingStateChanged(this.trackingInfo);
  
  @override
  List<Object> get props => [trackingInfo];
}

class ArImageTrackingToggled extends ArEvent {
  final bool enabled;
  
  const ArImageTrackingToggled(this.enabled);
  
  @override
  List<Object> get props => [enabled];
}

class ArError extends ArEvent {
  final String message;
  final String? code;
  
  const ArError(this.message, {this.code});
  
  @override
  List<Object> get props => [message, code];
}