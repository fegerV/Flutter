import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'injection_container.config.dart';

// Domain imports
import '../../domain/repositories/ar_repositories.dart';

// Data imports
import '../../data/repositories/ar_marker_repository_impl.dart';
import '../../data/repositories/ar_tracking_repository_impl.dart';
import '../../data/repositories/video_overlay_repository_impl.dart';
import '../../data/repositories/pose_smoothing_repository_impl.dart';

// AR imports
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async {
  getIt.init();
}

@module
abstract class RegisterModule {
  @singleton
  Dio get dio => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  @singleton
  DefaultCacheManager get cacheManager => DefaultCacheManager();

  // AR Managers (these will be initialized by the AR view)
  @lazySingleton
  ARSessionManager get arSessionManager => ARSessionManager();

  @lazySingleton
  ARObjectManager get arObjectManager => ARObjectManager();

  @lazySingleton
  ARAnchorManager get arAnchorManager => ARAnchorManager();

  @lazySingleton
  ARLocationManager get arLocationManager => ARLocationManager();

  // Repository implementations
  @lazySingleton
  ARMarkerRepository get arMarkerRepository => ARMarkerRepositoryImpl(getIt<Dio>(), getIt<DefaultCacheManager>());

  @lazySingleton
  ARTrackingRepository get arTrackingRepository => ARTrackingRepositoryImpl(
    getIt<ARSessionManager>(),
    getIt<ARObjectManager>(),
    getIt<ARAnchorManager>(),
    getIt<ARLocationManager>(),
  );

  @lazySingleton
  VideoOverlayRepository get videoOverlayRepository => VideoOverlayRepositoryImpl();

  @lazySingleton
  PoseSmoothingRepository get poseSmoothingRepository => PoseSmoothingRepositoryImpl();
}
