class AnimationMetadata {
  final String id;
  final String name;
  final String description;
  final String fileUrl;
  final String thumbnailUrl;
  final double fileSizeInMb;
  final int durationInSeconds;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AnimationMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.fileSizeInMb,
    required this.durationInSeconds,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  AnimationMetadata copyWith({
    String? id,
    String? name,
    String? description,
    String? fileUrl,
    String? thumbnailUrl,
    double? fileSizeInMb,
    int? durationInSeconds,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnimationMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileSizeInMb: fileSizeInMb ?? this.fileSizeInMb,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
