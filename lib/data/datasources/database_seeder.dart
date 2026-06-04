import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../features/kanji/domain/entities/kanji_card.dart';
import '../../features/grammar/domain/entities/grammar_point.dart';
import '../../features/vocabulary/domain/entities/vocabulary.dart';
import '../../features/kanji/domain/repositories/kanji_repository.dart';
import '../../features/grammar/domain/repositories/grammar_repository.dart';
import '../../features/vocabulary/domain/repositories/vocabulary_repository.dart';

class DatabaseSeeder {
  final KanjiRepository kanjiRepository;
  final GrammarRepository grammarRepository;
  final VocabularyRepository vocabularyRepository;

  /// Cached asset manifest to avoid re-parsing for each seed method.
  Map<String, dynamic>? _manifestCache;

  DatabaseSeeder({
    required this.kanjiRepository,
    required this.grammarRepository,
    required this.vocabularyRepository,
  });

  Future<void> seedAll() async {
    // Pre-cache the manifest once, then seed all three in parallel.
    await _ensureManifest();
    await Future.wait([
      seedKanjiData(),
      seedGrammarData(),
      seedVocabData(),
    ]);
  }

  Future<void> seedKanjiData() async {
    final levels = await _levelsWithAsset('kanji.json');

    // Load and parse all levels in parallel
    final parsed = await Future.wait(levels.map((level) async {
      try {
        final bytes = await rootBundle.load('assets/data/$level/kanji.json');
        final response = utf8.decode(bytes.buffer.asUint8List());
        return MapEntry(level, await _decodeJsonList(response));
      } catch (e) {
        debugPrint('Error loading $level kanji: $e');
        return null;
      }
    }));

    // Build all cards then batch-save
    final allCards = <KanjiCard>[];
    for (final entry in parsed) {
      if (entry == null) continue;
      final level = entry.key;
      final data = entry.value;
      for (final json in data) {
        final char = json['character'] as String;
        allCards.add(KanjiCard(
          id: '${level}_$char',
          kanji: char,
          meanings: (json['meanings'] as List).join(', '),
          onyomi: (json['on_reading'] as List).join(', '),
          kunyomi: (json['kun_reading'] as List).join(', '),
          jlptLevel: int.parse(level.replaceAll('n', '')),
          radicalsJson: _encodeList(json['radicals']),
          mnemonic: _optionalString(json['mnemonic']),
          relatedWordsJson: _encodeList(json['related_words']),
          nextReview: DateTime.now(),
        ));
      }
    }

    if (allCards.isNotEmpty) {
      await kanjiRepository.saveAllCards(allCards);
    }
  }

  Future<void> seedGrammarData() async {
    final levels = await _levelsWithAsset('grammar.json');

    final parsed = await Future.wait(levels.map((level) async {
      try {
        final bytes = await rootBundle.load('assets/data/$level/grammar.json');
        final response = utf8.decode(bytes.buffer.asUint8List());
        return MapEntry(level, await _decodeJsonList(response));
      } catch (e) {
        debugPrint('Error loading $level grammar: $e');
        return null;
      }
    }));

    final allPoints = <GrammarPoint>[];
    for (final entry in parsed) {
      if (entry == null) continue;
      final level = entry.key;
      final data = entry.value;
      for (final json in data) {
        final title = json['title'] as String;
        allPoints.add(GrammarPoint(
          id: '${level}_$title',
          title: title,
          shortExplanation: json['short_explanation'] ?? '',
          longExplanation: json['long_explanation'] ?? '',
          formation: json['formation'] ?? '',
          jlptLevel: int.parse(level.replaceAll('n', '')),
          examples: (json['examples'] as List)
              .map(
                (e) => GrammarExample(
                  jp: e['jp'] ?? '',
                  romaji: e['romaji'] ?? '',
                  en: e['en'] ?? '',
                ),
              )
              .toList(),
        ));
      }
    }

    if (allPoints.isNotEmpty) {
      await grammarRepository.saveGrammarPoints(allPoints);
    }
  }

  Future<void> seedVocabData() async {
    final levels = await _levelsWithAsset('vocabulary.json');

    final parsed = await Future.wait(levels.map((level) async {
      try {
        final bytes =
            await rootBundle.load('assets/data/$level/vocabulary.json');
        final response = utf8.decode(bytes.buffer.asUint8List());
        return MapEntry(level, await _decodeJsonList(response));
      } catch (e) {
        debugPrint('Error loading $level vocabulary: $e');
        return null;
      }
    }));

    final allVocab = <Vocabulary>[];
    for (final entry in parsed) {
      if (entry == null) continue;
      final level = entry.key;
      final data = entry.value;
      for (final json in data) {
        final word = json['word'] as String;
        allVocab.add(Vocabulary(
          id: '${level}_$word',
          word: word,
          reading: json['reading'] ?? '',
          meaning: json['meaning'] ?? '',
          jlptLevel: int.parse(level.replaceAll('n', '')),
          exampleSentencesJson: _encodeList(json['example_sentences']),
          imageUrl: _optionalString(json['image_url']),
          pitchAccent: _optionalString(json['pitch_accent']),
          partOfSpeech: _optionalString(json['part_of_speech']),
          nextReview: DateTime.now(),
        ));
      }
    }

    if (allVocab.isNotEmpty) {
      await vocabularyRepository.saveVocabulary(allVocab);
    }
  }

  String _encodeList(Object? value) {
    if (value == null) return '[]';
    if (value is List) return jsonEncode(value);
    return jsonEncode([value]);
  }

  String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  Future<List<dynamic>> _decodeJsonList(String source) {
    return compute(_parseJsonList, source);
  }

  static List<dynamic> _parseJsonList(String source) {
    return json.decode(source) as List<dynamic>;
  }

  Future<void> _ensureManifest() async {
    _manifestCache ??= json.decode(
      await rootBundle.loadString('AssetManifest.json'),
    ) as Map<String, dynamic>;
  }

  Future<List<String>> _levelsWithAsset(String fileName) async {
    await _ensureManifest();
    final manifest = _manifestCache!;
    final pattern = RegExp('^assets/data/(n\\d+)/${RegExp.escape(fileName)}\$');
    final levels = manifest.keys
        .map((path) => pattern.firstMatch(path)?.group(1))
        .nonNulls
        .toSet()
        .toList();
    levels.sort((a, b) => _levelNumber(b).compareTo(_levelNumber(a)));
    return levels;
  }

  int _levelNumber(String value) {
    return int.tryParse(value.replaceAll('n', '')) ?? 0;
  }
}
