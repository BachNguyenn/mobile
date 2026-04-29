import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../features/kanji/domain/entities/kanji_card.dart';
import '../../core/srs/srs_item.dart';

part 'app_database.g.dart';

@DataClassName('KanjiCardData')
class KanjiCardTable extends Table {
  TextColumn get id => text()();
  TextColumn get kanji => text()();
  TextColumn get meanings => text()();
  TextColumn get onyomi => text()();
  TextColumn get kunyomi => text()();
  TextColumn get strokeData => text().nullable().named('stroke_data')();
  IntColumn get jlptLevel => integer().withDefault(const Constant(5)).named('jlpt_level')();
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
  IntColumn get jlptLevel => integer().withDefault(const Constant(5)).named('jlpt_level')();
  
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
  IntColumn get jlptLevel => integer().withDefault(const Constant(5)).named('jlpt_level')();
  BoolColumn get isLearned => boolean().withDefault(const Constant(false)).named('is_learned')();

  @override
  Set<Column> get primaryKey => {id};
}

class ZenGardenTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get water => integer().withDefault(const Constant(0))();
  IntColumn get sunlight => integer().withDefault(const Constant(0))();
  IntColumn get exp => integer().withDefault(const Constant(0))();
  TextColumn get plantsJson => text().withDefault(const Constant('[]')).named('plants_json')();
  DateTimeColumn get lastLogin => dateTime().nullable().named('last_login')();
}

class ReviewLogTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemId => text().named('item_id')();
  TextColumn get itemType => text().named('item_type')();
  IntColumn get rating => integer()();
  DateTimeColumn get reviewTime => dateTime().named('review_time')();
  IntColumn get durationMs => integer().withDefault(const Constant(0)).named('duration_ms')();
}

class LessonTable extends Table {
  TextColumn get id => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false)).named('is_completed')();

  @override
  Set<Column> get primaryKey => {id};
}

class StudyLogTable extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(tables: [KanjiCardTable, VocabularyTable, GrammarTable, ZenGardenTable, LessonTable, StudyLogTable, ReviewLogTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
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
            } catch (_) {}

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
        },
      );

  Future<void> _createTableIfNotExist(Migrator m, TableInfo table) async {
    try {
      await m.createTable(table);
    } catch (_) {
      // Table likely already exists
    }
  }

  // Helper to clean up legacy JSON arrays stored as strings
  static String _cleanString(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      try {
        final List<dynamic> list = jsonDecode(trimmed);
        return list.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).join(', ');
      } catch (_) {
        // Fallback for malformed JSON or non-JSON strings that happen to have brackets
        String cleaned = trimmed.substring(1, trimmed.length - 1);
        cleaned = cleaned.replaceAll('"', '').replaceAll("'", "");
        return cleaned.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).join(', ');
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
        stability: d.stability,
        difficulty: d.difficulty,
        lastReview: d.lastReview,
        nextReview: d.nextReview,
        reps: d.reps,
        lapses: d.lapses,
        state: d.state,
      );

  static KanjiCardTableCompanion fromEntity(KanjiCard c) => KanjiCardTableCompanion(
        id: Value(c.id),
        kanji: Value(c.kanji),
        meanings: Value(c.meanings),
        onyomi: Value(c.onyomi),
        kunyomi: Value(c.kunyomi),
        strokeData: Value(c.strokeData),
        jlptLevel: Value(c.jlptLevel),
        stability: Value(c.stability),
        difficulty: Value(c.difficulty),
        lastReview: Value(c.lastReview),
        nextReview: Value(c.nextReview),
        reps: Value(c.reps),
        lapses: Value(c.lapses),
        state: Value(c.state),
      );

  // Transaction for submitting review and updating gamification
  Future<bool> submitReview({
    required SrsItem updatedItem,
    required String itemType,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) async {
    return transaction(() async {
      // 1. Update the correct table
      if (itemType == 'kanji') {
        await (update(kanjiCardTable)..where((t) => t.id.equals(updatedItem.id))).write(
          KanjiCardTableCompanion(
            stability: Value(updatedItem.stability),
            difficulty: Value(updatedItem.difficulty),
            lastReview: Value(updatedItem.lastReview),
            nextReview: Value(updatedItem.nextReview),
            reps: Value(updatedItem.reps),
            lapses: Value(updatedItem.lapses),
            state: Value(updatedItem.state),
          ),
        );
      } else if (itemType == 'vocab' || itemType == 'vocabulary') {
        await (update(vocabularyTable)..where((t) => t.id.equals(updatedItem.id))).write(
          VocabularyTableCompanion(
            stability: Value(updatedItem.stability),
            difficulty: Value(updatedItem.difficulty),
            lastReview: Value(updatedItem.lastReview),
            nextReview: Value(updatedItem.nextReview),
            reps: Value(updatedItem.reps),
            lapses: Value(updatedItem.lapses),
            state: Value(updatedItem.state),
          ),
        );
      }
      
      // 2. Insert ReviewLog
      await into(reviewLogTable).insert(ReviewLogTableCompanion.insert(
        itemId: updatedItem.id,
        itemType: itemType,
        rating: rating,
        reviewTime: DateTime.now(),
        durationMs: Value(durationMs),
      ));

      // 3. Update Zen Garden
      final gardenList = await select(zenGardenTable).get();
      if (gardenList.isNotEmpty) {
        final current = gardenList.first;
        await update(zenGardenTable).replace(current.copyWith(
          exp: current.exp + expGain,
          water: current.water + waterGain,
          sunlight: current.sunlight + sunGain,
          lastLogin: Value(DateTime.now()),
        ));
      }

      // 4. Update Daily Study Log count
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final logList = await (select(studyLogTable)..where((t) => t.date.equals(today))).get();
      if (logList.isNotEmpty) {
        await (update(studyLogTable)..where((t) => t.date.equals(today))).write(
          StudyLogTableCompanion(count: Value(logList.first.count + 1)),
        );
      } else {
        await into(studyLogTable).insert(StudyLogTableCompanion.insert(
          date: today,
          count: const Value(1),
        ));
      }

      return true;
    });
  }

  Future<bool> submitGrammarReview({
    required String grammarId,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) async {
    return transaction(() async {
      if (rating >= 3) {
        await (update(grammarTable)..where((t) => t.id.equals(grammarId))).write(
          GrammarTableCompanion(isLearned: const Value(true)),
        );
      }

      await into(reviewLogTable).insert(ReviewLogTableCompanion.insert(
        itemId: grammarId,
        itemType: 'grammar',
        rating: rating,
        reviewTime: DateTime.now(),
        durationMs: Value(durationMs),
      ));

      final gardenList = await select(zenGardenTable).get();
      if (gardenList.isNotEmpty) {
        final current = gardenList.first;
        await update(zenGardenTable).replace(current.copyWith(
          exp: current.exp + expGain,
          water: current.water + waterGain,
          sunlight: current.sunlight + sunGain,
          lastLogin: Value(DateTime.now()),
        ));
      }

      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final logList = await (select(studyLogTable)..where((t) => t.date.equals(today))).get();
      if (logList.isNotEmpty) {
        await (update(studyLogTable)..where((t) => t.date.equals(today))).write(
          StudyLogTableCompanion(count: Value(logList.first.count + 1)),
        );
      } else {
        await into(studyLogTable).insert(StudyLogTableCompanion.insert(
          date: today,
          count: const Value(1),
        ));
      }

      return true;
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
