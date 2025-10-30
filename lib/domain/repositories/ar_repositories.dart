import 'package:dartz/dartz.dart';
import '../entities/ar_marker.dart';
import '../entities/ar_tracking.dart';

abstract class ARMarkerRepository {
  Future<Either<Exception, MarkerConfiguration>> getMarkerConfiguration(String configId);
  Future<Either<Exception, List<ARMarker>>> getAllMarkers();
  Future<Either<Exception, ARMarker>> getMarkerById(String markerId);
  Future<Either<Exception, void>> downloadMarkerImage(String markerId, String imageUrl);
  Future<Either<Exception, void>> downloadMarkerVideo(String markerId, String videoUrl);
  Future<Either<Exception, bool>> isMarkerImageCached(String markerId);
  Future<Either<Exception, bool>> isMarkerVideoCached(String markerId);
  Future<Either<Exception, String>> getCachedMarkerImagePath(String markerId);
  Future<Either<Exception, String>> getCachedMarkerVideoPath(String markerId);
}

abstract class ARTrackingRepository {
  Future<Either<Exception, bool>> initializeARSession();
  Future<Either<Exception, void>> addMarkersToTrack(List<ARMarker> markers);
  Future<Either<Exception, ARTrackingState>> getTrackingState();
  Future<Either<Exception, List<ARTrackingResult>>> getTrackingResults();
  Future<Either<Exception, SmoothedPose>> getSmoothedPose(String markerId);
  Future<Either<Exception, void>> updateTrackingSettings(TrackingSettings settings);
  Future<Either<Exception, void>> pauseTracking();
  Future<Either<Exception, void>> resumeTracking();
  Future<Either<Exception, void>> stopTracking();
}

abstract class VideoOverlayRepository {
  Future<Either<Exception, void>> initializeVideoPlayer();
  Future<Either<Exception, void>> loadVideo(String videoUrl, String markerId);
  Future<Either<Exception, void>> playVideo(String markerId);
  Future<Either<Exception, void>> pauseVideo(String markerId);
  Future<Either<Exception, void>> stopVideo(String markerId);
  Future<Either<Exception, void>> setVideoVolume(String markerId, double volume);
  Future<Either<Exception, void>> setVideoLoop(String markerId, bool loop);
  Future<Either<Exception, VideoOverlayState>> getVideoState(String markerId);
  Future<Either<Exception, void>> updateVideoSettings(VideoSettings settings);
  Future<Either<Exception, void>> disposeVideoPlayer(String markerId);
}

abstract class PoseSmoothingRepository {
  Future<Either<Exception, SmoothedPose>> smoothPose(
    ARPose currentPose,
    ARPose? previousPose,
    double smoothingFactor,
  );
  Future<Either<Exception, bool>> isPoseStable(
    List<ARPose> recentPoses,
    double threshold,
  );
  Future<Either<Exception, double>> calculatePoseVelocity(
    ARPose currentPose,
    ARPose previousPose,
  );
  Future<Either<Exception, void>> updateSmoothingSettings(TrackingSettings settings);
}