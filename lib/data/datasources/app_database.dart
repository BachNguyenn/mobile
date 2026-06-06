import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/services/app_logger.dart';
import '../../features/kanji/domain/entities/kanji_card.dart';

part 'app_database.g.dart';

@DataClassName('KanjiCardData')
class KanjiCardTable extends Table {
  TextColumn get id => text()();
  TextColumn get kanji => text()();
  TextColumn get meanings => text()();
  TextColumn get onyomi => text()();
  TextColumn get kunyomi => text()();
  TextColumn get strokeData => text().nullable().named('stroke_data')();
  IntColumn get jlptLevel =>
      integer().withDefault(const Constant(5)).named('jlpt_level')();
  TextColumn get radicalsJson =>
      text().withDefault(const Constant('[]')).named('radicals_json')();
  TextColumn get mnemonic => text().nullable()();
  TextColumn get relatedWordsJson =>
      text().withDefault(const Constant('[]')).named('related_words_json')();
  TextColumn get strokePathsJson =>
      text().withDefault(const Constant('[]')).named('stroke_paths_json')();
  IntColumn get strokeCount => integer().nullable().named('stroke_count')();
  IntColumn get grade => integer().nullable()();
  IntColumn get frequency => integer().nullable()();
  IntColumn get radicalNumber => integer().nullable().named('radical_number')();
  TextColumn get radicalNamesJson =>
      text().withDefault(const Constant('[]')).named('radical_names_json')();
  TextColumn get nanoriJson =>
      text().withDefault(const Constant('[]')).named('nanori_json')();
  TextColumn get variantsJson =>
      text().withDefault(const Constant('[]')).named('variants_json')();
  TextColumn get queryCodesJson =>
      text().withDefault(const Constant('[]')).named('query_codes_json')();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastReview => dateTime().nullable().named('last_review')();
  DateTimeColumn get nextReview => dateTime().named('next_review')();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  IntColumn get state => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class VocabularyTable extends Table {
  TextColumn get id => text()();
  TextColumn get word => text()();
  TextColumn get reading => text()();
  TextColumn get meaning => text()();
  IntColumn get jlptLevel =>
      integer().withDefault(const Constant(5)).named('jlpt_level')();
  TextColumn get exampleSentencesJson => text()
      .withDefault(const Constant('[]'))
      .named('example_sentences_json')();
  TextColumn get imageUrl => text().nullable().named('image_url')();
  TextColumn get pitchAccent => text().nullable().named('pitch_accent')();
  TextColumn get partOfSpeech => text().nullable().named('part_of_speech')();

  // SRS Fields
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastReview => dateTime().nullable().named('last_review')();
  DateTimeColumn get nextReview => dateTime().named('next_review')();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  IntColumn get state => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class GrammarTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get structure => text()();
  TextColumn get explanation => text()();
  TextColumn get example => text()();
  IntColumn get jlptLevel =>
      integer().withDefault(const Constant(5)).named('jlpt_level')();
  BoolColumn get isLearned =>
      boolean().withDefault(const Constant(false)).named('is_learned')();

  @override
  Set<Column> get primaryKey => {id};
}

class ZenGardenTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get water => integer().withDefault(const Constant(0))();
  IntColumn get sunlight => integer().withDefault(const Constant(0))();
  IntColumn get exp => integer().withDefault(const Constant(0))();
  TextColumn get plantsJson =>
      text().withDefault(const Constant('[]')).named('plants_json')();
  DateTimeColumn get lastLogin => dateTime().nullable().named('last_login')();
}

class ReviewLogTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemId => text().named('item_id')();
  TextColumn get itemType => text().named('item_type')();
  IntColumn get rating => integer()();
  DateTimeColumn get reviewTime => dateTime().named('review_time')();
  IntColumn get durationMs =>
      integer().withDefault(const Constant(0)).named('duration_ms')();
}

class LessonTable extends Table {
  TextColumn get id => text()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false)).named('is_completed')();

  @override
  Set<Column> get primaryKey => {id};
}

