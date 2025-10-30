import 'package:equatable/equatable.dart';
import 'entity.dart';

class Animation extends Entity with EquatableMixin {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final String thumbnailUrl;
  final DateTime createdAt;
  final int fileSize;
  final int duration;
  final bool isDownloaded;
  final DateTime? downloadedAt;
  final String? localPath;

  const Animation({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.fileSize,
    required this.duration,
    this.isDownloaded = false,
    this.downloadedAt,
    this.localPath,
  });

  Animation copyWith({
    String? id,
    String? title,
    String? description,
    String? fileUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    int? fileSize,
    int? duration,
    bool? isDownloaded,
    DateTime? downloadedAt,
    String? localPath,
  }) {
    return Animation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      localPath: localPath ?? this.localPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        fileUrl,
        thumbnailUrl,
        createdAt,
        fileSize,
        duration,
        isDownloaded,
        downloadedAt,
        localPath,
      ];
}