import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_database.dart';
import '../../features/kanji/presentation/providers/kanji_repository_provider.dart';
import '../../features/grammar/presentation/providers/grammar_repository_provider.dart';
import '../../features/vocabulary/presentation/providers/vocabulary_repository_provider.dart';
import '../../data/datasources/database_seeder.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final databaseInitializerProvider = FutureProvider<void>((ref) async {
  final kanjiRepo = ref.watch(kanjiRepositoryProvider);
  final grammarRepo = ref.watch(grammarRepositoryProvider);
  final vocabRepo = ref.watch(vocabularyRepositoryProvider);
  
  final seeder = DatabaseSeeder(
    kanjiRepository: kanjiRepo,
    grammarRepository: grammarRepo,
    vocabularyRepository: vocabRepo,
  );

  final kanjiList = await kanjiRepo.getAllCards();
  if (kanjiList.isEmpty) {
    await seeder.seedKanjiData();
  }

  final grammarList = await grammarRepo.getAllGrammarPoints();
  if (grammarList.isEmpty) {
    await seeder.seedGrammarData();
  }

  final vocabList = await vocabRepo.getAllVocabulary();
  if (vocabList.isEmpty) {
    await seeder.seedVocabData();
  }
});
