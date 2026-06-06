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
  test('schema v13 creates enrichment columns, indexes, and search tables', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 13);

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
      containsAll([
        'radicals_json',
        'mnemonic',
        'related_words_json',
        'stroke_paths_json',
        'stroke_count',
        'grade',
        'frequency',
        'radical_number',
        'radical_names_json',
        'nanori_json',
        'variants_json',
        'query_codes_json',
      ]),
    );

    final vocabularyIndexes = await db
        .customSelect("PRAGMA index_list('vocabulary_table')")
        .get();
    expect(
      vocabularyIndexes.map((row) => row.read<String>('name')),
      contains('idx_vocabulary_due_level'),
    );

    final searchTables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('vocabulary_search_table', 'grammar_search_table')",
        )
        .get();
    expect(
      searchTables.map((row) => row.read<String>('name')),
      containsAll(['vocabulary_search_table', 'grammar_search_table']),
    );
  });

  test('repository count queries aggregate without loading full tables', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final now = DateTime(2026, 5, 14);
    final kanjiRepo = KanjiRepositoryImpl(db);
    final vocabularyRepo = VocabularyRepositoryImpl(db);
    final grammarRepo = GrammarRepositoryImpl(db);

    await kanjiRepo.saveAllCards([
      KanjiCard(
        id: 'n5_day',
        kanji: '\u65e5',
        meanings: 'day',
        onyomi: '\u30cb\u30c1',
        kunyomi: '\u3072',
        jlptLevel: 5,
        strokePathsJson: '["M0,0 L10,10"]',
        strokeCount: 1,
        grade: 1,
        frequency: 2,
        radicalNumber: 72,
        radicalNamesJson: '["\\u3072"]',
        nanoriJson: '["\\u3042\\u304d"]',
        variantsJson: '["jis208: 1-2-3"]',
        queryCodesJson: '["skip: 1-1-1"]',
        nextReview: now.subtract(const Duration(days: 1)),
        reps: 1,
      ),
      KanjiCard(
        id: 'n4_meet',
        kanji: '\u4f1a',
        meanings: 'meet',
        onyomi: '\u30ab\u30a4',
        kunyomi: '\u3042\u3046',
        jlptLevel: 4,
        nextReview: now.add(const Duration(days: 1)),
      ),
    ]);
    await vocabularyRepo.saveVocabulary([
      Vocabulary(
        id: 'n5_water',
        word: '\u6c34',
        reading: '\u307f\u305a',
        meaning: 'water',
        jlptLevel: 5,
        nextReview: now.subtract(const Duration(days: 1)),
        reps: 1,
      ),
    ]);
    await grammarRepo.saveGrammarPoints([
      const GrammarPoint(
        id: 'n5_desu',
        title: '\u3067\u3059',
        shortExplanation: 'to be',
        longExplanation: '',
        formation: 'N + \u3067\u3059',
        examples: [],
        jlptLevel: 5,
        isLearned: true,
      ),
    ]);

    expect(await kanjiRepo.countCards(), 2);
    expect(await kanjiRepo.countLearnedCards(), 1);
    expect(await kanjiRepo.countDueCards(now), 1);

    final enrichedKanji = await kanjiRepo.getCardById('n5_day');
    expect(enrichedKanji?.strokePaths, ['M0,0 L10,10']);
    expect(enrichedKanji?.strokeCount, 1);
    expect(enrichedKanji?.radicalNames, ['\u3072']);
    expect(enrichedKanji?.queryCodes, ['skip: 1-1-1']);

    expect(await vocabularyRepo.countVocabulary(jlptLevel: 5), 1);
    expect(await vocabularyRepo.countLearnedVocabulary(jlptLevel: 5), 1);
    expect(await vocabularyRepo.countDueVocabulary(now, jlptLevel: 5), 1);
    expect(await grammarRepo.countGrammarPoints(jlptLevel: 5), 1);
    expect(await grammarRepo.countLearnedGrammar(jlptLevel: 5), 1);
    expect(await grammarRepo.countDueGrammar(jlptLevel: 5), 0);
    expect(await vocabularyRepo.searchVocabulary('water', limit: 10), hasLength(1));
    expect(await grammarRepo.searchGrammar('to', limit: 10), hasLength(1));
  });
}
