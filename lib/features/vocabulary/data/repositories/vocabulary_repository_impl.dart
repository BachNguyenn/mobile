import 'package:drift/drift.dart';
import 'package:mobile/core/srs/srs_item.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../../../../data/datasources/app_database.dart';
import '../../../review/data/study_session_service.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final AppDatabase _db;
  final StudySessionService _studySessionService;

  VocabularyRepositoryImpl(this._db)
    : _studySessionService = DriftStudySessionService(_db);

  @override
  Future<List<Vocabulary>> getAllVocabulary() async {
    final rows = await (_db.select(
      _db.vocabularyTable,
    )..orderBy([(t) => OrderingTerm(expression: t.id)])).get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<List<Vocabulary>> getDueVocabulary(
    DateTime now, {
    int? jlptLevel,
    int? limit,
  }) async {
    final query = _db.select(_db.vocabularyTable)
      ..where((t) => t.nextReview.isSmallerOrEqualValue(now));

    if (jlptLevel != null) {
      query.where((t) => t.jlptLevel.equals(jlptLevel));
    }

    if (limit != null) {
      query.limit(limit);
    }

    final rows = await query.get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<int> countVocabulary({int? jlptLevel}) {
    final countExp = _db.vocabularyTable.id.count();
    final query = _db.selectOnly(_db.vocabularyTable)..addColumns([countExp]);
    if (jlptLevel != null) {
      query.where(_db.vocabularyTable.jlptLevel.equals(jlptLevel));
    }
    return query.getSingle().then((row) => row.read(countExp) ?? 0);
  }

  @override
  Future<int> countLearnedVocabulary({int? jlptLevel}) {
    final countExp = _db.vocabularyTable.id.count();
    final query = _db.selectOnly(_db.vocabularyTable)..addColumns([countExp]);
    query.where(_db.vocabularyTable.reps.isBiggerThanValue(0));
    if (jlptLevel != null) {
      query.where(_db.vocabularyTable.jlptLevel.equals(jlptLevel));
    }
    return query.getSingle().then((row) => row.read(countExp) ?? 0);
  }

  @override
  Future<int> countDueVocabulary(DateTime now, {int? jlptLevel}) {
    final countExp = _db.vocabularyTable.id.count();
    final query = _db.selectOnly(_db.vocabularyTable)..addColumns([countExp]);
    query.where(_db.vocabularyTable.nextReview.isSmallerOrEqualValue(now));
    if (jlptLevel != null) {
      query.where(_db.vocabularyTable.jlptLevel.equals(jlptLevel));
    }
    return query.getSingle().then((row) => row.read(countExp) ?? 0);
  }

  @override
  Future<List<Vocabulary>> getVocabularyByLevel(int level) async {
    final rows =
        await (_db.select(_db.vocabularyTable)
              ..where((t) => t.jlptLevel.equals(level))
              ..orderBy([(t) => OrderingTerm(expression: t.id)]))
            .get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<Vocabulary?> getVocabularyById(String id) async {
    final row = await (_db.select(
      _db.vocabularyTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<void> saveVocabulary(List<Vocabulary> vocabList) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.vocabularyTable,
        vocabList
            .map(
              (v) => VocabularyTableCompanion.insert(
                id: v.id,
                word: v.word,
                reading: v.reading,
                meaning: v.meaning,
                jlptLevel: Value(v.jlptLevel),
                exampleSentencesJson: Value(v.exampleSentencesJson),
                imageUrl: Value(v.imageUrl),
                pitchAccent: Value(v.pitchAccent),
                partOfSpeech: Value(v.partOfSpeech),
                stability: Value(v.stability),
                difficulty: Value(v.difficulty),
                lastReview: Value(v.lastReview),
                nextReview: v.nextReview,
                reps: Value(v.reps),
                lapses: Value(v.lapses),
                state: Value(v.state),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<List<Vocabulary>> searchVocabulary(
    String query, {
    int? jlptLevel,
  }) async {
    final queryBuilder = _db.select(_db.vocabularyTable);
    if (query.isNotEmpty) {
      queryBuilder.where(
        (t) =>
            t.word.contains(query) |
            t.meaning.contains(query) |
            t.reading.contains(query) |
            t.exampleSentencesJson.contains(query) |
            t.partOfSpeech.contains(query),
      );
    }
    if (jlptLevel != null) {
      queryBuilder.where((t) => t.jlptLevel.equals(jlptLevel));
    }
    queryBuilder.orderBy([(t) => OrderingTerm(expression: t.id)]);
    final rows = await queryBuilder.get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<bool> submitReview({
    required SrsItem updatedItem,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) {
    return _studySessionService.submitSrsReview(
      updatedItem: updatedItem,
      itemType: StudyItemType.vocabulary,
      rating: rating,
      durationMs: durationMs,
      expGain: expGain,
      waterGain: waterGain,
      sunGain: sunGain,
    );
  }

  Vocabulary _mapRowToEntity(VocabularyTableData row) {
    return Vocabulary(
      id: row.id,
      word: row.word,
      reading: row.reading,
      meaning: row.meaning,
      jlptLevel: row.jlptLevel,
      exampleSentencesJson: row.exampleSentencesJson,
      imageUrl: row.imageUrl,
      pitchAccent: row.pitchAccent,
      partOfSpeech: row.partOfSpeech,
      stability: row.stability,
      difficulty: row.difficulty,
      lastReview: row.lastReview,
      nextReview: row.nextReview,
      reps: row.reps,
      lapses: row.lapses,
      state: row.state,
    );
  }
}
