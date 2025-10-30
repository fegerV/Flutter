import 'package:injectable/injectable.dart';
import '../entities/animation.dart';
import '../repositories/animation_repository.dart';
import 'usecase.dart';

class GetCachedAnimationsParams {
  final bool onlyDownloaded;

  const GetCachedAnimationsParams({this.onlyDownloaded = false});
}

@injectable
class GetCachedAnimationsUseCase implements UseCase<List<Animation>, GetCachedAnimationsParams> {
  final AnimationRepository _repository;

  GetCachedAnimationsUseCase(this._repository);

  @override
  Future<List<Animation>> call(GetCachedAnimationsParams params) async {
    return await _repository.getCachedAnimations(onlyDownloaded: params.onlyDownloaded);
  }
}