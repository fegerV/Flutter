import 'package:injectable/injectable.dart';
import '../entities/animation.dart';
import '../repositories/animation_repository.dart';
import 'usecase.dart';

class DownloadAnimationParams {
  final Animation animation;

  const DownloadAnimationParams(this.animation);
}

@injectable
class DownloadAnimationUseCase implements UseCase<Animation, DownloadAnimationParams> {
  final AnimationRepository _repository;

  DownloadAnimationUseCase(this._repository);

  @override
  Future<Animation> call(DownloadAnimationParams params) async {
    return await _repository.downloadAnimation(params.animation);
  }
}