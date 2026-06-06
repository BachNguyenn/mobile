import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Read the minimum possible row from each content table to check if they are completely empty.
  final checks = await Future.wait<bool>([
    (db.select(db.kanjiCardTable)..limit(1)).getSingleOrNull().then((r) => r == null),
    (db.select(db.grammarTable)..limit(1)).getSingleOrNull().then((r) => r == null),
    (db.select(db.vocabularyTable)..limit(1)).getSingleOrNull().then((r) => r == null),
  ]);

  final isKanjiEmpty = checks[0];
  final isGrammarEmpty = checks[1];
  final isVocabEmpty = checks[2];

  // Retrieve the seeded schema version from SharedPreferences.
  // This allows us to re-seed only when the app is first installed or when
  // the database schema version is bumped (upgrade).
  final prefs = await SharedPreferences.getInstance();
  final seededVersion = prefs.getInt('seeded_data_version') ?? 0;
  final currentVersion = db.schemaVersion;

  final needsKanjiSeed = isKanjiEmpty || seededVersion < currentVersion;
  final needsGrammarSeed = isGrammarEmpty || seededVersion < currentVersion;
  final needsVocabSeed = isVocabEmpty || seededVersion < currentVersion;

  // Seed only the missing libraries; existing user progress stays untouched.
  final seedTasks = <Future<void>>[];
  if (needsKanjiSeed) seedTasks.add(seeder.seedKanjiData());
  if (needsGrammarSeed) seedTasks.add(seeder.seedGrammarData());
  if (needsVocabSeed) seedTasks.add(seeder.seedVocabData());

  if (seedTasks.isNotEmpty) {
    await Future.wait(seedTasks);
    await prefs.setInt('seeded_data_version', currentVersion);
  }
});

