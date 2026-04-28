import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/grammar_point.dart';
import '../../../../core/providers/database_provider.dart';
import 'grammar_repository_provider.dart';
import '../../../../core/models/progress_models.dart';

final grammarListProvider = FutureProvider<List<GrammarPoint>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(grammarRepositoryProvider);
  return repo.getAllGrammarPoints();
});

final grammarSearchQueryProvider = StateProvider<String>((ref) => '');
final grammarLevelFilterProvider = StateProvider<int?>((ref) => null);

final grammarProgressProvider = FutureProvider<ModuleProgress>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(grammarRepositoryProvider);
  final level = ref.watch(grammarLevelFilterProvider);
  
  final allGrammar = await repo.getAllGrammarPoints();
  final filtered = level == null 
      ? allGrammar 
      : allGrammar.where((g) => g.jlptLevel == level).toList();
      
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

final grammarSearchResultsProvider = FutureProvider<List<GrammarPoint>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(grammarRepositoryProvider);
  final query = ref.watch(grammarSearchQueryProvider);
  final jlptLevel = ref.watch(grammarLevelFilterProvider);
  
  return repo.searchGrammar(query, jlptLevel: jlptLevel);
});
