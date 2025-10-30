class MarkerDefinition {
  final String id;
  final String name;
  final String imageUrl;
  final double width;
  final double height;
  final String? animationId;
  final Map<String, dynamic> metadata;

  const MarkerDefinition({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.animationId,
    this.metadata = const {},
  });

  MarkerDefinition copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? width,
    double? height,
    String? animationId,
    Map<String, dynamic>? metadata,
  }) {
    return MarkerDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      animationId: animationId ?? this.animationId,
      metadata: metadata ?? this.metadata,
    );
  }
}
