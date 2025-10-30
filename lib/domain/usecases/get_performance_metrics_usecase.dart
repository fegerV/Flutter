import 'package:dartz/dartz.dart';
import 'package:flutter_ar_app/domain/entities/performance_metrics.dart';
import 'package:flutter_ar_app/domain/repositories/performance_repository.dart';
import 'package:flutter_ar_app/domain/usecases/usecase.dart';

class GetPerformanceMetricsUseCase implements UseCase<PerformanceMetrics, NoParams> {
  final PerformanceRepository repository;

  GetPerformanceMetricsUseCase(this.repository);

  @override
  Future<Either<String, PerformanceMetrics>> call(NoParams params) async {
    return await repository.getCurrentMetrics();
  }
}