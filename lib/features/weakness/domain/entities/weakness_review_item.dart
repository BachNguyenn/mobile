import 'package:mobile/features/review/domain/entities/review_item.dart';

class WeaknessReviewItem {
  final ReviewItem reviewItem;
  final int attempts;
  final int misses;
  final double successRate;
  final DateTime? lastReviewedAt;

  const WeaknessReviewItem({
    required this.reviewItem,
    required this.attempts,
    required this.misses,
    required this.successRate,
    this.lastReviewedAt,
  });

  String get id => reviewItem.id;

  ReviewItemType get type => reviewItem.type;

  int get accuracyPercent => (successRate * 100).round().clamp(0, 100);
}
