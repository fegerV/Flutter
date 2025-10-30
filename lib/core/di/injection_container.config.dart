// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i3;
import 'package:dio/dio.dart' as _i4;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../../data/datasources/local/secure_storage_service.dart' as _i11;
import '../../data/datasources/remote/animation_api_client.dart' as _i6;
import '../../data/datasources/remote/auth_api_client.dart' as _i7;
import '../../data/datasources/remote/marker_api_client.dart' as _i9;
import '../../data/datasources/remote/minio_client.dart' as _i10;
import '../../data/datasources/remote/user_asset_api_client.dart' as _i13;
import '../../data/repositories/animation_repository.dart' as _i16;
import '../../data/repositories/auth_repository.dart' as _i17;
import '../../data/repositories/marker_repository.dart' as _i18;
import '../../data/repositories/user_asset_repository.dart' as _i14;
import '../../domain/services/ar_service.dart' as _i15;
import '../network/network_info.dart' as _i8;
import 'injection_container.dart' as _i12;

extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i3.Connectivity>(registerModule.connectivity);
    gh.singleton<_i4.Dio>(registerModule.dio);
    gh.singleton<_i5.FlutterSecureStorage>(registerModule.secureStorage);
    gh.lazySingleton<_i6.AnimationApiClient>(
        () => _i6.AnimationApiClient(gh<_i4.Dio>()));
    gh.lazySingleton<_i7.AuthApiClient>(
        () => _i7.AuthApiClient(gh<_i4.Dio>()));
    gh.lazySingleton<_i8.NetworkInfo>(
        () => _i8.NetworkInfoImpl(gh<_i3.Connectivity>()));
    gh.lazySingleton<_i9.MarkerApiClient>(
        () => _i9.MarkerApiClient(gh<_i4.Dio>()));
    gh.lazySingleton<_i10.MinioClientService>(
        () => _i10.MinioClientService());
    gh.lazySingleton<_i11.SecureStorageService>(
        () => _i11.SecureStorageService(gh<_i5.FlutterSecureStorage>()));
    gh.lazySingleton<_i13.UserAssetApiClient>(
        () => _i13.UserAssetApiClient(gh<_i4.Dio>()));
    gh.lazySingleton<_i14.UserAssetRepository>(() =>
        _i14.UserAssetRepositoryImpl(
          apiClient: gh<_i13.UserAssetApiClient>(),
          secureStorage: gh<_i11.SecureStorageService>(),
          networkInfo: gh<_i8.NetworkInfo>(),
        ));
    gh.lazySingleton<_i15.ArService>(() => _i15.ArService(
          authRepository: gh<_i17.AuthRepository>(),
          animationRepository: gh<_i16.AnimationRepository>(),
          markerRepository: gh<_i18.MarkerRepository>(),
          userAssetRepository: gh<_i14.UserAssetRepository>(),
        ));
    gh.lazySingleton<_i16.AnimationRepository>(() =>
        _i16.AnimationRepositoryImpl(
          apiClient: gh<_i6.AnimationApiClient>(),
          minioClient: gh<_i10.MinioClientService>(),
          secureStorage: gh<_i11.SecureStorageService>(),
          networkInfo: gh<_i8.NetworkInfo>(),
        ));
    gh.lazySingleton<_i17.AuthRepository>(() => _i17.AuthRepositoryImpl(
          apiClient: gh<_i7.AuthApiClient>(),
          secureStorage: gh<_i11.SecureStorageService>(),
          networkInfo: gh<_i8.NetworkInfo>(),
        ));
    gh.lazySingleton<_i18.MarkerRepository>(() => _i18.MarkerRepositoryImpl(
          apiClient: gh<_i9.MarkerApiClient>(),
          secureStorage: gh<_i11.SecureStorageService>(),
          networkInfo: gh<_i8.NetworkInfo>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i12.RegisterModule {}
