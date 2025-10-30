import 'package:equatable/equatable.dart';
import 'entity.dart';

class CacheInfo extends Entity with EquatableMixin {
  final int totalSize;
  final int usedSize;
  final int itemCount;
  final DateTime lastCleanup;
  final int maxSizeLimit;
  final Duration ttl;

  const CacheInfo({
    required this.totalSize,
    required this.usedSize,
    required this.itemCount,
    required this.lastCleanup,
    required this.maxSizeLimit,
    required this.ttl,
  });

  double get usagePercentage => totalSize > 0 ? usedSize / totalSize : 0.0;

  bool get isNearLimit => usagePercentage >= 0.9;

  bool get isOverLimit => usedSize > maxSizeLimit;

  CacheInfo copyWith({
    int? totalSize,
    int? usedSize,
    int? itemCount,
    DateTime? lastCleanup,
    int? maxSizeLimit,
    Duration? ttl,
  }) {
    return CacheInfo(
      totalSize: totalSize ?? this.totalSize,
      usedSize: usedSize ?? this.usedSize,
      itemCount: itemCount ?? this.itemCount,
      lastCleanup: lastCleanup ?? this.lastCleanup,
      maxSizeLimit: maxSizeLimit ?? this.maxSizeLimit,
      ttl: ttl ?? this.ttl,
    );
  }

  @override
  List<Object?> get props => [
        totalSize,
        usedSize,
        itemCount,
        lastCleanup,
        maxSizeLimit,
        ttl,
      ];
}