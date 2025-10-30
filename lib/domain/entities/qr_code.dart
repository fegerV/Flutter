import 'package:equatable/equatable.dart';
import 'entity.dart';

class QRCode extends Entity with EquatableMixin {
  final String rawValue;
  final String? animationId;
  final String? type;
  final DateTime scannedAt;
  final Map<String, dynamic>? metadata;

  const QRCode({
    required this.rawValue,
    this.animationId,
    this.type,
    required this.scannedAt,
    this.metadata,
  });

  bool get isValidAnimationQR => animationId != null && animationId!.isNotEmpty;

  QRCode copyWith({
    String? rawValue,
    String? animationId,
    String? type,
    DateTime? scannedAt,
    Map<String, dynamic>? metadata,
  }) {
    return QRCode(
      rawValue: rawValue ?? this.rawValue,
      animationId: animationId ?? this.animationId,
      type: type ?? this.type,
      scannedAt: scannedAt ?? this.scannedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        rawValue,
        animationId,
        type,
        scannedAt,
        metadata,
      ];
}