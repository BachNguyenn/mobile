import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kanji_card.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../../data/repositories/kanji_repository_impl.dart';
import '../../data/datasources/app_database.dart';
import 'study_event_provider.dart';
import '../../data/datasources/database_seeder.dart';

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

final dueKanjiCardsProvider = FutureProvider<List<KanjiCard>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(kanjiRepositoryProvider);
  return repo.getDueCards(DateTime.now());
});

final kanjiSearchQueryProvider = StateProvider<String>((ref) => '');
final kanjiJlptFilterProvider = StateProvider<int?>((ref) => null);

final kanjiSearchResultsProvider = FutureProvider<List<KanjiCard>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(kanjiRepositoryProvider);
  final query = ref.watch(kanjiSearchQueryProvider);
  final jlptLevel = ref.watch(kanjiJlptFilterProvider);
  
  return repo.searchKanji(query, jlptLevel: jlptLevel);
});

/// Helper: emit study event khi user review xong 1 kanji
///
/// Gọi từ review screen hoặc kanji detail sau khi FSRS update:
/// ```dart
/// ref.read(emitKanjiStudyEventProvider)(cardId, qualityRating);
/// ```
final emitKanjiStudyEventProvider = Provider<void Function(String cardId, int rating)>((ref) {
  final eventController = ref.watch(studyEventControllerProvider);
  return (String cardId, int rating) {
    eventController.addEvent(StudyEvent(
      cardId: cardId,
      type: 'kanji',
      timestamp: DateTime.now(),
      qualityRating: rating,
    ));
  };
});