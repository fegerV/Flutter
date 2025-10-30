import '../entities/recording.dart';

abstract class RecordingRepository {
  Future<bool> startRecording({bool includeAudio = true});
  Future<bool> stopRecording();
  Future<bool> pauseRecording();
  Future<bool> resumeRecording();
  Future<Recording?> getCurrentRecording();
  Future<List<Recording>> getAllRecordings();
  Future<bool> saveToGallery(Recording recording);
  Future<bool> deleteRecording(String recordingId);
  Future<Recording?> getRecordingById(String id);
  Stream<Recording?> get currentRecordingStream;
  Stream<List<Recording>> get recordingsStream;
}