import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/ar_marker.dart';
import '../../domain/entities/ar_tracking.dart';
import '../../domain/repositories/ar_repositories.dart';
import '../../domain/usecases/ar_usecases.dart';

final getIt = GetIt.instance;

// Repository providers
final arMarkerRepositoryProvider = Provider<ARMarkerRepository>((ref) {
  return getIt<ARMarkerRepository>();
});

final arTrackingRepositoryProvider = Provider<ARTrackingRepository>((ref) {
  return getIt<ARTrackingRepository>();
});

final videoOverlayRepositoryProvider = Provider<VideoOverlayRepository>((ref) {
  return getIt<VideoOverlayRepository>();
});

final poseSmoothingRepositoryProvider = Provider<PoseSmoothingRepository>((ref) {
  return getIt<PoseSmoothingRepository>();
});

// Use case providers
final getMarkerConfigurationProvider = Provider<GetMarkerConfigurationUseCase>((ref) {
  final repository = ref.watch(arMarkerRepositoryProvider);
  return GetMarkerConfigurationUseCase(repository);
});

final getAllMarkersProvider = Provider<GetAllMarkersUseCase>((ref) {
  final repository = ref.watch(arMarkerRepositoryProvider);
  return GetAllMarkersUseCase(repository);
});

final syncMarkerDataProvider = Provider<SyncMarkerDataUseCase>((ref) {
  final repository = ref.watch(arMarkerRepositoryProvider);
  return SyncMarkerDataUseCase(repository);
});

final initializeARSessionProvider = Provider<InitializeARSessionUseCase>((ref) {
  final repository = ref.watch(arTrackingRepositoryProvider);
  return InitializeARSessionUseCase(repository);
});

final startMarkerTrackingProvider = Provider<StartMarkerTrackingUseCase>((ref) {
  final repository = ref.watch(arTrackingRepositoryProvider);
  return StartMarkerTrackingUseCase(repository);
});

final getTrackingResultsProvider = Provider<GetTrackingResultsUseCase>((ref) {
  final repository = ref.watch(arTrackingRepositoryProvider);
  return GetTrackingResultsUseCase(repository);
});

final getSmoothedPoseProvider = Provider<GetSmoothedPoseUseCase>((ref) {
  final repository = ref.watch(arTrackingRepositoryProvider);
  return GetSmoothedPoseUseCase(repository);
});

final playVideoOverlayProvider = Provider<PlayVideoOverlayUseCase>((ref) {
  final repository = ref.watch(videoOverlayRepositoryProvider);
  return PlayVideoOverlayUseCase(repository);
});

final pauseVideoOverlayProvider = Provider<PauseVideoOverlayUseCase>((ref) {
  final repository = ref.watch(videoOverlayRepositoryProvider);
  return PauseVideoOverlayUseCase(repository);
});

final loadVideoOverlayProvider = Provider<LoadVideoOverlayUseCase>((ref) {
  final videoRepository = ref.watch(videoOverlayRepositoryProvider);
  final markerRepository = ref.watch(arMarkerRepositoryProvider);
  return LoadVideoOverlayUseCase(videoRepository, markerRepository);
});

final handleMarkerTrackingStateProvider = Provider<HandleMarkerTrackingStateUseCase>((ref) {
  final trackingRepository = ref.watch(arTrackingRepositoryProvider);
  final videoRepository = ref.watch(videoOverlayRepositoryProvider);
  return HandleMarkerTrackingStateUseCase(trackingRepository, videoRepository);
});

final applyPoseSmoothingProvider = Provider<ApplyPoseSmoothingUseCase>((ref) {
  final repository = ref.watch(poseSmoothingRepositoryProvider);
  return ApplyPoseSmoothingUseCase(repository);
});

// State providers
final arTrackingStateProvider = StateNotifierProvider<ARTrackingNotifier, ARTrackingState>((ref) {
  final getTrackingResults = ref.watch(getTrackingResultsProvider);
  return ARTrackingNotifier(getTrackingResults);
});

final markerConfigurationProvider = FutureProvider<MarkerConfiguration>((ref) async {
  final getMarkerConfiguration = ref.watch(getMarkerConfigurationProvider);
  final result = await getMarkerConfiguration.execute('default');
  
  return result.fold(
    (error) => throw Exception('Failed to load marker configuration: $error'),
    (config) => config,
  );
});

final allMarkersProvider = FutureProvider<List<ARMarker>>((ref) async {
  final getAllMarkers = ref.watch(getAllMarkersProvider);
  final result = await getAllMarkers.execute();
  
  return result.fold(
    (error) => throw Exception('Failed to load markers: $error'),
    (markers) => markers,
  );
});

final videoOverlayStatesProvider = StateProvider<Map<String, VideoOverlayState>>((ref) {
  return {};
});

final smoothedPosesProvider = StateProvider<Map<String, SmoothedPose>>((ref) {
  return {};
});

// Notifiers
class ARTrackingNotifier extends StateNotifier<ARTrackingState> {
  final GetTrackingResultsUseCase _getTrackingResults;

  ARTrackingNotifier(this._getTrackingResults) 
    : super(ARTrackingState(lastUpdate: DateTime.now()));

  Future<void> updateTrackingState() async {
    final result = await _getTrackingResults.execute();
    
    result.fold(
      (error) => state = state.copyWith(
        errorMessage: error.toString(),
        lastUpdate: DateTime.now(),
      ),
      (trackingResults) {
        final detectedMarkers = trackingResults.map((r) => r.markerId).toList();
        final trackingResultsMap = {for (var r in trackingResults) r.markerId: r};
        
        state = state.copyWith(
          isTracking: trackingResults.isNotEmpty,
          detectedMarkers: detectedMarkers,
          trackingResults: trackingResultsMap,
          errorMessage: null,
          lastUpdate: DateTime.now(),
        );
      },
    );
  }

  void setError(String error) {
    state = state.copyWith(
      errorMessage: error,
      lastUpdate: DateTime.now(),
    );
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      lastUpdate: DateTime.now(),
    );
  }
}