import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';

void main() {
  test('Vocabulary parses enriched example sentence JSON', () {
    final vocabulary = Vocabulary(
      id: 'v1',
      word: '水',
      reading: 'みず',
      meaning: 'water',
      exampleSentencesJson: jsonEncode([
        {
          'text': '水を飲みます。',
          'reading': 'mizu o nomimasu.',
          'meaning': 'I drink water.',
        },
        '水です。',
      ]),
      imageUrl: 'https://example.com/water.png',
      pitchAccent: 'みず[0]',
      partOfSpeech: 'noun',
      nextReview: DateTime(2026),
    );

    expect(vocabulary.exampleSentences, hasLength(2));
    expect(vocabulary.exampleSentences.first.text, '水を飲みます。');
    expect(vocabulary.exampleSentences.first.reading, 'mizu o nomimasu.');
    expect(vocabulary.exampleSentences.first.meaning, 'I drink water.');
    expect(vocabulary.exampleSentences.last.text, '水です。');
  });

  test('KanjiCard parses radicals and related words JSON', () {
    final card = KanjiCard(
      id: 'k1',
      kanji: '水',
      meanings: 'water',
      onyomi: 'スイ',
      kunyomi: 'みず',
      radicalsJson: jsonEncode(['水']),
      mnemonic: 'Looks like flowing water.',
      relatedWordsJson: jsonEncode(['水曜日', '水道']),
      nextReview: DateTime(2026),
    );

    expect(card.radicals, ['水']);
    expect(card.mnemonic, 'Looks like flowing water.');
    expect(card.relatedWords, ['水曜日', '水道']);
  });

  test('Kanji database mapper preserves enrichment fields', () {
    final card = KanjiCard(
      id: 'k1',
      kanji: '火',
      meanings: 'fire',
      onyomi: 'カ',
      kunyomi: 'ひ',
      radicalsJson: jsonEncode(['火']),
      mnemonic: 'A flame shape.',
      relatedWordsJson: jsonEncode(['火山']),
      nextReview: DateTime(2026),
    );

    final companion = AppDatabase.fromEntity(card);

    expect(companion.radicalsJson.value, jsonEncode(['火']));
    expect(companion.mnemonic.value, 'A flame shape.');
    expect(companion.relatedWordsJson.value, jsonEncode(['火山']));
  });
}
