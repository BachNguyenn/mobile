import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vocabulary.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/models/progress_models.dart';
import 'vocabulary_repository_provider.dart';

final vocabularyListProvider = FutureProvider<List<Vocabulary>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(vocabularyRepositoryProvider);
  return repo.getAllVocabulary();
});

final vocabularySearchQueryProvider = StateProvider<String>((ref) => '');
final vocabularyLevelFilterProvider = StateProvider<int?>((ref) => null);

final vocabularyProgressProvider = FutureProvider<ModuleProgress>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(vocabularyRepositoryProvider);
  final level = ref.watch(vocabularyLevelFilterProvider);
  
  final allVocab = await repo.getAllVocabulary();
  final filtered = level == null 
      ? allVocab 
      : allVocab.where((v) => v.jlptLevel == level).toList();
      
  // For now, let's assume vocabulary doesn't have individual SRS in the same way 
  // or we just use a placeholder for "learned" based on if they've seen it.
  // In a real app, vocab would also have reps/difficulty fields.
  final learned = 0; // Placeholder
  final total = filtered.length;
  final percentage = total > 0 ? learned / total : 0.0;
  
  return ModuleProgress(
    title: level == null ? 'Tất cả' : 'Trình độ N$level',
    learned: learned,
    total: total,
    percentage: percentage,
  );
});

final vocabularySearchResultsProvider = FutureProvider<List<Vocabulary>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(vocabularyRepositoryProvider);
  final query = ref.watch(vocabularySearchQueryProvider);
  final jlptLevel = ref.watch(vocabularyLevelFilterProvider);
  
  return repo.searchVocabulary(query, jlptLevel: jlptLevel);
});
