import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:vector_math/vector_math.dart';

import '../../domain/entities/ar_marker.dart';
import '../../domain/entities/ar_tracking.dart';
import '../../domain/repositories/ar_repositories.dart';

@LazySingleton(as: PoseSmoothingRepository)
class PoseSmoothingRepositoryImpl implements PoseSmoothingRepository {
  TrackingSettings _trackingSettings = const TrackingSettings();
  final Map<String, List<ARPose>> _poseHistory = {};
  final Map<String, ARPose> _lastSmoothedPoses = {};

  @override
  Future<Either<Exception, SmoothedPose>> smoothPose(
    ARPose currentPose,
    ARPose? previousPose,
    double smoothingFactor,
  ) async {
    try {
      ARPose smoothedPose;

      if (previousPose == null) {
        // No previous pose, use current as is
        smoothedPose = currentPose;
      } else {
        // Apply smoothing algorithm
        smoothedPose = _applySmoothingAlgorithm(
          currentPose,
          previousPose,
          smoothingFactor,
        );
      }

      // Calculate velocity and stability
      final velocity = _calculatePoseVelocity(currentPose, previousPose);
      final isStable = await _isPoseStableInternal(currentPose);

      final result = SmoothedPose(
        currentPose: currentPose,
        smoothedPose: smoothedPose,
        smoothingFactor: smoothingFactor,
        isStable: isStable,
        velocity: velocity,
        timestamp: DateTime.now(),
      );

      return Right(result);
    } catch (e) {
      return Left(Exception('Failed to smooth pose: $e'));
    }
  }

  @override
  Future<Either<Exception, bool>> isPoseStable(
    List<ARPose> recentPoses,
    double threshold,
  ) async {
    try {
      if (recentPoses.length < 3) {
        return const Right(false);
      }

      double totalVariation = 0.0;
      int comparisons = 0;

      // Compare consecutive poses
      for (int i = 1; i < recentPoses.length; i++) {
        final current = recentPoses[i];
        final previous = recentPoses[i - 1];

        // Calculate position variation
        final positionVariation = current.position.distanceTo(previous.position);
        
        // Calculate rotation variation
        final rotationVariation = _calculateRotationDifference(
          current.rotation,
          previous.rotation,
        );

        // Calculate scale variation
        final scaleVariation = (current.scale - previous.scale).length;

        // Weight the variations (position is most important)
        totalVariation += (positionVariation * 0.6) + 
                         (rotationVariation * 0.3) + 
                         (scaleVariation * 0.1);
        comparisons++;
      }

      final averageVariation = totalVariation / comparisons;
      return Right(averageVariation < threshold);
    } catch (e) {
      return Left(Exception('Failed to check pose stability: $e'));
    }
  }

