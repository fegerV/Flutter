class UserAsset {
  final String id;
  final String userId;
  final String assetType;
  final String name;
  final String fileUrl;
  final double fileSizeInMb;
  final DateTime uploadedAt;
  final Map<String, dynamic> metadata;

  const UserAsset({
    required this.id,
    required this.userId,
    required this.assetType,
    required this.name,
    required this.fileUrl,
    required this.fileSizeInMb,
    required this.uploadedAt,
    this.metadata = const {},
  });

  UserAsset copyWith({
    String? id,
    String? userId,
    String? assetType,
    String? name,
    String? fileUrl,
    double? fileSizeInMb,
    DateTime? uploadedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserAsset(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assetType: assetType ?? this.assetType,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSizeInMb: fileSizeInMb ?? this.fileSizeInMb,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
