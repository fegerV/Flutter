import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

import 'injection_container.config.dart';
import '../../data/repositories/ar_repository_impl.dart';
import '../../domain/repositories/ar_repository.dart';
import '../../domain/notifiers/ar_notifier.dart';
import '../services/ar_energy_optimizer.dart';

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
  ArEnergyOptimizer get arEnergyOptimizer => ArEnergyOptimizer();

  @singleton
  ArRepository get arRepository => ArRepositoryImpl();

  @singleton
  ArNotifier get arNotifier => ArNotifier(getIt<ArRepository>());
}
