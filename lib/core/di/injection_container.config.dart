// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'injection_container.dart' as i;

import 'package:flutter_ar_app/domain/usecases/download_animation_usecase.dart'
    as inj0;
import 'package:flutter_ar_app/domain/usecases/get_cached_animations_usecase.dart'
    as inj1;
import 'package:flutter_ar_app/domain/usecases/scan_qr_code_usecase.dart'
    as inj2;
import 'package:flutter_ar_app/domain/usecases/get_cache_info_usecase.dart'
    as inj3;
import 'package:flutter_ar_app/domain/usecases/clear_cache_usecase.dart'
    as inj4;

import 'package:flutter_ar_app/domain/repositories/animation_repository.dart'
    as inj5;
import 'package:flutter_ar_app/domain/repositories/qr_repository.dart' as inj6;
import 'package:flutter_ar_app/domain/repositories/cache_repository.dart' as inj7;

import 'package:flutter_ar_app/data/repositories/animation_repository_impl.dart'
    as inj8;
import 'package:flutter_ar_app/data/repositories/qr_repository_impl.dart'
    as inj9;
import 'package:flutter_ar_app/data/repositories/cache_repository_impl.dart'
    as inj10;

import 'package:flutter_ar_app/data/services/cache_service.dart' as inj11;
import 'package:flutter_ar_app/data/services/qr_service.dart' as inj12;

import 'package:flutter_ar_app/data/datasources/animation_remote_data_source.dart'
    as inj13;

import 'package:dio/dio.dart' as inj14;

GetIt g = GetIt.instance;

Future<void> configureDependencies() async {
  final getIt = GetIt.asNewInstance();
  
  // Services
  getIt.registerSingleton<inj11.CacheService>(inj11.CacheService());
  getIt.registerSingleton<inj12.QRService>(inj12.QRService());
  
  // Data sources
  getIt.registerSingleton<inj13.AnimationRemoteDataSource>(
    inj13.AnimationRemoteDataSourceImpl(getIt<inj14.Dio>()),
  );
  
  // Repositories
  getIt.registerSingleton<inj5.AnimationRepository>(
    inj8.AnimationRepositoryImpl(
      getIt<inj13.AnimationRemoteDataSource>(),
      getIt<inj11.CacheService>(),
      getIt<inj14.Dio>(),
    ),
  );
  
  getIt.registerSingleton<inj6.QRRepository>(
    inj9.QRRepositoryImpl(getIt<inj12.QRService>()),
  );
  
  getIt.registerSingleton<inj7.CacheRepository>(
    inj10.CacheRepositoryImpl(getIt<inj11.CacheService>()),
  );
  
  // Use cases
  getIt.registerSingleton<inj0.DownloadAnimationUseCase>(
    inj0.DownloadAnimationUseCase(getIt<inj5.AnimationRepository>()),
  );
  
  getIt.registerSingleton<inj1.GetCachedAnimationsUseCase>(
    inj1.GetCachedAnimationsUseCase(getIt<inj5.AnimationRepository>()),
  );
  
  getIt.registerSingleton<inj2.ScanQRCodeUseCase>(
    inj2.ScanQRCodeUseCase(getIt<inj6.QRRepository>()),
  );
  
  getIt.registerSingleton<inj3.GetCacheInfoUseCase>(
    inj3.GetCacheInfoUseCase(getIt<inj7.CacheRepository>()),
  );
  
  getIt.registerSingleton<inj4.ClearCacheUseCase>(
    inj4.ClearCacheUseCase(getIt<inj7.CacheRepository>()),
  );
}

extension GetItExtension on GetIt {
  T get<T extends Object>() {
    return g<T>();
  }
}