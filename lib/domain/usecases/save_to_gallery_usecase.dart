import '../entities/recording.dart';
import '../repositories/recording_repository.dart';

class SaveToGalleryUseCase {
  final RecordingRepository _repository;

  SaveToGalleryUseCase(this._repository);

  Future<bool> execute(Recording recording) async {
    return await _repository.saveToGallery(recording);
  }
}