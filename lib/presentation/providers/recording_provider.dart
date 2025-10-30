import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../domain/usecases/start_recording_usecase.dart';
import '../../domain/usecases/stop_recording_usecase.dart';
import '../../domain/usecases/save_to_gallery_usecase.dart';
import '../../domain/usecases/get_recordings_usecase.dart';

import '../../core/di/injection_container.dart';

final recordingRepositoryProvider = Provider<RecordingRepository>((ref) {
  return getIt<RecordingRepositoryImpl>();
});

final startRecordingUseCaseProvider = Provider<StartRecordingUseCase>((ref) {
  final repository = ref.watch(recordingRepositoryProvider);
  return StartRecordingUseCase(repository);
});

final stopRecordingUseCaseProvider = Provider<StopRecordingUseCase>((ref) {
  final repository = ref.watch(recordingRepositoryProvider);
  return StopRecordingUseCase(repository);
});

final saveToGalleryUseCaseProvider = Provider<SaveToGalleryUseCase>((ref) {
  final repository = ref.watch(recordingRepositoryProvider);
  return SaveToGalleryUseCase(repository);
});

final getRecordingsUseCaseProvider = Provider<GetRecordingsUseCase>((ref) {
  final repository = ref.watch(recordingRepositoryProvider);
  return GetRecordingsUseCase(repository);
});

final currentRecordingProvider = StreamProvider<Recording?>((ref) {
  final repository = ref.watch(recordingRepositoryProvider);
  return repository.currentRecordingStream;
});

final recordingsProvider = StreamProvider<List<Recording>>((ref) {
  final useCase = ref.watch(getRecordingsUseCaseProvider);
  return useCase.watchRecordings();
});

final recordingStateProvider = StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
  final startUseCase = ref.watch(startRecordingUseCaseProvider);
  final stopUseCase = ref.watch(stopRecordingUseCaseProvider);
  final saveUseCase = ref.watch(saveToGalleryUseCaseProvider);
  final getUseCase = ref.watch(getRecordingsUseCaseProvider);
  
  return RecordingNotifier(
    startRecordingUseCase: startUseCase,
    stopRecordingUseCase: stopUseCase,
    saveToGalleryUseCase: saveUseCase,
    getRecordingsUseCase: getUseCase,
  );
});

class RecordingNotifier extends StateNotifier<RecordingState> {
  final StartRecordingUseCase _startRecordingUseCase;
  final StopRecordingUseCase _stopRecordingUseCase;
  final SaveToGalleryUseCase _saveToGalleryUseCase;
  final GetRecordingsUseCase _getRecordingsUseCase;

  RecordingNotifier({
    required StartRecordingUseCase startRecordingUseCase,
    required StopRecordingUseCase stopRecordingUseCase,
    required SaveToGalleryUseCase saveToGalleryUseCase,
    required GetRecordingsUseCase getRecordingsUseCase,
  })  : _startRecordingUseCase = startRecordingUseCase,
        _stopRecordingUseCase = stopRecordingUseCase,
        _saveToGalleryUseCase = saveToGalleryUseCase,
        _getRecordingsUseCase = getRecordingsUseCase,
        super(const RecordingState());

  Future<void> startRecording({bool includeAudio = true}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _startRecordingUseCase.execute(includeAudio: includeAudio);
      
      if (success) {
        state = state.copyWith(isRecording: true, isLoading: false);
      } else {
        state = state.copyWith(
          isRecording: false,
          isLoading: false,
          error: 'Failed to start recording',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        isLoading: false,
        error: 'Error starting recording: $e',
      );
    }
  }

  Future<void> stopRecording() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final success = await _stopRecordingUseCase.execute();
      
      if (success) {
        state = state.copyWith(isRecording: false, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to stop recording',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error stopping recording: $e',
      );
    }
  }

  Future<void> saveToGallery(Recording recording) async {
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      final success = await _saveToGalleryUseCase.execute(recording);
      
      if (success) {
        state = state.copyWith(isSaving: false, lastSavedRecording: recording);
      } else {
        state = state.copyWith(
          isSaving: false,
          error: 'Failed to save to gallery',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Error saving to gallery: $e',
      );
    }
  }

  Future<void> refreshRecordings() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _getRecordingsUseCase.execute();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error refreshing recordings: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearLastSaved() {
    state = state.copyWith(lastSavedRecording: null);
  }
}

class RecordingState {
  final bool isRecording;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final Recording? lastSavedRecording;

  const RecordingState({
    this.isRecording = false,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.lastSavedRecording,
  });

  RecordingState copyWith({
    bool? isRecording,
    bool? isLoading,
    bool? isSaving,
    String? error,
    Recording? lastSavedRecording,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      lastSavedRecording: lastSavedRecording ?? this.lastSavedRecording,
    );
  }
}