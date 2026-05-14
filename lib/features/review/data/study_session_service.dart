import 'package:drift/drift.dart';
import 'package:mobile/core/srs/srs_item.dart';
import 'package:mobile/data/datasources/app_database.dart';

enum StudyItemType {
  kanji('kanji'),
  vocabulary('vocabulary'),
  grammar('grammar'),
  sentence('sentence');

  final String storageValue;

  const StudyItemType(this.storageValue);
}

abstract class StudySessionService {
  Future<bool> submitSrsReview({
    required SrsItem updatedItem,
    required StudyItemType itemType,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  });

  Future<bool> submitGrammarReview({
    required String grammarId,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  });
}

class DriftStudySessionService implements StudySessionService {
  final AppDatabase _db;

  DriftStudySessionService(this._db);

  @override
  Future<bool> submitSrsReview({
    required SrsItem updatedItem,
    required StudyItemType itemType,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) async {
    return _db.transaction(() async {
      switch (itemType) {
        case StudyItemType.kanji:
          await (_db.update(
            _db.kanjiCardTable,
          )..where((table) => table.id.equals(updatedItem.id))).write(
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
          break;
        case StudyItemType.vocabulary:
          await (_db.update(
            _db.vocabularyTable,
          )..where((table) => table.id.equals(updatedItem.id))).write(
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
          break;
        case StudyItemType.grammar:
        case StudyItemType.sentence:
          throw ArgumentError('SRS review is not supported for $itemType');
      }

      await _insertReviewLog(
        itemId: updatedItem.id,
        itemType: itemType,
        rating: rating,
        durationMs: durationMs,
      );
      await _grantGardenRewards(
        expGain: expGain,
        waterGain: waterGain,
        sunGain: sunGain,
      );
      await _incrementTodayStudyLog();
      return true;
    });
  }

  @override
  Future<bool> submitGrammarReview({
    required String grammarId,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) async {
    return _db.transaction(() async {
      if (rating >= 3) {
        await (_db.update(_db.grammarTable)
              ..where((table) => table.id.equals(grammarId)))
            .write(const GrammarTableCompanion(isLearned: Value(true)));
      }

      await _insertReviewLog(
        itemId: grammarId,
        itemType: StudyItemType.grammar,
        rating: rating,
        durationMs: durationMs,
      );
      await _grantGardenRewards(
        expGain: expGain,
        waterGain: waterGain,
        sunGain: sunGain,
      );
      await _incrementTodayStudyLog();
      return true;
    });
  }

  Future<void> _insertReviewLog({
    required String itemId,
    required StudyItemType itemType,
    required int rating,
    required int durationMs,
  }) {
    return _db
        .into(_db.reviewLogTable)
        .insert(
          ReviewLogTableCompanion.insert(
            itemId: itemId,
            itemType: itemType.storageValue,
            rating: rating,
            reviewTime: DateTime.now(),
            durationMs: Value(durationMs),
          ),
        );
  }

  Future<void> _grantGardenRewards({
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) async {
    final garden = await _db.select(_db.zenGardenTable).getSingleOrNull();
    if (garden == null) return;

    await _db
        .update(_db.zenGardenTable)
        .replace(
          garden.copyWith(
            exp: garden.exp + expGain,
            water: garden.water + waterGain,
            sunlight: garden.sunlight + sunGain,
            lastLogin: Value(DateTime.now()),
          ),
        );
  }

  Future<void> _incrementTodayStudyLog() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = await (_db.select(
      _db.studyLogTable,
    )..where((table) => table.date.equals(today))).getSingleOrNull();

    if (current == null) {
      await _db
          .into(_db.studyLogTable)
          .insert(
            StudyLogTableCompanion.insert(date: today, count: const Value(1)),
          );
      return;
    }

    await (_db.update(_db.studyLogTable)
          ..where((table) => table.date.equals(today)))
        .write(StudyLogTableCompanion(count: Value(current.count + 1)));
  }
}
