import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/weakness/domain/entities/weakness_review_item.dart';

abstract class WeaknessRepository {
  Future<List<WeaknessReviewItem>> getWeakItems({
    int? jlptLevel,
    ReviewItemType? type,
    int limit = 20,
    int minAttempts = 2,
    int lookbackDays = 30,
  });
}
