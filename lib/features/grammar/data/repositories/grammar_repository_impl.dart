import 'package:drift/drift.dart';
import '../../domain/entities/grammar_point.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../../../../data/datasources/app_database.dart';
import 'dart:convert';

class GrammarRepositoryImpl implements GrammarRepository {
  final AppDatabase _db;

  GrammarRepositoryImpl(this._db);

  @override
  Future<List<GrammarPoint>> getAllGrammarPoints() async {
    final rows = await (_db.select(_db.grammarTable)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<List<GrammarPoint>> getGrammarPointsByLevel(int level) async {
    final rows = await (_db.select(_db.grammarTable)
          ..where((t) => t.jlptLevel.equals(level))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<GrammarPoint?> getGrammarPointById(String id) async {
    final row = await (_db.select(_db.grammarTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<void> saveGrammarPoints(List<GrammarPoint> points) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
          _db.grammarTable,
          points
              .map((p) => GrammarTableCompanion.insert(
                    id: p.id,
                    title: p.title,
                    structure: p.formation,
                    explanation: json.encode({
                      'short': p.shortExplanation,
                      'long': p.longExplanation,
                    }),
                    example: json.encode(p.examples
                        .map((e) => {'jp': e.jp, 'romaji': e.romaji, 'en': e.en})
                        .toList()),
                    jlptLevel: Value(p.jlptLevel),
                    isLearned: Value(p.isLearned),
                  ))
              .toList());
    });
  }

  @override
  Future<void> markAsLearned(String id, bool isLearned) async {
    await (_db.update(_db.grammarTable)..where((t) => t.id.equals(id))).write(
        GrammarTableCompanion(isLearned: Value(isLearned)));
  }

  @override
  Future<bool> submitReview({
    required String grammarId,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) {
    return _db.submitGrammarReview(
      grammarId: grammarId,
      rating: rating,
      durationMs: durationMs,
      expGain: expGain,
      waterGain: waterGain,
      sunGain: sunGain,
    );
  }

  @override
  Future<List<GrammarPoint>> searchGrammar(String query, {int? jlptLevel}) async {
    final queryBuilder = _db.select(_db.grammarTable);
    if (query.isNotEmpty) {
      queryBuilder.where((t) => 
        t.title.contains(query) | 
        t.explanation.contains(query) | 
        t.structure.contains(query)
      );
    }
    if (jlptLevel != null) {
      queryBuilder.where((t) => t.jlptLevel.equals(jlptLevel));
    }
    queryBuilder.orderBy([(t) => OrderingTerm(expression: t.id)]);
    final rows = await queryBuilder.get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  GrammarPoint _mapRowToEntity(GrammarTableData row) {
    final explanation = json.decode(row.explanation);
    final examplesList = json.decode(row.example) as List;

    return GrammarPoint(
      id: row.id,
      title: row.title,
      shortExplanation: explanation['short'] ?? '',
      longExplanation: explanation['long'] ?? '',
      formation: row.structure,
      examples: examplesList
          .map((e) => GrammarExample(
                jp: e['jp'],
                romaji: e['romaji'],
                en: e['en'],
              ))
          .toList(),
      jlptLevel: row.jlptLevel,
      isLearned: row.isLearned,
    );
  }
}
