import 'package:dartz/dartz.dart';
import 'package:flutter_ar_app/domain/entities/device_profile.dart';
import 'package:flutter_ar_app/domain/repositories/performance_repository.dart';
import 'package:flutter_ar_app/domain/usecases/usecase.dart';

class GetDeviceProfileUseCase implements UseCase<DeviceProfile, NoParams> {
  final PerformanceRepository repository;

  GetDeviceProfileUseCase(this.repository);

  @override
  Future<Either<String, DeviceProfile>> call(NoParams params) async {
    return await repository.getDeviceProfile();
  }
}