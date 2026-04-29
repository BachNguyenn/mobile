import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vocabulary.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/models/progress_models.dart';
import '../../../../core/srs/fsrs_engine.dart';
import '../../../review/presentation/providers/study_event_provider.dart';
import 'vocabulary_repository_provider.dart';

final vocabularyListProvider = FutureProvider<List<Vocabulary>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(vocabularyRepositoryProvider);
  return repo.getAllVocabulary();
});

final vocabularySearchQueryProvider = StateProvider<String>((ref) => '');
final vocabularyLevelFilterProvider = StateProvider<int?>((ref) => null);
final vocabularySrsServiceProvider = Provider<SrsService>((ref) => SrsService());

final vocabularyProgressProvider = FutureProvider<ModuleProgress>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(vocabularyRepositoryProvider);
  final level = ref.watch(vocabularyLevelFilterProvider);
  
  final allVocab = await repo.getAllVocabulary();
  final filtered = level == null 
      ? allVocab 
      : allVocab.where((v) => v.jlptLevel == level).toList();
      
  final learned = filtered.where((v) => v.reps > 0).length;
  final total = filtered.length;
  final percentage = total > 0 ? learned / total : 0.0;
  
  return ModuleProgress(
    title: level == null ? 'Tất cả' : 'Trình độ N$level',
    learned: learned,
    total: total,
    percentage: percentage,
  );
});

final dueVocabularyProvider = FutureProvider<List<Vocabulary>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(vocabularyRepositoryProvider);
  final level = ref.watch(vocabularyLevelFilterProvider);

  final vocabulary = await repo.getDueVocabulary(DateTime.now(), jlptLevel: level, limit: 20);
  return List<Vocabulary>.from(vocabulary)..shuffle();
});

final totalDueVocabularyCountProvider = FutureProvider<int>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(vocabularyRepositoryProvider);
  final level = ref.watch(vocabularyLevelFilterProvider);

  final vocabulary = await repo.getDueVocabulary(DateTime.now(), jlptLevel: level);
  return vocabulary.length;
});

final emitVocabularyStudyEventProvider = Provider<void Function(String id, int rating)>((ref) {
  final eventController = ref.watch(studyEventControllerProvider);
  final repo = ref.watch(vocabularyRepositoryProvider);
  final srsService = ref.watch(vocabularySrsServiceProvider);

  return (String id, int rating) async {
    final vocabulary = await repo.getVocabularyById(id);
    if (vocabulary == null) return;

    final updated = srsService.calculateNextVocabularyReview(vocabulary, rating);
    final expGain = rating >= 3 ? 8 : 2;
    final waterGain = rating >= 3 ? 4 : 1;
    final sunGain = rating >= 3 ? 4 : 1;

    await repo.submitReview(
      updatedItem: updated,
      rating: rating,
      durationMs: 0,
      expGain: expGain,
      waterGain: waterGain,
      sunGain: sunGain,
    );

    ref.invalidate(vocabularyListProvider);
    ref.invalidate(vocabularyProgressProvider);
    ref.invalidate(vocabularySearchResultsProvider(ref.read(vocabularySearchQueryProvider)));
    ref.invalidate(dueVocabularyProvider);
    ref.invalidate(totalDueVocabularyCountProvider);

    eventController.addEvent(StudyEvent(
      cardId: id,
      type: 'vocabulary',
      timestamp: DateTime.now(),
      qualityRating: rating,
    ));
  };
});

final vocabularySearchResultsProvider = FutureProvider.family<List<Vocabulary>, String>((ref, query) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(vocabularyRepositoryProvider);
  final jlptLevel = ref.watch(vocabularyLevelFilterProvider);
  
  return repo.searchVocabulary(query, jlptLevel: jlptLevel);
});
