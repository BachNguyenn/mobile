import 'package:drift/drift.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:mobile/features/kanji/domain/repositories/kanji_repository.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:mobile/features/weakness/domain/entities/weakness_review_item.dart';
import 'package:mobile/features/weakness/domain/repositories/weakness_repository.dart';

class DriftWeaknessRepository implements WeaknessRepository {
  final AppDatabase _db;
  final KanjiRepository _kanjiRepository;
  final VocabularyRepository _vocabularyRepository;
  final GrammarRepository _grammarRepository;

  const DriftWeaknessRepository(
    this._db,
    this._kanjiRepository,
    this._vocabularyRepository,
    this._grammarRepository,
  );

  @override
  Future<List<WeaknessReviewItem>> getWeakItems({
    int? jlptLevel,
    ReviewItemType? type,
    int limit = 20,
    int minAttempts = 2,
    int lookbackDays = 30,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: lookbackDays - 1));
    final typeFilter = _storageType(type);
    final rows = await _db
        .customSelect(
          '''
          SELECT
            item_id,
            item_type,
            COUNT(*) AS attempts,
            SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END) AS misses,
            AVG(CASE WHEN rating >= 3 THEN 1.0 ELSE 0.0 END) AS success_rate,
            MAX(review_time) AS last_review
          FROM review_log_table
          WHERE review_time >= ?
            AND item_type IN ('kanji', 'vocabulary', 'grammar')
            AND (? IS NULL OR item_type = ?)
          GROUP BY item_id, item_type
          HAVING attempts >= ? AND misses > 0
          ORDER BY misses DESC, success_rate ASC, last_review DESC
          LIMIT ?
          ''',
          variables: [
            Variable.withDateTime(start),
            Variable(typeFilter),
            Variable(typeFilter),
            Variable(minAttempts),
            Variable(limit),
          ],
          readsFrom: {_db.reviewLogTable},
        )
        .get();

    final items = <WeaknessReviewItem>[];
    for (final row in rows) {
      final reviewItem = await _toReviewItem(
        id: row.read<String>('item_id'),
        type: row.read<String>('item_type'),
      );
      if (reviewItem == null) continue;
      if (jlptLevel != null && reviewItem.jlptLevel != jlptLevel) continue;

      items.add(
        WeaknessReviewItem(
          reviewItem: reviewItem,
          attempts: row.read<int>('attempts'),
          misses: row.read<int>('misses'),
          successRate: row.read<double>('success_rate'),
          lastReviewedAt: _dateFromStorage(
            row.readNullable<int>('last_review'),
          ),
        ),
      );
    }
    return items;
  }

  Future<ReviewItem?> _toReviewItem({
    required String id,
    required String type,
  }) async {
    switch (type) {
      case 'kanji':
        final card = await _kanjiRepository.getCardById(id);
        return card == null ? null : ReviewItem.fromKanji(card);
      case 'vocabulary':
      case 'vocab':
        final vocabulary = await _vocabularyRepository.getVocabularyById(id);
        return vocabulary == null
            ? null
            : ReviewItem.fromVocabulary(vocabulary);
      case 'grammar':
        final grammar = await _grammarRepository.getGrammarPointById(id);
        return grammar == null ? null : ReviewItem.fromGrammar(grammar);
      default:
        return null;
    }
  }

  String? _storageType(ReviewItemType? type) {
    return switch (type) {
      ReviewItemType.kanji => 'kanji',
      ReviewItemType.vocabulary => 'vocabulary',
      ReviewItemType.grammar => 'grammar',
      ReviewItemType.sentence => 'sentence',
      null => null,
    };
  }

  DateTime? _dateFromStorage(Object? value) {
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
