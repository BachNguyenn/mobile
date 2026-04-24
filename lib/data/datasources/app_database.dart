import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/kanji_card.dart';

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

class ZenGardenTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get water => integer().withDefault(const Constant(0))();
  IntColumn get sunlight => integer().withDefault(const Constant(0))();
  IntColumn get exp => integer().withDefault(const Constant(0))();
  TextColumn get plantsJson => text().withDefault(const Constant('[]')).named('plants_json')();
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

@DriftDatabase(tables: [KanjiCardTable, ZenGardenTable, LessonTable, StudyLogTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

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
              INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
              VALUES (new.id, new.meanings, new.onyomi, new.kunyomi);
            END;
          ''');
          await customStatement('''
            CREATE TRIGGER kanji_card_update AFTER UPDATE ON kanji_card_table BEGIN
              UPDATE kanji_search_table SET 
                meanings = new.meanings,
                onyomi = new.onyomi,
                kunyomi = new.kunyomi
              WHERE id = new.id;
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
                INSERT INTO kanji_search_table (id, meanings, onyomi, kunyomi)
                VALUES (new.id, new.meanings, new.onyomi, new.kunyomi);
              END;
            ''');
            await customStatement('''
              CREATE TRIGGER kanji_card_update AFTER UPDATE ON kanji_card_table BEGIN
                UPDATE kanji_search_table SET 
                  meanings = new.meanings,
                  onyomi = new.onyomi,
                  kunyomi = new.kunyomi
                WHERE id = new.id;
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

  // Mappers
  static KanjiCard toEntity(KanjiCardData d) => KanjiCard(
        id: d.id,
        kanji: d.kanji,
        meanings: d.meanings,
        onyomi: d.onyomi,
        kunyomi: d.kunyomi,
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}