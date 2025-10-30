import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/marker_definition.dart';

part 'marker_definition_model.g.dart';

@JsonSerializable()
class MarkerDefinitionModel {
  final String id;
  final String name;
  
  @JsonKey(name: 'image_url')
  final String imageUrl;
  
  final double width;
  final double height;
  
  @JsonKey(name: 'animation_id')
  final String? animationId;
  
  final Map<String, dynamic> metadata;

  const MarkerDefinitionModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.animationId,
    this.metadata = const {},
  });

  factory MarkerDefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$MarkerDefinitionModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarkerDefinitionModelToJson(this);

  MarkerDefinition toEntity() {
    return MarkerDefinition(
      id: id,
      name: name,
      imageUrl: imageUrl,
      width: width,
      height: height,
      animationId: animationId,
      metadata: metadata,
    );
  }

  factory MarkerDefinitionModel.fromEntity(MarkerDefinition entity) {
    return MarkerDefinitionModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      width: entity.width,
      height: entity.height,
      animationId: entity.animationId,
      metadata: entity.metadata,
    );
  }
}
