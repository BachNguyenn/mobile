import 'package:drift/drift.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../../../../data/datasources/app_database.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final AppDatabase _db;

  VocabularyRepositoryImpl(this._db);

  @override
  Future<List<Vocabulary>> getAllVocabulary() async {
    final rows = await (_db.select(_db.vocabularyTable)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<List<Vocabulary>> getVocabularyByLevel(int level) async {
    final rows = await (_db.select(_db.vocabularyTable)
          ..where((t) => t.jlptLevel.equals(level))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<Vocabulary?> getVocabularyById(String id) async {
    final row = await (_db.select(_db.vocabularyTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<void> saveVocabulary(List<Vocabulary> vocabList) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
          _db.vocabularyTable,
          vocabList
              .map((v) => VocabularyTableCompanion.insert(
                    id: v.id,
                    word: v.word,
                    reading: v.reading,
                    meaning: v.meaning,
                    jlptLevel: Value(v.jlptLevel),
                    nextReview: DateTime.now(),
                  ))
              .toList());
    });
  }

  @override
  Future<List<Vocabulary>> searchVocabulary(String query, {int? jlptLevel}) async {
    final queryBuilder = _db.select(_db.vocabularyTable);
    if (query.isNotEmpty) {
      queryBuilder.where((t) => 
        t.word.contains(query) | 
        t.meaning.contains(query) | 
        t.reading.contains(query)
      );
    }
    if (jlptLevel != null) {
      queryBuilder.where((t) => t.jlptLevel.equals(jlptLevel));
    }
    queryBuilder.orderBy([(t) => OrderingTerm(expression: t.id)]);
    final rows = await queryBuilder.get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  Vocabulary _mapRowToEntity(VocabularyTableData row) {
    return Vocabulary(
      id: row.id,
      word: row.word,
      reading: row.reading,
      meaning: row.meaning,
      jlptLevel: row.jlptLevel,
    );
  }
}