  @override
  Future<Either<Exception, double>> calculatePoseVelocity(
    ARPose currentPose,
    ARPose previousPose,
  ) async {
    try {
      if (previousPose == null) {
        return const Right(0.0);
      }

      final velocity = _calculatePoseVelocity(currentPose, previousPose);
      return Right(velocity);
    } catch (e) {
      return Left(Exception('Failed to calculate pose velocity: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateSmoothingSettings(TrackingSettings settings) async {
    try {
      _trackingSettings = settings;
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to update smoothing settings: $e'));
    }
  }

  ARPose _applySmoothingAlgorithm(
    ARPose currentPose,
    ARPose previousPose,
    double smoothingFactor,
  ) {
    // Exponential moving average smoothing
    final smoothedPosition = Vector3.lerp(
      previousPose.position,
      currentPose.position,
      smoothingFactor,
    );

    // Spherical linear interpolation for rotation
    final smoothedRotation = previousPose.rotation.slerp(
      currentPose.rotation,
      smoothingFactor,
    );

    // Linear interpolation for scale
    final smoothedScale = Vector3.lerp(
      previousPose.scale,
      currentPose.scale,
      smoothingFactor,
    );

    // Combine into new transform matrix
    final smoothedTransform = Matrix4.compose(
      smoothedPosition,
      smoothedRotation,
      smoothedScale,
    );

    return ARPose(
      transform: smoothedTransform,
      position: smoothedPosition,
      rotation: smoothedRotation,
      scale: smoothedScale,
      confidence: (currentPose.confidence + previousPose.confidence) / 2,
      timestamp: DateTime.now(),
    );
  }

  double _calculatePoseVelocity(ARPose currentPose, ARPose? previousPose) {
    if (previousPose == null) return 0.0;

    final distance = currentPose.position.distanceTo(previousPose.position);
    final timeDelta = currentPose.timestamp.difference(previousPose.timestamp).inMilliseconds;
    
    if (timeDelta <= 0) return 0.0;
    
    return distance / (timeDelta / 1000.0); // Convert to units per second
  }

  Future<bool> _isPoseStableInternal(ARPose pose) async {
    // Quick stability check based on confidence and movement
    return pose.confidence > 0.8;
  }

  double _calculateRotationDifference(Quaternion q1, Quaternion q2) {
    // Calculate angular difference between two quaternions
    final dotProduct = q1.dot(q2);
    final angle = 2.0 * acos(dotProduct.abs().clamp(0.0, 1.0));
    return angle;
  }

  // Advanced smoothing with Kalman filter-like approach
  ARPose _applyKalmanSmoothing(
    ARPose currentPose,
    String markerId,
  ) {
    final history = _poseHistory[markerId] ?? [];
    final lastSmoothed = _lastSmoothedPoses[markerId];

    if (history.length < 2 || lastSmoothed == null) {
      _lastSmoothedPoses[markerId] = currentPose;
      return currentPose;
    }

    // Simple Kalman-like prediction and update
    final predictedPose = _predictPose(lastSmoothed, history.last);
    final smoothedPose = _updatePose(predictedPose, currentPose);

    _lastSmoothedPoses[markerId] = smoothedPose;
    return smoothedPose;
  }

  ARPose _predictPose(ARPose lastSmoothed, ARPose lastMeasured) {
    // Simple linear prediction based on velocity
    final deltaTime = lastMeasured.timestamp.difference(lastSmoothed.timestamp).inMilliseconds / 1000.0;
    final velocity = _calculatePoseVelocity(lastMeasured, lastSmoothed);
    
    // Predict next position
    final direction = (lastMeasured.position - lastSmoothed.position).normalized();
    final predictedPosition = lastMeasured.position + (direction * velocity * deltaTime);

    // Predict rotation (simple interpolation)
    final predictedRotation = lastSmoothed.rotation.slerp(
      lastMeasured.rotation,
      0.5,
    );

    return ARPose(
      transform: Matrix4.compose(
        predictedPosition,
        predictedRotation,
        lastMeasured.scale,
      ),
      position: predictedPosition,
      rotation: predictedRotation,
      scale: lastMeasured.scale,
      confidence: lastMeasured.confidence * 0.9, // Reduce confidence for predictions
      timestamp: DateTime.now(),
    );
  }

  ARPose _updatePose(ARPose predicted, ARPose measured) {
    // Combine prediction with measurement
    final kalmanGain = 0.3; // Adjust based on confidence
    
    final updatedPosition = Vector3.lerp(
      predicted.position,
      measured.position,
      kalmanGain,
    );

    final updatedRotation = predicted.rotation.slerp(
      measured.rotation,
      kalmanGain,
    );

    return ARPose(
      transform: Matrix4.compose(
        updatedPosition,
        updatedRotation,
        measured.scale,
      ),
      position: updatedPosition,
      rotation: updatedRotation,
      scale: measured.scale,
      confidence: (predicted.confidence + measured.confidence) / 2,
      timestamp: DateTime.now(),
    );
  }

  // Public method to update pose history for advanced smoothing
  void updatePoseHistory(String markerId, ARPose pose) {
    final history = _poseHistory[markerId] ?? [];
    history.add(pose);
    
    // Keep only recent poses (last 20 for better smoothing)
    if (history.length > 20) {
      history.removeAt(0);
    }
    
    _poseHistory[markerId] = history;
  }

  // Clear pose history for a marker
  void clearPoseHistory(String markerId) {
    _poseHistory.remove(markerId);
    _lastSmoothedPoses.remove(markerId);
  }

  // Clear all pose history
  void clearAllPoseHistory() {
    _poseHistory.clear();
    _lastSmoothedPoses.clear();
  }
}