class StudyLogTable extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(
  tables: [
    KanjiCardTable,
    VocabularyTable,
    GrammarTable,
    ZenGardenTable,
    LessonTable,
    StudyLogTable,
    ReviewLogTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createPerformanceIndexes();
      // Create FTS5 table
      await customStatement('''
            CREATE VIRTUAL TABLE kanji_search_table USING fts5(
              id, meanings, onyomi, kunyomi,
              tokenize='unicode61'
            );
          ''');
      // Create triggers for FTS5
      await customStatement('''
            CREATE TRIGGER kanji_card_insert AFTER INSERT ON kanji_card_table BEGIN
              DELETE FROM kanji_search_table WHERE id = new.id;
              INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
              VALUES (new.id, new.meanings, new.onyomi, new.kunyomi);
            END;
          ''');
      await customStatement('''
            CREATE TRIGGER kanji_card_update AFTER UPDATE ON kanji_card_table BEGIN
              DELETE FROM kanji_search_table WHERE id = new.id;
              INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
              VALUES (new.id, new.meanings, new.onyomi, new.kunyomi);
            END;
          ''');
      await customStatement('''
            CREATE TRIGGER kanji_card_delete AFTER DELETE ON kanji_card_table BEGIN
              DELETE FROM kanji_search_table WHERE id = old.id;
            END;
          ''');
      await _createVocabularySearchTable(withBackfill: false);
      await _createGrammarSearchTable(withBackfill: false);
    },
    onUpgrade: (m, from, to) async {
      if (from < 6) {
        await customStatement('''
              CREATE VIRTUAL TABLE kanji_search_table USING fts5(
                id, meanings, onyomi, kunyomi,
                tokenize='unicode61'
              );
            ''');
        // Index existing data
        await customStatement('''
              INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
              SELECT id, meanings, onyomi, kunyomi FROM kanji_card_table;
            ''');
        // Add triggers
        await customStatement('''
              CREATE TRIGGER kanji_card_insert AFTER INSERT ON kanji_card_table BEGIN
                DELETE FROM kanji_search_table WHERE id = new.id;
                INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
                VALUES (new.id, new.meanings, new.onyomi, new.kunyomi);
              END;
            ''');
        await customStatement('''
              CREATE TRIGGER kanji_card_update AFTER UPDATE ON kanji_card_table BEGIN
                DELETE FROM kanji_search_table WHERE id = new.id;
                INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
                VALUES (new.id, new.meanings, new.onyomi, new.kunyomi);
              END;
            ''');
        await customStatement('''
              CREATE TRIGGER kanji_card_delete AFTER DELETE ON kanji_card_table BEGIN
                DELETE FROM kanji_search_table WHERE id = old.id;
              END;
            ''');
      }
      if (from < 7) {
        await m.addColumn(zenGardenTable, zenGardenTable.lastLogin);
        await m.createTable(reviewLogTable);
      }
      if (from < 8) {
        // Ensure all required tables are created if missing from previous version upgrades
        await _createTableIfNotExist(m, vocabularyTable);
        await _createTableIfNotExist(m, grammarTable);
        await _createTableIfNotExist(m, lessonTable);
        await _createTableIfNotExist(m, studyLogTable);
      }
      if (from < 9) {
        // Recreate triggers with proper Unicode handling (DELETE then INSERT pattern)
        try {
          await customStatement('DROP TRIGGER IF EXISTS kanji_card_insert;');
          await customStatement('DROP TRIGGER IF EXISTS kanji_card_update;');
          await customStatement('DROP TRIGGER IF EXISTS kanji_card_delete;');
        } catch (error, stackTrace) {
          AppLogger.warning(
            'Failed to drop legacy kanji search triggers',
            error: error,
            stackTrace: stackTrace,
          );
        }

        await customStatement('''
              CREATE TRIGGER kanji_card_insert AFTER INSERT ON kanji_card_table BEGIN
                DELETE FROM kanji_search_table WHERE id = new.id;
                INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
                VALUES (new.id, new.meanings, new.onyomi, new.kunyomi);
              END;
            ''');
        await customStatement('''
              CREATE TRIGGER kanji_card_update AFTER UPDATE ON kanji_card_table BEGIN
                DELETE FROM kanji_search_table WHERE id = new.id;
                INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
                VALUES (new.id, new.meanings, new.onyomi, new.kunyomi);
              END;
            ''');
        await customStatement('''
              CREATE TRIGGER kanji_card_delete AFTER DELETE ON kanji_card_table BEGIN
                DELETE FROM kanji_search_table WHERE id = old.id;
              END;
            ''');
      }
      if (from < 10) {
        await m.addColumn(kanjiCardTable, kanjiCardTable.radicalsJson);
        await m.addColumn(kanjiCardTable, kanjiCardTable.mnemonic);
        await m.addColumn(kanjiCardTable, kanjiCardTable.relatedWordsJson);
        await m.addColumn(
          vocabularyTable,
          vocabularyTable.exampleSentencesJson,
        );
        await m.addColumn(vocabularyTable, vocabularyTable.imageUrl);
        await m.addColumn(vocabularyTable, vocabularyTable.pitchAccent);
        await m.addColumn(vocabularyTable, vocabularyTable.partOfSpeech);
      }
      if (from < 11) {
        await _createPerformanceIndexes();
      }
      if (from < 12) {
        await _createVocabularySearchTable();
        await _createGrammarSearchTable();
      }
      if (from < 13) {
        await m.addColumn(kanjiCardTable, kanjiCardTable.strokePathsJson);
        await m.addColumn(kanjiCardTable, kanjiCardTable.strokeCount);
        await m.addColumn(kanjiCardTable, kanjiCardTable.grade);
        await m.addColumn(kanjiCardTable, kanjiCardTable.frequency);
        await m.addColumn(kanjiCardTable, kanjiCardTable.radicalNumber);
        await m.addColumn(kanjiCardTable, kanjiCardTable.radicalNamesJson);
        await m.addColumn(kanjiCardTable, kanjiCardTable.nanoriJson);
        await m.addColumn(kanjiCardTable, kanjiCardTable.variantsJson);
        await m.addColumn(kanjiCardTable, kanjiCardTable.queryCodesJson);
      }
    },
  );

  Future<void> _createPerformanceIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_kanji_level ON kanji_card_table(jlpt_level);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_kanji_due_level ON kanji_card_table(next_review, jlpt_level);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocabulary_level ON vocabulary_table(jlpt_level);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocabulary_due_level ON vocabulary_table(next_review, jlpt_level);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_level_learned ON grammar_table(jlpt_level, is_learned);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_review_log_time_type ON review_log_table(review_time, item_type);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_study_log_date ON study_log_table(date);',
    );
  }

  Future<void> _createVocabularySearchTable({bool withBackfill = true}) async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS vocabulary_search_table USING fts5(
        id, word, reading, meaning, example_sentences, part_of_speech,
        tokenize='unicode61'
      );
    ''');
    if (withBackfill) {
      await customStatement('''
        INSERT INTO vocabulary_search_table (
          id, word, reading, meaning, example_sentences, part_of_speech
        )
        SELECT id, word, reading, meaning, example_sentences_json, part_of_speech
        FROM vocabulary_table
        WHERE id NOT IN (SELECT id FROM vocabulary_search_table);
      ''');
    }
    await customStatement('DROP TRIGGER IF EXISTS vocabulary_search_insert;');
    await customStatement('DROP TRIGGER IF EXISTS vocabulary_search_update;');
    await customStatement('DROP TRIGGER IF EXISTS vocabulary_search_delete;');
    await customStatement('''
      CREATE TRIGGER vocabulary_search_insert AFTER INSERT ON vocabulary_table BEGIN
        DELETE FROM vocabulary_search_table WHERE id = new.id;
        INSERT INTO vocabulary_search_table (
          id, word, reading, meaning, example_sentences, part_of_speech
        )
        VALUES (
          new.id, new.word, new.reading, new.meaning,
          new.example_sentences_json, new.part_of_speech
        );
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER vocabulary_search_update AFTER UPDATE ON vocabulary_table BEGIN
        DELETE FROM vocabulary_search_table WHERE id = new.id;
        INSERT INTO vocabulary_search_table (
          id, word, reading, meaning, example_sentences, part_of_speech
        )
        VALUES (
          new.id, new.word, new.reading, new.meaning,
          new.example_sentences_json, new.part_of_speech
        );
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER vocabulary_search_delete AFTER DELETE ON vocabulary_table BEGIN
        DELETE FROM vocabulary_search_table WHERE id = old.id;
      END;
    ''');
  }

  Future<void> _createGrammarSearchTable({bool withBackfill = true}) async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS grammar_search_table USING fts5(
        id, title, structure, explanation, example,
        tokenize='unicode61'
      );
    ''');
    if (withBackfill) {
      await customStatement('''
        INSERT INTO grammar_search_table (
          id, title, structure, explanation, example
        )
        SELECT id, title, structure, explanation, example
        FROM grammar_table
        WHERE id NOT IN (SELECT id FROM grammar_search_table);
      ''');
    }
    await customStatement('DROP TRIGGER IF EXISTS grammar_search_insert;');
    await customStatement('DROP TRIGGER IF EXISTS grammar_search_update;');
    await customStatement('DROP TRIGGER IF EXISTS grammar_search_delete;');
    await customStatement('''
      CREATE TRIGGER grammar_search_insert AFTER INSERT ON grammar_table BEGIN
        DELETE FROM grammar_search_table WHERE id = new.id;
        INSERT INTO grammar_search_table (
          id, title, structure, explanation, example
        )
        VALUES (
          new.id, new.title, new.structure, new.explanation, new.example
        );
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER grammar_search_update AFTER UPDATE ON grammar_table BEGIN
        DELETE FROM grammar_search_table WHERE id = new.id;
        INSERT INTO grammar_search_table (
          id, title, structure, explanation, example
        )
        VALUES (
          new.id, new.title, new.structure, new.explanation, new.example
        );
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER grammar_search_delete AFTER DELETE ON grammar_table BEGIN
        DELETE FROM grammar_search_table WHERE id = old.id;
      END;
    ''');
  }

  Future<void> _createTableIfNotExist(Migrator m, TableInfo table) async {
    try {
      await m.createTable(table);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Skipping table creation because it may already exist: $table',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // Helper to clean up legacy JSON arrays stored as strings
  static String _cleanString(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      try {
        final List<dynamic> list = jsonDecode(trimmed);
        return list
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .join(', ');
      } catch (error, stackTrace) {
        AppLogger.warning(
          'Failed to decode legacy string list',
          error: error,
          stackTrace: stackTrace,
        );
        // Fallback for malformed JSON or non-JSON strings that happen to have brackets
        String cleaned = trimmed.substring(1, trimmed.length - 1);
        cleaned = cleaned.replaceAll('"', '').replaceAll("'", '');
        return cleaned
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .join(', ');
      }
    }
    return input;
  }

  // Mappers
  static KanjiCard toEntity(KanjiCardData d) => KanjiCard(
    id: d.id,
    kanji: d.kanji,
    meanings: _cleanString(d.meanings),
    onyomi: _cleanString(d.onyomi),
    kunyomi: _cleanString(d.kunyomi),
    strokeData: d.strokeData,
    jlptLevel: d.jlptLevel,
    radicalsJson: d.radicalsJson,
    mnemonic: d.mnemonic,
    relatedWordsJson: d.relatedWordsJson,
    strokePathsJson: d.strokePathsJson,
    strokeCount: d.strokeCount,
    grade: d.grade,
    frequency: d.frequency,
    radicalNumber: d.radicalNumber,
    radicalNamesJson: d.radicalNamesJson,
    nanoriJson: d.nanoriJson,
    variantsJson: d.variantsJson,
    queryCodesJson: d.queryCodesJson,
    stability: d.stability,
    difficulty: d.difficulty,
    lastReview: d.lastReview,
    nextReview: d.nextReview,
    reps: d.reps,
    lapses: d.lapses,
    state: d.state,
  );

  static KanjiCardTableCompanion fromEntity(KanjiCard c) =>
      KanjiCardTableCompanion(
        id: Value(c.id),
        kanji: Value(c.kanji),
        meanings: Value(c.meanings),
        onyomi: Value(c.onyomi),
        kunyomi: Value(c.kunyomi),
        strokeData: Value(c.strokeData),
        jlptLevel: Value(c.jlptLevel),
        radicalsJson: Value(c.radicalsJson),
        mnemonic: Value(c.mnemonic),
        relatedWordsJson: Value(c.relatedWordsJson),
        strokePathsJson: Value(c.strokePathsJson),
        strokeCount: Value(c.strokeCount),
        grade: Value(c.grade),
        frequency: Value(c.frequency),
        radicalNumber: Value(c.radicalNumber),
        radicalNamesJson: Value(c.radicalNamesJson),
        nanoriJson: Value(c.nanoriJson),
        variantsJson: Value(c.variantsJson),
        queryCodesJson: Value(c.queryCodesJson),
        stability: Value(c.stability),
        difficulty: Value(c.difficulty),
        lastReview: Value(c.lastReview),
        nextReview: Value(c.nextReview),
        reps: Value(c.reps),
        lapses: Value(c.lapses),
        state: Value(c.state),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        database.execute('PRAGMA journal_mode = WAL;');
        database.execute('PRAGMA synchronous = NORMAL;');
      },
    );
  });
}
