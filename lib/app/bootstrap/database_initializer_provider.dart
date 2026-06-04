import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/data/datasources/database_seeder.dart';
import 'package:mobile/features/grammar/application/providers/grammar_repository_provider.dart';
import 'package:mobile/features/kanji/application/providers/kanji_repository_provider.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_repository_provider.dart';

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

  // Check all three tables in parallel
  final checks = await Future.wait<bool>([
    (db.select(db.kanjiCardTable)..limit(1))
        .getSingleOrNull()
        .then((r) => r != null),
    (db.select(db.grammarTable)..limit(1))
        .getSingleOrNull()
        .then((r) => r != null),
    (db.select(db.vocabularyTable)..limit(1))
        .getSingleOrNull()
        .then((r) => r != null),
  ]);

  final hasKanji = checks[0];
  final hasGrammar = checks[1];
  final hasVocab = checks[2];

  // Seed only missing data, in parallel when possible
  final seedTasks = <Future<void>>[];
  if (!hasKanji) seedTasks.add(seeder.seedKanjiData());
  if (!hasGrammar) seedTasks.add(seeder.seedGrammarData());
  if (!hasVocab) seedTasks.add(seeder.seedVocabData());

  if (seedTasks.isNotEmpty) {
    await Future.wait(seedTasks);
  }
});
