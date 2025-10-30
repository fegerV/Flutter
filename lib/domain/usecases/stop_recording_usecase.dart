import '../repositories/recording_repository.dart';

class StopRecordingUseCase {
  final RecordingRepository _repository;

  StopRecordingUseCase(this._repository);

  Future<bool> execute() async {
    return await _repository.stopRecording();
  }
}