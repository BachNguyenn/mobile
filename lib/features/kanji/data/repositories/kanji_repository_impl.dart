import 'package:drift/drift.dart';
import '../../domain/entities/kanji_card.dart';
import '../../../../core/srs/srs_item.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../../../../data/datasources/app_database.dart';

class KanjiRepositoryImpl implements KanjiRepository {
  final AppDatabase db;

  KanjiRepositoryImpl(this.db);

  @override
  Future<List<KanjiCard>> getAllCards() async {
    final rows = await (db.select(db.kanjiCardTable)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<List<KanjiCard>> getDueCards(DateTime now, {int? jlptLevel, int? limit}) async {
    final query = db.select(db.kanjiCardTable)
      ..where((t) => t.nextReview.isSmallerOrEqualValue(now));
    
    if (jlptLevel != null) {
      query.where((t) => t.jlptLevel.equals(jlptLevel));
    }

    if (limit != null) {
      query.limit(limit);
    }

    final rows = await query.get();
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<KanjiCard?> getCardById(String id) async {
    final query = db.select(db.kanjiCardTable)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<void> saveCard(KanjiCard card) async {
    await db.into(db.kanjiCardTable).insertOnConflictUpdate(_toData(card));
  }

  @override
  Future<void> saveAllCards(List<KanjiCard> cards) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.kanjiCardTable,
        cards.map((c) => _toData(c)).toList(),
      );
    });
  }

  @override
  Future<List<KanjiCard>> searchKanji(String query, {int? jlptLevel}) async {
    if (query.isEmpty && jlptLevel == null) return getAllCards();

    List<String>? ids;
    if (query.isNotEmpty) {
      // Use FTS5 for searching
      final searchResults = await db.customSelect(
        'SELECT id FROM kanji_search_table WHERE kanji_search_table MATCH ?',
        variables: [Variable.withString(query)],
      ).get();
      ids = searchResults.map((r) => r.read<String>('id')).toList();
    }

    final mainQuery = db.select(db.kanjiCardTable);
    final searchIds = ids;
    if (searchIds != null) {
      if (searchIds.isEmpty) return [];
      mainQuery.where((t) => t.id.isIn(searchIds));
    }
    if (jlptLevel != null) {
      mainQuery.where((t) => t.jlptLevel.equals(jlptLevel));
    }

    mainQuery.orderBy([(t) => OrderingTerm(expression: t.id)]);
    final rows = await mainQuery.get();
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<bool> submitReview({
    required SrsItem updatedItem,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) async {
    return db.submitReview(
      updatedItem: updatedItem,
      itemType: 'kanji',
      rating: rating,
      durationMs: durationMs,
      expGain: expGain,
      waterGain: waterGain,
      sunGain: sunGain,
    );
  }

  @override
  Future<KanjiCard?> getCardByKanji(String kanji) async {
    final query = db.select(db.kanjiCardTable)..where((t) => t.kanji.equals(kanji));
    final row = await query.getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  KanjiCard _toEntity(KanjiCardData data) {
    return AppDatabase.toEntity(data);
  }

  KanjiCardTableCompanion _toData(KanjiCard card) {
    return AppDatabase.fromEntity(card);
  }
}
