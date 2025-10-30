import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../services/recording_service.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingService _service;

  RecordingRepositoryImpl(this._service);

  @override
  Future<bool> startRecording({bool includeAudio = true}) async {
    return await _service.startRecording(includeAudio: includeAudio);
  }

  @override
  Future<bool> stopRecording() async {
    return await _service.stopRecording();
  }

  @override
  Future<bool> pauseRecording() async {
    return await _service.pauseRecording();
  }

  @override
  Future<bool> resumeRecording() async {
    return await _service.resumeRecording();
  }

  @override
  Future<Recording?> getCurrentRecording() async {
    return _service.currentRecording;
  }

  @override
  Future<List<Recording>> getAllRecordings() async {
    return await _service.getAllRecordings();
  }

  @override
  Future<bool> saveToGallery(Recording recording) async {
    return await _service.saveToGallery(recording);
  }

  @override
  Future<bool> deleteRecording(String recordingId) async {
    return await _service.deleteRecording(recordingId);
  }

  @override
  Future<Recording?> getRecordingById(String id) async {
    return await _service.getRecordingById(id);
  }

  @override
  Stream<Recording?> get currentRecordingStream => _service.currentRecordingStream;

  @override
  Stream<List<Recording>> get recordingsStream => _service.recordingsStream;
}