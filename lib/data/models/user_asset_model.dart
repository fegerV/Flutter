import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_asset.dart';

part 'user_asset_model.g.dart';

@JsonSerializable()
class UserAssetModel {
  final String id;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'asset_type')
  final String assetType;
  
  final String name;
  
  @JsonKey(name: 'file_url')
  final String fileUrl;
  
  @JsonKey(name: 'file_size_mb')
  final double fileSizeInMb;
  
  @JsonKey(name: 'uploaded_at')
  final String uploadedAt;
  
  final Map<String, dynamic> metadata;

  const UserAssetModel({
    required this.id,
    required this.userId,
    required this.assetType,
    required this.name,
    required this.fileUrl,
    required this.fileSizeInMb,
    required this.uploadedAt,
    this.metadata = const {},
  });

  factory UserAssetModel.fromJson(Map<String, dynamic> json) =>
      _$UserAssetModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAssetModelToJson(this);

  UserAsset toEntity() {
    return UserAsset(
      id: id,
      userId: userId,
      assetType: assetType,
      name: name,
      fileUrl: fileUrl,
      fileSizeInMb: fileSizeInMb,
      uploadedAt: DateTime.parse(uploadedAt),
      metadata: metadata,
    );
  }

  factory UserAssetModel.fromEntity(UserAsset entity) {
    return UserAssetModel(
      id: entity.id,
      userId: entity.userId,
      assetType: entity.assetType,
      name: entity.name,
      fileUrl: entity.fileUrl,
      fileSizeInMb: entity.fileSizeInMb,
      uploadedAt: entity.uploadedAt.toIso8601String(),
      metadata: entity.metadata,
    );
  }
}
