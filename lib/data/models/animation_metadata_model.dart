import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/animation_metadata.dart';

part 'animation_metadata_model.g.dart';

@JsonSerializable()
class AnimationMetadataModel {
  final String id;
  final String name;
  final String description;
  
  @JsonKey(name: 'file_url')
  final String fileUrl;
  
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;
  
  @JsonKey(name: 'file_size_mb')
  final double fileSizeInMb;
  
  @JsonKey(name: 'duration_seconds')
  final int durationInSeconds;
  
  final List<String> tags;
  
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const AnimationMetadataModel({
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

  factory AnimationMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$AnimationMetadataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnimationMetadataModelToJson(this);

  AnimationMetadata toEntity() {
    return AnimationMetadata(
      id: id,
      name: name,
      description: description,
      fileUrl: fileUrl,
      thumbnailUrl: thumbnailUrl,
      fileSizeInMb: fileSizeInMb,
      durationInSeconds: durationInSeconds,
      tags: tags,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  factory AnimationMetadataModel.fromEntity(AnimationMetadata entity) {
    return AnimationMetadataModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      fileUrl: entity.fileUrl,
      thumbnailUrl: entity.thumbnailUrl,
      fileSizeInMb: entity.fileSizeInMb,
      durationInSeconds: entity.durationInSeconds,
      tags: entity.tags,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
