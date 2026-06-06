import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/grammar/data/repositories/grammar_repository_impl.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/kanji/data/repositories/kanji_repository_impl.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:mobile/features/weakness/data/repositories/drift_weakness_repository.dart';

void main() {
  test(
    'loads weak review items ordered by misses and filters by type',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final now = DateTime(2026, 6, 6, 12);
      final kanjiRepository = KanjiRepositoryImpl(db);
      final vocabularyRepository = VocabularyRepositoryImpl(db);
      final grammarRepository = GrammarRepositoryImpl(db);
      final repository = DriftWeaknessRepository(
        db,
        kanjiRepository,
        vocabularyRepository,
        grammarRepository,
      );

      await kanjiRepository.saveAllCards([
        KanjiCard(
          id: 'k_day',
          kanji: '\u65e5',
          meanings: 'day',
          onyomi: '\u30cb\u30c1',
          kunyomi: '\u3072',
          jlptLevel: 5,
          nextReview: now,
        ),
      ]);
      await vocabularyRepository.saveVocabulary([
        Vocabulary(
          id: 'v_water',
          word: '\u6c34',
          reading: '\u307f\u305a',
          meaning: 'water',
          jlptLevel: 5,
          nextReview: now,
        ),
      ]);
      await grammarRepository.saveGrammarPoints([
        const GrammarPoint(
          id: 'g_particle',
          title: '\u306f',
          shortExplanation: 'topic marker',
          longExplanation: 'Marks the topic of a sentence.',
          formation: 'N + \u306f',
          examples: [],
          jlptLevel: 5,
        ),
      ]);

      await _insertReview(db, 'k_day', 'kanji', 1, now);
      await _insertReview(db, 'k_day', 'kanji', 2, now);
      await _insertReview(db, 'k_day', 'kanji', 4, now);
      await _insertReview(db, 'v_water', 'vocabulary', 1, now);
      await _insertReview(db, 'v_water', 'vocabulary', 4, now);
      await _insertReview(db, 'g_particle', 'grammar', 1, now);

      final allWeakItems = await repository.getWeakItems(
        minAttempts: 2,
        lookbackDays: 30,
      );

      expect(allWeakItems, hasLength(2));
      expect(allWeakItems.first.id, 'k_day');
      expect(allWeakItems.first.type, ReviewItemType.kanji);
      expect(allWeakItems.first.misses, 2);
      expect(allWeakItems.first.attempts, 3);
      expect(allWeakItems.first.reviewItem.answer, '\u65e5');

      final vocabularyOnly = await repository.getWeakItems(
        type: ReviewItemType.vocabulary,
        minAttempts: 2,
        lookbackDays: 30,
      );

      expect(vocabularyOnly, hasLength(1));
      expect(vocabularyOnly.single.id, 'v_water');
      expect(vocabularyOnly.single.reviewItem.prompt, '\u6c34');
    },
  );
}

Future<void> _insertReview(
  AppDatabase db,
  String itemId,
  String itemType,
  int rating,
  DateTime reviewTime,
) {
  return db
      .into(db.reviewLogTable)
      .insert(
        ReviewLogTableCompanion.insert(
          itemId: itemId,
          itemType: itemType,
          rating: rating,
          reviewTime: reviewTime,
        ),
      );
}
