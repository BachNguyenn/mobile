import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kanji_card.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../../data/repositories/kanji_repository_impl.dart';
import '../../data/datasources/app_database.dart';
import 'study_event_provider.dart';
import 'progress_models.dart';
import '../../data/datasources/database_seeder.dart';
import '../../core/srs/fsrs_engine.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final kanjiRepositoryProvider = Provider<KanjiRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return KanjiRepositoryImpl(db);
});

final databaseInitializerProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(kanjiRepositoryProvider);
  final list = await repo.getAllCards();
  if (list.isEmpty) {
    final seeder = DatabaseSeeder(repo);
    await seeder.seedData();
  }
});

final kanjiListProvider = FutureProvider<List<KanjiCard>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(kanjiRepositoryProvider);
  return repo.getAllCards();
});

final kanjiSearchQueryProvider = StateProvider<String>((ref) => '');
/// Unified level filter for the Library screen
final kanjiLevelFilterProvider = StateProvider<int?>((ref) => null);

/// Kanji progress for the selected level
final kanjiProgressProvider = FutureProvider<ModuleProgress>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(kanjiRepositoryProvider);
  final level = ref.watch(kanjiLevelFilterProvider);
  
  final allCards = await repo.getAllCards();
  final filteredCards = level == null 
      ? allCards 
      : allCards.where((c) => c.jlptLevel == level).toList();
      
  final learned = filteredCards.where((c) => c.reps > 0).length;
  final total = filteredCards.length;
  final percentage = total > 0 ? learned / total : 0.0;
  
  return ModuleProgress(
    title: level == null ? 'Tất cả' : 'Trình độ N$level',
    learned: learned,
    total: total,
    percentage: percentage,
  );
});

/// Number of cards per review session
final reviewSessionLimitProvider = StateProvider<int>((ref) => 20);

/// Get due cards with level filtering, session limit, and SHUFFLE
final dueKanjiCardsProvider = FutureProvider<List<KanjiCard>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(kanjiRepositoryProvider);
  final level = ref.watch(kanjiLevelFilterProvider);
  final limit = ref.watch(reviewSessionLimitProvider);
  
  final cards = await repo.getDueCards(DateTime.now(), jlptLevel: level, limit: limit);
  
  // Shuffle cards for a varied experience
  final shuffled = List<KanjiCard>.from(cards)..shuffle();
  return shuffled;
});

/// Get total number of due cards across all levels (no limit)
final totalDueCountProvider = FutureProvider<int>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(kanjiRepositoryProvider);
  final level = ref.watch(kanjiLevelFilterProvider);
  
  final allDue = await repo.getDueCards(DateTime.now(), jlptLevel: level);
  return allDue.length;
});

final kanjiSearchResultsProvider = FutureProvider<List<KanjiCard>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(kanjiRepositoryProvider);
  final query = ref.watch(kanjiSearchQueryProvider);
  final jlptLevel = ref.watch(kanjiLevelFilterProvider);
  
  return repo.searchKanji(query, jlptLevel: jlptLevel);
});

final srsServiceProvider = Provider<SrsService>((ref) => SrsService());

/// Helper: emit study event khi user review xong 1 kanji
final emitKanjiStudyEventProvider = Provider<void Function(String cardId, int rating)>((ref) {
  final eventController = ref.watch(studyEventControllerProvider);
  final repo = ref.watch(kanjiRepositoryProvider);
  final srsService = ref.watch(srsServiceProvider);

  return (String cardId, int rating) async {
    // 1. Fetch the card
    final card = await repo.getCardById(cardId);
    if (card != null) {
      // 2. Calculate updated SRS fields using SrsService
      final updatedCard = srsService.calculateNextReview(card, rating);

      // 3. Submit review via transaction
      final expGain = rating >= 3 ? 10 : 2;
      final waterGain = rating >= 3 ? 5 : 1;
      final sunGain = rating >= 3 ? 5 : 1;

      await repo.submitReview(
        updatedItem: updatedCard,
        rating: rating,
        durationMs: 0,
        expGain: expGain,
        waterGain: waterGain,
        sunGain: sunGain,
      );
      
      // Invalidate providers to trigger UI refresh
      ref.invalidate(kanjiListProvider);
      ref.invalidate(dueKanjiCardsProvider);
      ref.invalidate(totalDueCountProvider);
      ref.invalidate(kanjiSearchResultsProvider);

      // 4. Emit the event for UI effects
      eventController.addEvent(StudyEvent(
        cardId: cardId,
        type: 'kanji',
        timestamp: DateTime.now(),
        qualityRating: rating,
      ));
    }
  };
});