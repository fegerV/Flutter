import 'package:dartz/dartz.dart';
import 'package:flutter_ar_app/domain/repositories/performance_repository.dart';
import 'package:flutter_ar_app/domain/usecases/usecase.dart';

class CheckARRequirementsUseCase implements UseCase<bool, NoParams> {
  final PerformanceRepository repository;

  CheckARRequirementsUseCase(this.repository);

  @override
  Future<Either<String, bool>> call(NoParams params) async {
    return await repository.checkARRequirements();
  }
}