import 'package:injectable/injectable.dart';
import '../entities/cache_info.dart';
import '../repositories/cache_repository.dart';
import 'usecase.dart';

class GetCacheInfoParams {
  const GetCacheInfoParams();
}

@injectable
class GetCacheInfoUseCase implements UseCase<CacheInfo, GetCacheInfoParams> {
  final CacheRepository _repository;

  GetCacheInfoUseCase(this._repository);

  @override
  Future<CacheInfo> call(GetCacheInfoParams params) async {
    return await _repository.getCacheInfo();
  }
}