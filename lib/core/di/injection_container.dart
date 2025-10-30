import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

import 'injection_container.config.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/qr_service.dart';
import '../../data/datasources/animation_remote_data_source.dart';
import '../../data/repositories/animation_repository_impl.dart';
import '../../data/repositories/qr_repository_impl.dart';
import '../../data/repositories/cache_repository_impl.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async {
  getIt.init();
  
  // Initialize services
  await getIt<CacheService>().initialize();
  await getIt<QRService>().initialize();
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
  CacheService get cacheService => CacheService();

  @singleton
  QRService get qrService => QRService();

  @singleton
  AnimationRemoteDataSource get animationRemoteDataSource => AnimationRemoteDataSourceImpl(dio);

  @singleton
  AnimationRepositoryImpl get animationRepository => AnimationRepositoryImpl(
    animationRemoteDataSource,
    cacheService,
    dio,
  );

  @singleton
  QRRepositoryImpl get qrRepository => QRRepositoryImpl(qrService);

  @singleton
  CacheRepositoryImpl get cacheRepository => CacheRepositoryImpl(cacheService);
}
