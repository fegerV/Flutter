import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/recording.dart';

class RecordingService {
  static const MethodChannel _channel = MethodChannel('recording_channel');
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  
  Recording? _currentRecording;
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;
  bool _isRecording = false;
  bool _isPaused = false;
  
  final StreamController<Recording?> _currentRecordingController = 
      StreamController<Recording?>.broadcast();
  final StreamController<List<Recording>> _recordingsController = 
      StreamController<List<Recording>>.broadcast();

  Stream<Recording?> get currentRecordingStream => _currentRecordingController.stream;
  Stream<List<Recording>> get recordingsStream => _recordingsController.stream;

  Recording? get currentRecording => _currentRecording;

  Future<bool> checkPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;
      final storageStatus = await Permission.storage.status;

      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) return false;
      }

      if (!micStatus.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) return false;
      }

      if (!storageStatus.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startRecording({bool includeAudio = true}) async {
    if (_isRecording) return false;

    try {
      final hasPermissions = await checkPermissions();
      if (!hasPermissions) return false;

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'recording_$timestamp.mp4';
      final filePath = '${directory.path}/$fileName';

      final result = await _channel.invokeMethod('startRecording', {
        'filePath': filePath,
        'includeAudio': includeAudio,
      });

      if (result == true) {
        _isRecording = true;
        _isPaused = false;
        _recordingStartTime = DateTime.now();
        
        _currentRecording = Recording(
          id: timestamp.toString(),
          filePath: filePath,
          createdAt: DateTime.now(),
          duration: Duration.zero,
          fileSizeBytes: 0,
          hasAudio: includeAudio,
          status: RecordingStatus.recording,
        );

        _startRecordingTimer();
        _currentRecordingController.add(_currentRecording);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> stopRecording() async {
    if (!_isRecording) return false;

    try {
      final result = await _channel.invokeMethod('stopRecording');
      
      if (result == true) {
        _isRecording = false;
        _isPaused = false;
        _recordingTimer?.cancel();
        
        if (_currentRecording != null && _recordingStartTime != null) {
          final duration = DateTime.now().difference(_recordingStartTime!);
          final file = File(_currentRecording!.filePath);
          final fileSize = await file.length();
          
          _currentRecording = _currentRecording!.copyWith(
            duration: duration,
            fileSizeBytes: fileSize,
            status: RecordingStatus.completed,
          );
          
          _currentRecordingController.add(_currentRecording);
          _notifyRecordingsChanged();
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> pauseRecording() async {
    if (!_isRecording || _isPaused) return false;

    try {
      final result = await _channel.invokeMethod('pauseRecording');
      
      if (result == true) {
        _isPaused = true;
        _recordingTimer?.cancel();
        
        if (_currentRecording != null) {
          _currentRecording = _currentRecording!.copyWith(
            status: RecordingStatus.paused,
          );
          _currentRecordingController.add(_currentRecording);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resumeRecording() async {
    if (!_isRecording || !_isPaused) return false;

    try {
      final result = await _channel.invokeMethod('resumeRecording');
      
      if (result == true) {
        _isPaused = false;
        _startRecordingTimer();
        
        if (_currentRecording != null) {
          _currentRecording = _currentRecording!.copyWith(
            status: RecordingStatus.recording,
          );
          _currentRecordingController.add(_currentRecording);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveToGallery(Recording recording) async {
    try {
      final result = await GallerySaver.saveVideo(
        recording.filePath,
        name: 'AR_Recording_${recording.id}',
      );

      if (result == true) {
        await MediaScanner.loadMedia(path: recording.filePath);
        
        final updatedRecording = recording.copyWith(
          status: RecordingStatus.saved,
        );
        
        await _updateRecording(updatedRecording);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRecording(String recordingId) async {
    try {
      final recording = await getRecordingById(recordingId);
      if (recording == null) return false;

      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      await _removeRecording(recordingId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Recording?> getRecordingById(String id) async {
    final recordings = await getAllRecordings();
    return recordings.where((r) => r.id == id).firstOrNull;
  }

  Future<List<Recording>> getAllRecordings() async {
    try {
      final directory = await getTemporaryDirectory();
      final files = await directory.list().where(
        (entity) => entity.path.endsWith('.mp4')
      ).cast<File>().toList();

      final recordings = <Recording>[];
      for (final file in files) {
        final stat = await file.stat();
        final fileName = file.path.split('/').last;
        final id = fileName.replaceAll('recording_', '').replaceAll('.mp4', '');
        
        recordings.add(Recording(
          id: id,
          filePath: file.path,
          createdAt: stat.modified,
          duration: await _getVideoDuration(file.path),
          fileSizeBytes: stat.size,
          hasAudio: true,
          status: RecordingStatus.completed,
        ));
      }

      return recordings..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentRecording != null && _recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        _currentRecording = _currentRecording!.copyWith(
          duration: duration,
        );
        _currentRecordingController.add(_currentRecording);
      }
    });
  }

  Future<Duration> _getVideoDuration(String filePath) async {
    try {
      final info = await _flutterFFmpeg.getMediaInformation(filePath);
      final duration = info?.getMediaProperties()?.getDuration();
      return Duration(milliseconds: (duration ?? 0).toInt());
    } catch (e) {
      return Duration.zero;
    }
  }

  Future<void> _updateRecording(Recording recording) async {
    _notifyRecordingsChanged();
  }

  Future<void> _removeRecording(String recordingId) async {
    _notifyRecordingsChanged();
  }

  void _notifyRecordingsChanged() {
    getAllRecordings().then((recordings) {
      _recordingsController.add(recordings);
    });
  }

  void dispose() {
    _recordingTimer?.cancel();
    _currentRecordingController.close();
    _recordingsController.close();
  }
}