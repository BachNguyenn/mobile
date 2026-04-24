import 'package:drift/drift.dart';
import '../../domain/entities/kanji_card.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../datasources/app_database.dart';

class KanjiRepositoryImpl implements KanjiRepository {
  final AppDatabase db;

  KanjiRepositoryImpl(this.db);

  @override
  Future<List<KanjiCard>> getAllCards() async {
    final rows = await db.select(db.kanjiCardTable).get();
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<List<KanjiCard>> getDueCards(DateTime now) async {
    final query = db.select(db.kanjiCardTable)
      ..where((t) => t.nextReview.isSmallerThanValue(now));
    final rows = await query.get();
    return rows.map((r) => _toEntity(r)).toList();
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

    final rows = await mainQuery.get();
    return rows.map((r) => _toEntity(r)).toList();
  }

  KanjiCard _toEntity(KanjiCardData data) {
    return KanjiCard(
      id: data.id,
      kanji: data.kanji,
      meanings: data.meanings,
      onyomi: data.onyomi,
      kunyomi: data.kunyomi,
      jlptLevel: data.jlptLevel,
      nextReview: data.nextReview,
      stability: data.stability,
      difficulty: data.difficulty,
      lastReview: data.lastReview,
      reps: data.reps,
      lapses: data.lapses,
      state: data.state,
      strokeData: data.strokeData,
    );
  }

  KanjiCardTableCompanion _toData(KanjiCard card) {
    return KanjiCardTableCompanion.insert(
      id: card.id,
      kanji: card.kanji,
      meanings: card.meanings,
      onyomi: card.onyomi,
      kunyomi: card.kunyomi,
      jlptLevel: Value(card.jlptLevel),
      nextReview: card.nextReview,
      stability: Value(card.stability),
      difficulty: Value(card.difficulty),
      lastReview: Value(card.lastReview),
      reps: Value(card.reps),
      lapses: Value(card.lapses),
      state: Value(card.state),
      strokeData: Value(card.strokeData),
    );
  }
}
