import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/app/bootstrap/database_initializer_provider.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/weakness/domain/entities/weakness_review_item.dart';
import 'package:mobile/features/weakness/domain/repositories/weakness_repository.dart';

final weaknessRepositoryProvider = Provider<WeaknessRepository>((ref) {
  throw UnimplementedError('weaknessRepositoryProvider must be overridden');
});

final weaknessLevelFilterProvider = StateProvider<int?>((ref) => null);
final weaknessTypeFilterProvider = StateProvider<ReviewItemType?>(
  (ref) => null,
);

final weakItemsProvider = FutureProvider<List<WeaknessReviewItem>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repository = ref.watch(weaknessRepositoryProvider);
  final jlptLevel = ref.watch(weaknessLevelFilterProvider);
  final type = ref.watch(weaknessTypeFilterProvider);
  return repository.getWeakItems(jlptLevel: jlptLevel, type: type, limit: 30);
});

final weakReviewItemsProvider = FutureProvider<List<ReviewItem>>((ref) async {
  final items = await ref.watch(weakItemsProvider.future);
  return items.take(10).map((item) => item.reviewItem).toList(growable: false);
});
