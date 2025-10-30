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
import 'package:flutter_ar_app/domain/usecases/start_recording_usecase.dart'
    as inj5;
import 'package:flutter_ar_app/domain/usecases/stop_recording_usecase.dart'
    as inj6;
import 'package:flutter_ar_app/domain/usecases/save_to_gallery_usecase.dart'
    as inj7;
import 'package:flutter_ar_app/domain/usecases/get_recordings_usecase.dart'
    as inj8;

import 'package:flutter_ar_app/domain/repositories/animation_repository.dart'
    as inj9;
import 'package:flutter_ar_app/domain/repositories/qr_repository.dart' as inj10;
import 'package:flutter_ar_app/domain/repositories/cache_repository.dart' as inj11;
import 'package:flutter_ar_app/domain/repositories/recording_repository.dart' as inj12;

import 'package:flutter_ar_app/data/repositories/animation_repository_impl.dart'
    as inj13;
import 'package:flutter_ar_app/data/repositories/qr_repository_impl.dart'
    as inj14;
import 'package:flutter_ar_app/data/repositories/cache_repository_impl.dart'
    as inj15;
import 'package:flutter_ar_app/data/repositories/recording_repository_impl.dart'
    as inj16;

import 'package:flutter_ar_app/data/services/cache_service.dart' as inj17;
import 'package:flutter_ar_app/data/services/qr_service.dart' as inj18;
import 'package:flutter_ar_app/data/services/recording_service.dart' as inj19;

import 'package:flutter_ar_app/data/datasources/animation_remote_data_source.dart'
    as inj20;

import 'package:dio/dio.dart' as inj21;

GetIt g = GetIt.instance;

Future<void> configureDependencies() async {
  final getIt = GetIt.asNewInstance();
  
  // Services
  getIt.registerSingleton<inj17.CacheService>(inj17.CacheService());
  getIt.registerSingleton<inj18.QRService>(inj18.QRService());
  getIt.registerSingleton<inj19.RecordingService>(inj19.RecordingService());
  
  // Data sources
  getIt.registerSingleton<inj20.AnimationRemoteDataSource>(
    inj20.AnimationRemoteDataSourceImpl(getIt<inj21.Dio>()),
  );
  
  // Repositories
  getIt.registerSingleton<inj9.AnimationRepository>(
    inj13.AnimationRepositoryImpl(
      getIt<inj20.AnimationRemoteDataSource>(),
      getIt<inj17.CacheService>(),
      getIt<inj21.Dio>(),
    ),
  );
  
  getIt.registerSingleton<inj10.QRRepository>(
    inj14.QRRepositoryImpl(getIt<inj18.QRService>()),
  );
  
  getIt.registerSingleton<inj11.CacheRepository>(
    inj15.CacheRepositoryImpl(getIt<inj17.CacheService>()),
  );
  
  getIt.registerSingleton<inj12.RecordingRepository>(
    inj16.RecordingRepositoryImpl(getIt<inj19.RecordingService>()),
  );
  
  // Use cases
  getIt.registerSingleton<inj0.DownloadAnimationUseCase>(
    inj0.DownloadAnimationUseCase(getIt<inj9.AnimationRepository>()),
  );
  
  getIt.registerSingleton<inj1.GetCachedAnimationsUseCase>(
    inj1.GetCachedAnimationsUseCase(getIt<inj9.AnimationRepository>()),
  );
  
  getIt.registerSingleton<inj2.ScanQRCodeUseCase>(
    inj2.ScanQRCodeUseCase(getIt<inj10.QRRepository>()),
  );
  
  getIt.registerSingleton<inj3.GetCacheInfoUseCase>(
    inj3.GetCacheInfoUseCase(getIt<inj11.CacheRepository>()),
  );
  
  getIt.registerSingleton<inj4.ClearCacheUseCase>(
    inj4.ClearCacheUseCase(getIt<inj7.CacheRepository>()),
  );
  
  getIt.registerSingleton<inj5.StartRecordingUseCase>(
    inj5.StartRecordingUseCase(getIt<inj12.RecordingRepository>()),
  );
  
  getIt.registerSingleton<inj6.StopRecordingUseCase>(
    inj6.StopRecordingUseCase(getIt<inj12.RecordingRepository>()),
  );
  
  getIt.registerSingleton<inj7.SaveToGalleryUseCase>(
    inj7.SaveToGalleryUseCase(getIt<inj12.RecordingRepository>()),
  );
  
  getIt.registerSingleton<inj8.GetRecordingsUseCase>(
    inj8.GetRecordingsUseCase(getIt<inj12.RecordingRepository>()),
  );
}

extension GetItExtension on GetIt {
  T get<T extends Object>() {
    return g<T>();
  }
}