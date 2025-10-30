import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/notifiers/ar_notifier.dart';
import '../../domain/states/ar_state.dart';
import '../../core/di/injection_container.dart';

final arNotifierProvider = StateNotifierProvider<ArNotifier, ArState>(
  (ref) => getIt<ArNotifier>(),
);

final arEventProvider = StreamProvider<ArEvent>(
  (ref) => getIt<ArNotifier>().eventStream,
);

extension ArStateExtension on ArState {
  bool get isLoading => this is ArLoading || 
                         this is ArPermissionChecking || 
                         this is ArDeviceChecking || 
                         this is ArSessionInitializing;
  
  bool get hasError => this is ArError;
  
  bool get isReady => this is ArSessionReady || 
                      this is ArSessionActive || 
                      this is ArSessionPaused;
  
  bool get isActive => this is ArSessionActive;
  
  bool get isPaused => this is ArSessionPaused;
}