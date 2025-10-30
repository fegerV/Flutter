import '../entities/recording.dart';
import '../repositories/recording_repository.dart';

class GetRecordingsUseCase {
  final RecordingRepository _repository;

  GetRecordingsUseCase(this._repository);

  Future<List<Recording>> execute() async {
    return await _repository.getAllRecordings();
  }

  Stream<List<Recording>> watchRecordings() {
    return _repository.recordingsStream;
  }
}