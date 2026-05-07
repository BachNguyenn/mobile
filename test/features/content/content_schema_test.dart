import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/datasources/app_database.dart';

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
      containsAll([
        'radicals_json',
        'mnemonic',
        'related_words_json',
      ]),
    );
  });
}
