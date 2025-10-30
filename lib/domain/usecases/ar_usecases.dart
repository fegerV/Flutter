import 'package:dartz/dartz.dart';
import '../entities/ar_marker.dart';
import '../entities/ar_tracking.dart';
import '../repositories/ar_repositories.dart';

class GetMarkerConfigurationUseCase {
  final ARMarkerRepository _repository;

  GetMarkerConfigurationUseCase(this._repository);

  Future<Either<Exception, MarkerConfiguration>> execute(String configId) {
    return _repository.getMarkerConfiguration(configId);
  }
}

class GetAllMarkersUseCase {
  final ARMarkerRepository _repository;

  GetAllMarkersUseCase(this._repository);

  Future<Either<Exception, List<ARMarker>>> execute() {
    return _repository.getAllMarkers();
  }
}

class SyncMarkerDataUseCase {
  final ARMarkerRepository _repository;

  SyncMarkerDataUseCase(this._repository);

  Future<Either<Exception, void>> execute(List<ARMarker> markers) async {
    for (final marker in markers) {
      // Download marker image if not cached
      final isImageCached = await _repository.isMarkerImageCached(marker.id);
      isImageCached.fold(
        (error) => return Left(error),
        (cached) async {
          if (!cached) {
            await _repository.downloadMarkerImage(marker.id, marker.imageUrl);
          }
        },
      );

      // Download marker video if exists and not cached
      if (marker.videoUrl != null) {
        final isVideoCached = await _repository.isMarkerVideoCached(marker.id);
        isVideoCached.fold(
          (error) => return Left(error),
          (cached) async {
            if (!cached) {
              await _repository.downloadMarkerVideo(marker.id, marker.videoUrl!);
            }
          },
        );
      }
    }
    return const Right(null);
  }
}

class InitializeARSessionUseCase {
  final ARTrackingRepository _repository;

  InitializeARSessionUseCase(this._repository);

  Future<Either<Exception, bool>> execute() {
    return _repository.initializeARSession();
  }
}

class StartMarkerTrackingUseCase {
  final ARTrackingRepository _repository;

  StartMarkerTrackingUseCase(this._repository);

  Future<Either<Exception, void>> execute(List<ARMarker> markers) async {
    final addResult = await _repository.addMarkersToTrack(markers);
    return addResult.fold(
      (error) => Left(error),
      (_) => _repository.resumeTracking(),
    );
  }
}

class GetTrackingResultsUseCase {
  final ARTrackingRepository _repository;

  GetTrackingResultsUseCase(this._repository);

  Future<Either<Exception, List<ARTrackingResult>>> execute() {
    return _repository.getTrackingResults();
  }
}

class GetSmoothedPoseUseCase {
  final ARTrackingRepository _repository;

  GetSmoothedPoseUseCase(this._repository);

  Future<Either<Exception, SmoothedPose>> execute(String markerId) {
    return _repository.getSmoothedPose(markerId);
  }
}

class PlayVideoOverlayUseCase {
  final VideoOverlayRepository _repository;

  PlayVideoOverlayUseCase(this._repository);

  Future<Either<Exception, void>> execute(String markerId) async {
    final stateResult = await _repository.getVideoState(markerId);
    return stateResult.fold(
      (error) => Left(error),
      (state) async {
        if (state.isLoaded) {
          return _repository.playVideo(markerId);
        } else {
          return Left(Exception('Video not loaded for marker $markerId'));
        }
      },
    );
  }
}

class PauseVideoOverlayUseCase {
  final VideoOverlayRepository _repository;

  PauseVideoOverlayUseCase(this._repository);

  Future<Either<Exception, void>> execute(String markerId) {
    return _repository.pauseVideo(markerId);
  }
}

class LoadVideoOverlayUseCase {
  final VideoOverlayRepository _repository;
  final ARMarkerRepository _markerRepository;

  LoadVideoOverlayUseCase(this._repository, this._markerRepository);

  Future<Either<Exception, void>> execute(String markerId) async {
    // Get cached video path
    final pathResult = await _markerRepository.getCachedMarkerVideoPath(markerId);
    return pathResult.fold(
      (error) => Left(error),
      (videoPath) => _repository.loadVideo(videoPath, markerId),
    );
  }
}

class HandleMarkerTrackingStateUseCase {
  final ARTrackingRepository _trackingRepository;
  final VideoOverlayRepository _videoRepository;

  HandleMarkerTrackingStateUseCase(
    this._trackingRepository,
    this._videoRepository,
  );

  Future<Either<Exception, void>> execute(
    List<ARTrackingResult> trackingResults,
    Map<String, VideoOverlayState> videoStates,
  ) async {
    for (final result in trackingResults) {
      final videoState = videoStates[result.markerId];
      
      if (result.isTracking && result.confidence > 0.7) {
        // Marker detected and confident - play video
        if (videoState == null || !videoState.isPlaying) {
          await _videoRepository.playVideo(result.markerId);
        }
      } else {
        // Marker lost or low confidence - pause video
        if (videoState != null && videoState.isPlaying) {
          await _videoRepository.pauseVideo(result.markerId);
        }
      }
    }
    
    return const Right(null);
  }
}

class ApplyPoseSmoothingUseCase {
  final PoseSmoothingRepository _repository;

  ApplyPoseSmoothingUseCase(this._repository);

  Future<Either<Exception, SmoothedPose>> execute(
    ARPose currentPose,
    ARPose? previousPose,
    double smoothingFactor,
  ) {
    return _repository.smoothPose(currentPose, previousPose, smoothingFactor);
  }
}