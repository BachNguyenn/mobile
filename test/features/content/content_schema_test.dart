import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/grammar/data/repositories/grammar_repository_impl.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/kanji/data/repositories/kanji_repository_impl.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';

void main() {
  test('schema v10 creates enrichment columns', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 10);

    final vocabularyColumns = await db
        .customSelect("PRAGMA table_info('vocabulary_table')")
        .get();
    final kanjiColumns = await db
        .customSelect("PRAGMA table_info('kanji_card_table')")
        .get();

    expect(
      vocabularyColumns.map((row) => row.read<String>('name')),
      containsAll([
        'example_sentences_json',
        'image_url',
        'pitch_accent',
        'part_of_speech',
      ]),
    );
    expect(
      kanjiColumns.map((row) => row.read<String>('name')),
      containsAll(['radicals_json', 'mnemonic', 'related_words_json']),
    );
  });

  test(
    'repository count queries aggregate without loading full tables',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final now = DateTime(2026, 5, 14);
      final kanjiRepo = KanjiRepositoryImpl(db);
      final vocabularyRepo = VocabularyRepositoryImpl(db);
      final grammarRepo = GrammarRepositoryImpl(db);

      await kanjiRepo.saveAllCards([
        KanjiCard(
          id: 'n5_日',
          kanji: '日',
          meanings: 'day',
          onyomi: 'ニチ',
          kunyomi: 'ひ',
          jlptLevel: 5,
          nextReview: now.subtract(const Duration(days: 1)),
          reps: 1,
        ),
        KanjiCard(
          id: 'n4_会',
          kanji: '会',
          meanings: 'meet',
          onyomi: 'カイ',
          kunyomi: 'あう',
          jlptLevel: 4,
          nextReview: now.add(const Duration(days: 1)),
        ),
      ]);
      await vocabularyRepo.saveVocabulary([
        Vocabulary(
          id: 'n5_水',
          word: '水',
          reading: 'みず',
          meaning: 'water',
          jlptLevel: 5,
          nextReview: now.subtract(const Duration(days: 1)),
          reps: 1,
        ),
      ]);
      await grammarRepo.saveGrammarPoints([
        const GrammarPoint(
          id: 'n5_desu',
          title: 'です',
          shortExplanation: 'to be',
          longExplanation: '',
          formation: 'N + です',
          examples: [],
          jlptLevel: 5,
          isLearned: true,
        ),
      ]);

      expect(await kanjiRepo.countCards(), 2);
      expect(await kanjiRepo.countLearnedCards(), 1);
      expect(await kanjiRepo.countDueCards(now), 1);
      expect(await vocabularyRepo.countVocabulary(jlptLevel: 5), 1);
      expect(await vocabularyRepo.countLearnedVocabulary(jlptLevel: 5), 1);
      expect(await vocabularyRepo.countDueVocabulary(now, jlptLevel: 5), 1);
      expect(await grammarRepo.countGrammarPoints(jlptLevel: 5), 1);
      expect(await grammarRepo.countLearnedGrammar(jlptLevel: 5), 1);
      expect(await grammarRepo.countDueGrammar(jlptLevel: 5), 0);
    },
  );
}
