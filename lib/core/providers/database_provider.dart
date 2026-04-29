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
  final db = ref.watch(databaseProvider);
  final kanjiRepo = ref.watch(kanjiRepositoryProvider);
  final grammarRepo = ref.watch(grammarRepositoryProvider);
  final vocabRepo = ref.watch(vocabularyRepositoryProvider);

  final seeder = DatabaseSeeder(
    kanjiRepository: kanjiRepo,
    grammarRepository: grammarRepo,
    vocabularyRepository: vocabRepo,
  );

  final hasKanji =
      await (db.select(db.kanjiCardTable)..limit(1)).getSingleOrNull() != null;
  if (!hasKanji) {
    await seeder.seedKanjiData();
  }

  final hasGrammar =
      await (db.select(db.grammarTable)..limit(1)).getSingleOrNull() != null;
  if (!hasGrammar) {
    await seeder.seedGrammarData();
  }

  final hasVocab =
      await (db.select(db.vocabularyTable)..limit(1)).getSingleOrNull() != null;
  if (!hasVocab) {
    await seeder.seedVocabData();
  }
});
