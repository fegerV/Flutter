import 'dart:async';
import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/ar_marker.dart';
import '../../domain/entities/ar_tracking.dart';
import '../../domain/repositories/ar_repositories.dart';

@LazySingleton(as: VideoOverlayRepository)
class VideoOverlayRepositoryImpl implements VideoOverlayRepository {
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, VideoOverlayState> _videoStates = {};
  VideoSettings _videoSettings = const VideoSettings();

  @override
  Future<Either<Exception, void>> initializeVideoPlayer() async {
    try {
      // Initialize any global video player settings
      VideoPlayerController.setVolume(0.0); // Default to muted for AR
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to initialize video player: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> loadVideo(String videoUrl, String markerId) async {
    try {
      // Dispose existing controller if any
      final existingController = _controllers[markerId];
      if (existingController != null) {
        await existingController.dispose();
        _controllers.remove(markerId);
      }

      // Create new controller
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controllers[markerId] = controller;

      // Initialize controller
      await controller.initialize();

      // Apply video settings
      controller.setLooping(_videoSettings.loop);
      controller.setVolume(_videoSettings.enableAudio ? _videoSettings.volume : 0.0);

      // Update video state
      _videoStates[markerId] = VideoOverlayState(
        markerId: markerId,
        isLoaded: true,
        isPlaying: false,
        duration: controller.value.duration,
        lastUpdate: DateTime.now(),
      );

      // Set up listener for state changes
      controller.addListener(() => _onVideoStateChange(markerId, controller));

      return const Right(null);
    } catch (e) {
      _videoStates[markerId] = VideoOverlayState(
        markerId: markerId,
        hasError: true,
        errorMessage: 'Failed to load video: $e',
        lastUpdate: DateTime.now(),
      );
      return Left(Exception('Failed to load video: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> playVideo(String markerId) async {
    try {
      final controller = _controllers[markerId];
      if (controller == null) {
        return Left(Exception('No video controller found for marker $markerId'));
      }

      if (controller.value.isInitialized) {
        await controller.play();
        
        _videoStates[markerId] = _videoStates[markerId]?.copyWith(
          isPlaying: true,
          lastUpdate: DateTime.now(),
        ) ?? VideoOverlayState(
          markerId: markerId,
          isPlaying: true,
          lastUpdate: DateTime.now(),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to play video: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> pauseVideo(String markerId) async {
    try {
      final controller = _controllers[markerId];
      if (controller == null) {
        return Left(Exception('No video controller found for marker $markerId'));
      }

      if (controller.value.isPlaying) {
        await controller.pause();
        
        _videoStates[markerId] = _videoStates[markerId]?.copyWith(
          isPlaying: false,
          lastUpdate: DateTime.now(),
        ) ?? VideoOverlayState(
          markerId: markerId,
          isPlaying: false,
          lastUpdate: DateTime.now(),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to pause video: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> stopVideo(String markerId) async {
    try {
      final controller = _controllers[markerId];
      if (controller == null) {
        return Left(Exception('No video controller found for marker $markerId'));
      }

      await controller.pause();
      await controller.seekTo(Duration.zero);
      
      _videoStates[markerId] = _videoStates[markerId]?.copyWith(
        isPlaying: false,
        position: Duration.zero,
        lastUpdate: DateTime.now(),
      ) ?? VideoOverlayState(
        markerId: markerId,
        isPlaying: false,
        position: Duration.zero,
        lastUpdate: DateTime.now(),
      );

      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to stop video: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> setVideoVolume(String markerId, double volume) async {
    try {
      final controller = _controllers[markerId];
      if (controller == null) {
        return Left(Exception('No video controller found for marker $markerId'));
      }

      await controller.setVolume(volume);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to set video volume: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> setVideoLoop(String markerId, bool loop) async {
    try {
      final controller = _controllers[markerId];
      if (controller == null) {
        return Left(Exception('No video controller found for marker $markerId'));
      }

      controller.setLooping(loop);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to set video loop: $e'));
    }
  }

  @override
  Future<Either<Exception, VideoOverlayState>> getVideoState(String markerId) async {
    try {
      final state = _videoStates[markerId];
      if (state == null) {
        return Left(Exception('No video state found for marker $markerId'));
      }

      // Update current position from controller
      final controller = _controllers[markerId];
      if (controller != null && controller.value.isInitialized) {
        return Right(state.copyWith(
          position: controller.value.position,
          lastUpdate: DateTime.now(),
        ));
      }

      return Right(state);
    } catch (e) {
      return Left(Exception('Failed to get video state: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateVideoSettings(VideoSettings settings) async {
    try {
      _videoSettings = settings;

      // Apply settings to all existing controllers
      for (final entry in _controllers.entries) {
        final markerId = entry.key;
        final controller = entry.value;

        if (controller.value.isInitialized) {
          controller.setLooping(settings.loop);
          controller.setVolume(settings.enableAudio ? settings.volume : 0.0);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to update video settings: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> disposeVideoPlayer(String markerId) async {
    try {
      final controller = _controllers[markerId];
      if (controller != null) {
        await controller.dispose();
        _controllers.remove(markerId);
      }

      _videoStates.remove(markerId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to dispose video player: $e'));
    }
  }

  void _onVideoStateChange(String markerId, VideoPlayerController controller) {
    final currentState = _videoStates[markerId];
    if (currentState == null) return;

    final videoState = currentState.copyWith(
      isPlaying: controller.value.isPlaying,
      position: controller.value.position,
      duration: controller.value.duration,
      hasError: controller.value.hasError,
      errorMessage: controller.value.errorDescription,
      lastUpdate: DateTime.now(),
    );

    _videoStates[markerId] = videoState;
  }

  // Helper method to get video controller for UI rendering
  VideoPlayerController? getController(String markerId) {
    return _controllers[markerId];
  }

  // Helper method to get all video states
  Map<String, VideoOverlayState> getAllVideoStates() {
    return Map.unmodifiable(_videoStates);
  }

  // Dispose all controllers
  Future<void> disposeAll() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
    _videoStates.clear();
  }
}