import 'package:dartz/dartz.dart';
import 'package:flutter_ar_app/domain/repositories/performance_repository.dart';
import 'package:flutter_ar_app/domain/usecases/usecase.dart';

class StartPerformanceMonitoringUseCase implements UseCase<void, NoParams> {
  final PerformanceRepository repository;

  StartPerformanceMonitoringUseCase(this.repository);

  @override
  Future<Either<String, void>> call(NoParams params) async {
    return await repository.startMonitoring();
  }
}