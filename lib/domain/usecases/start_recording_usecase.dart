import '../entities/recording.dart';
import '../repositories/recording_repository.dart';

class StartRecordingUseCase {
  final RecordingRepository _repository;

  StartRecordingUseCase(this._repository);

  Future<bool> execute({bool includeAudio = true}) async {
    return await _repository.startRecording(includeAudio: includeAudio);
  }
}