import 'package:injectable/injectable.dart';
import '../repositories/cache_repository.dart';
import 'usecase.dart';

class ClearCacheParams {
  final bool clearAll;
  final String? animationId;

  const ClearCacheParams({this.clearAll = false, this.animationId});
}

@injectable
class ClearCacheUseCase implements UseCase<void, ClearCacheParams> {
  final CacheRepository _repository;

  ClearCacheUseCase(this._repository);

  @override
  Future<void> call(ClearCacheParams params) async {
    await _repository.clearCache(animationId: params.clearAll ? null : params.animationId);
  }
}