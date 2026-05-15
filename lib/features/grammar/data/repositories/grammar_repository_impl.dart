import 'package:drift/drift.dart';
import '../../domain/entities/grammar_point.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../../../../data/datasources/app_database.dart';
import 'dart:convert';
import '../../../review/data/study_session_service.dart';

class GrammarRepositoryImpl implements GrammarRepository {
  final AppDatabase _db;
  final StudySessionService _studySessionService;

  GrammarRepositoryImpl(this._db)
    : _studySessionService = DriftStudySessionService(_db);

  @override
  Future<List<GrammarPoint>> getAllGrammarPoints() async {
    final rows = await (_db.select(
      _db.grammarTable,
    )..orderBy([(t) => OrderingTerm(expression: t.id)])).get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<List<GrammarPoint>> getGrammarPointsByLevel(int level) async {
    final rows =
        await (_db.select(_db.grammarTable)
              ..where((t) => t.jlptLevel.equals(level))
              ..orderBy([(t) => OrderingTerm(expression: t.id)]))
            .get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<int> countGrammarPoints({int? jlptLevel}) {
    final countExp = _db.grammarTable.id.count();
    final query = _db.selectOnly(_db.grammarTable)..addColumns([countExp]);
    if (jlptLevel != null) {
      query.where(_db.grammarTable.jlptLevel.equals(jlptLevel));
    }
    return query.getSingle().then((row) => row.read(countExp) ?? 0);
  }

  @override
  Future<int> countLearnedGrammar({int? jlptLevel}) {
    final countExp = _db.grammarTable.id.count();
    final query = _db.selectOnly(_db.grammarTable)..addColumns([countExp]);
    query.where(_db.grammarTable.isLearned.equals(true));
    if (jlptLevel != null) {
      query.where(_db.grammarTable.jlptLevel.equals(jlptLevel));
    }
    return query.getSingle().then((row) => row.read(countExp) ?? 0);
  }

  @override
  Future<int> countDueGrammar({int? jlptLevel}) async {
    final total = await countGrammarPoints(jlptLevel: jlptLevel);
    final learned = await countLearnedGrammar(jlptLevel: jlptLevel);
    return total - learned;
  }

  @override
  Future<List<GrammarPoint>> getDueGrammar({int? jlptLevel, int? limit}) async {
    final query = _db.select(_db.grammarTable)
      ..where((t) => t.isLearned.equals(false));

    if (jlptLevel != null) {
      query.where((t) => t.jlptLevel.equals(jlptLevel));
    }

    query.orderBy([(t) => OrderingTerm(expression: t.id)]);

    if (limit != null) {
      query.limit(limit);
    }

    final rows = await query.get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  @override
  Future<GrammarPoint?> getGrammarPointById(String id) async {
    final row = await (_db.select(
      _db.grammarTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<void> saveGrammarPoints(List<GrammarPoint> points) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.grammarTable,
        points
            .map(
              (p) => GrammarTableCompanion.insert(
                id: p.id,
                title: p.title,
                structure: p.formation,
                explanation: json.encode({
                  'short': p.shortExplanation,
                  'long': p.longExplanation,
                }),
                example: json.encode(
                  p.examples
                      .map((e) => {'jp': e.jp, 'romaji': e.romaji, 'en': e.en})
                      .toList(),
                ),
                jlptLevel: Value(p.jlptLevel),
                isLearned: Value(p.isLearned),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> markAsLearned(String id, bool isLearned) async {
    await (_db.update(_db.grammarTable)..where((t) => t.id.equals(id))).write(
      GrammarTableCompanion(isLearned: Value(isLearned)),
    );
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
    return _studySessionService.submitGrammarReview(
      grammarId: grammarId,
      rating: rating,
      durationMs: durationMs,
      expGain: expGain,
      waterGain: waterGain,
      sunGain: sunGain,
    );
  }

  @override
  Future<List<GrammarPoint>> searchGrammar(
    String query, {
    int? jlptLevel,
    int? limit,
  }) async {
    final normalized = query.trim();
    List<String>? ids;
    if (normalized.isNotEmpty) {
      final rows = await _db
          .customSelect(
            '''
            SELECT id
            FROM grammar_search_table
            WHERE grammar_search_table MATCH ?
            ORDER BY rank
            ${limit == null ? '' : 'LIMIT ?'}
            ''',
            variables: [
              Variable.withString(_ftsPrefixQuery(normalized)),
              if (limit != null) Variable.withInt(limit),
            ],
          )
          .get();
      ids = rows.map((row) => row.read<String>('id')).toList();
    }

    final queryBuilder = _db.select(_db.grammarTable);
    final searchIds = ids;
    if (searchIds != null) {
      if (searchIds.isEmpty) return [];
      queryBuilder.where((t) => t.id.isIn(searchIds));
    }
    if (jlptLevel != null) {
      queryBuilder.where((t) => t.jlptLevel.equals(jlptLevel));
    }
    queryBuilder.orderBy([(t) => OrderingTerm(expression: t.id)]);
    if (normalized.isEmpty && limit != null) {
      queryBuilder.limit(limit);
    }
    final rows = await queryBuilder.get();
    return rows.map((row) => _mapRowToEntity(row)).toList();
  }

  String _ftsPrefixQuery(String query) {
    return query
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .map((term) => '"${term.replaceAll('"', '""')}"*')
        .join(' ');
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
          .map(
            (e) =>
                GrammarExample(jp: e['jp'], romaji: e['romaji'], en: e['en']),
          )
          .toList(),
      jlptLevel: row.jlptLevel,
      isLearned: row.isLearned,
    );
  }
}
