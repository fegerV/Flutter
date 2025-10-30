import 'package:equatable/equatable.dart';

class Recording extends Equatable {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  final int fileSizeBytes;
  final bool hasAudio;
  final RecordingStatus status;

  const Recording({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.duration,
    required this.fileSizeBytes,
    required this.hasAudio,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        filePath,
        createdAt,
        duration,
        fileSizeBytes,
        hasAudio,
        status,
      ];

  Recording copyWith({
    String? id,
    String? filePath,
    DateTime? createdAt,
    Duration? duration,
    int? fileSizeBytes,
    bool? hasAudio,
    RecordingStatus? status,
  }) {
    return Recording(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      hasAudio: hasAudio ?? this.hasAudio,
      status: status ?? this.status,
    );
  }
}

enum RecordingStatus {
  recording,
  paused,
  completed,
  saved,
  error,
}