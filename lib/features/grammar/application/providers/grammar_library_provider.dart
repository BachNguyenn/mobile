import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/app/bootstrap/database_initializer_provider.dart';
import '../../domain/entities/grammar_point.dart';
import 'grammar_repository_provider.dart';
import '../../../../core/models/progress_models.dart';
import '../../../review/application/providers/study_event_provider.dart';

const grammarLibraryResultLimit = 160;
const grammarSearchResultLimit = 80;

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

  final results = await Future.wait<int>([
    repo.countLearnedGrammar(jlptLevel: level),
    repo.countGrammarPoints(jlptLevel: level),
  ]);
  final learned = results[0];
  final total = results[1];
  final percentage = total > 0 ? learned / total : 0.0;

  return ModuleProgress(
    title: level == null ? 'Tất cả' : 'Trình độ N$level',
    learned: learned,
    total: total,
    percentage: percentage,
  );
});

final dueGrammarProvider = FutureProvider<List<GrammarPoint>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(grammarRepositoryProvider);
  final level = ref.watch(grammarLevelFilterProvider);

  return repo.getDueGrammar(jlptLevel: level, limit: 20);
});

final totalDueGrammarCountProvider = FutureProvider<int>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(grammarRepositoryProvider);
  final level = ref.watch(grammarLevelFilterProvider);

  return repo.countDueGrammar(jlptLevel: level);
});

final emitGrammarStudyEventProvider =
    Provider<Future<void> Function(String id, int rating)>((ref) {
      final eventController = ref.watch(studyEventControllerProvider);
      final repo = ref.watch(grammarRepositoryProvider);

      return (String id, int rating) async {
        final expGain = rating >= 3 ? 8 : 2;
        final waterGain = rating >= 3 ? 4 : 1;
        final sunGain = rating >= 3 ? 4 : 1;

        await repo.submitReview(
          grammarId: id,
          rating: rating,
          durationMs: 0,
          expGain: expGain,
          waterGain: waterGain,
          sunGain: sunGain,
        );

        ref.invalidate(grammarListProvider);
        ref.invalidate(grammarProgressProvider);
        ref.invalidate(
          grammarSearchResultsProvider(ref.read(grammarSearchQueryProvider)),
        );
        ref.invalidate(dueGrammarProvider);
        ref.invalidate(totalDueGrammarCountProvider);

        eventController.addEvent(
          StudyEvent(
            cardId: id,
            type: 'grammar',
            timestamp: DateTime.now(),
            qualityRating: rating,
          ),
        );
      };
    });

final grammarSearchResultsProvider =
    FutureProvider.family<List<GrammarPoint>, String>((ref, query) async {
      await ref.watch(databaseInitializerProvider.future);
      final repo = ref.watch(grammarRepositoryProvider);
      final jlptLevel = ref.watch(grammarLevelFilterProvider);
      final trimmedQuery = query.trim();

      return repo.searchGrammar(
        trimmedQuery,
        jlptLevel: jlptLevel,
        limit: trimmedQuery.isEmpty
            ? grammarLibraryResultLimit
            : grammarSearchResultLimit,
      );
    });
