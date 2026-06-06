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

  /// Cached asset list to avoid re-parsing for each seed method.
  List<String>? _assetsCache;

  DatabaseSeeder({
    required this.kanjiRepository,
    required this.grammarRepository,
    required this.vocabularyRepository,
  });

  Future<void> seedAll() async {
    // Pre-cache the manifest once, then seed all three in parallel.
    await _ensureManifest();
    await Future.wait([seedKanjiData(), seedGrammarData(), seedVocabData()]);
  }

  Future<void> seedKanjiData() async {
    final existing = await kanjiRepository.getAllCards();
    final existingMap = {for (final c in existing) c.id: c};

    final levels = await _levelsWithAsset('kanji.json');

    // Load and parse all levels in parallel
    final parsed = await Future.wait(
      levels.map((level) async {
        try {
          final bytes = await rootBundle.load('assets/data/$level/kanji.json');
          final response = utf8.decode(bytes.buffer.asUint8List());
          return MapEntry(level, await _decodeJsonList(response));
        } catch (e) {
          debugPrint('Error loading $level kanji: $e');
          return null;
        }
      }),
    );

    // Build all cards then batch-save
    final allCards = <KanjiCard>[];
    for (final entry in parsed) {
      if (entry == null) continue;
      final level = entry.key;
      final data = entry.value;
      for (final json in data) {
        final char = json['character'] as String;
        final id = '${level}_$char';
        final existingCard = existingMap[id];
        allCards.add(
          KanjiCard(
            id: id,
            kanji: char,
            meanings: (json['meanings'] as List).join(', '),
            onyomi: (json['on_reading'] as List).join(', '),
            kunyomi: (json['kun_reading'] as List).join(', '),
            strokeData: _encodeList(
              json['stroke_data'] ?? json['stroke_paths'],
            ),
            jlptLevel: int.parse(level.replaceAll('n', '')),
            radicalsJson: _encodeList(json['radicals']),
            mnemonic: _optionalString(json['mnemonic']),
            relatedWordsJson: _encodeList(json['related_words']),
            strokePathsJson: _encodeList(
              json['stroke_paths'] ?? json['stroke_data'],
            ),
            strokeCount: _optionalInt(json['stroke_count']),
            grade: _optionalInt(json['grade']),
            frequency: _optionalInt(json['frequency']),
            radicalNumber: _optionalInt(json['radical_number']),
            radicalNamesJson: _encodeList(json['radical_names']),
            nanoriJson: _encodeList(json['nanori']),
            variantsJson: _encodeList(json['variants']),
            queryCodesJson: _encodeList(json['query_codes']),
            // Preserve user progress
            stability: existingCard?.stability ?? 0.0,
            difficulty: existingCard?.difficulty ?? 0.0,
            lastReview: existingCard?.lastReview,
            nextReview: existingCard?.nextReview ?? DateTime.now(),
            reps: existingCard?.reps ?? 0,
            lapses: existingCard?.lapses ?? 0,
            state: existingCard?.state ?? 0,
          ),
        );
      }
    }

    if (allCards.isNotEmpty) {
      await kanjiRepository.saveAllCards(allCards);
    }
  }

  Future<void> seedGrammarData() async {
    final existing = await grammarRepository.getAllGrammarPoints();
    final existingMap = {for (final gp in existing) gp.id: gp};

    final levels = await _levelsWithAsset('grammar.json');

    final parsed = await Future.wait(
      levels.map((level) async {
        try {
          final bytes = await rootBundle.load(
            'assets/data/$level/grammar.json',
          );
          final response = utf8.decode(bytes.buffer.asUint8List());
          return MapEntry(level, await _decodeJsonList(response));
        } catch (e) {
          debugPrint('Error loading $level grammar: $e');
          return null;
        }
      }),
    );

    final allPoints = <GrammarPoint>[];
    for (final entry in parsed) {
      if (entry == null) continue;
      final level = entry.key;
      final data = entry.value;
      for (final json in data) {
        final title = json['title'] as String;
        final id = '${level}_$title';
        final existingGp = existingMap[id];
        allPoints.add(
          GrammarPoint(
            id: id,
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
            isLearned: existingGp?.isLearned ?? false,
          ),
        );
      }
    }

    if (allPoints.isNotEmpty) {
      await grammarRepository.saveGrammarPoints(allPoints);
    }
  }

  Future<void> seedVocabData() async {
    final existing = await vocabularyRepository.getAllVocabulary();
    final existingMap = {for (final v in existing) v.id: v};

    final levels = await _levelsWithAsset('vocabulary.json');

    final parsed = await Future.wait(
      levels.map((level) async {
        try {
          final bytes = await rootBundle.load(
            'assets/data/$level/vocabulary.json',
          );
          final response = utf8.decode(bytes.buffer.asUint8List());
          return MapEntry(level, await _decodeJsonList(response));
        } catch (e) {
          debugPrint('Error loading $level vocabulary: $e');
          return null;
        }
      }),
    );

    final allVocab = <Vocabulary>[];
    for (final entry in parsed) {
      if (entry == null) continue;
      final level = entry.key;
      final data = entry.value;
      for (final json in data) {
        final word = json['word'] as String;
        final id = '${level}_$word';
        final existingVocab = existingMap[id];
        allVocab.add(
          Vocabulary(
            id: id,
            word: word,
            reading: json['reading'] ?? '',
            meaning: json['meaning'] ?? '',
            jlptLevel: int.parse(level.replaceAll('n', '')),
            exampleSentencesJson: _encodeList(json['example_sentences']),
            imageUrl: _optionalString(json['image_url']),
            pitchAccent: _optionalString(json['pitch_accent']),
            partOfSpeech: _optionalString(json['part_of_speech']),
            // Preserve user progress
            stability: existingVocab?.stability ?? 0.0,
            difficulty: existingVocab?.difficulty ?? 0.0,
            lastReview: existingVocab?.lastReview,
            nextReview: existingVocab?.nextReview ?? DateTime.now(),
            reps: existingVocab?.reps ?? 0,
            lapses: existingVocab?.lapses ?? 0,
            state: existingVocab?.state ?? 0,
          ),
        );
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

  int? _optionalInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  Future<List<dynamic>> _decodeJsonList(String source) async {
    return json.decode(source) as List<dynamic>;
  }

  Future<void> _ensureManifest() async {
    if (_assetsCache != null) return;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _assetsCache = manifest.listAssets();
    } catch (e) {
      try {
        final jsonStr = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = json.decode(jsonStr);
        _assetsCache = manifestMap.keys.toList();
      } catch (innerErr) {
        debugPrint('Failed to load asset manifest: $innerErr');
        // Fallback list to ensure app never crashes on startup
        _assetsCache = [
          'assets/data/n5/kanji.json',
          'assets/data/n4/kanji.json',
          'assets/data/n3/kanji.json',
          'assets/data/n2/kanji.json',
          'assets/data/n1/kanji.json',
          'assets/data/n5/grammar.json',
          'assets/data/n4/grammar.json',
          'assets/data/n3/grammar.json',
          'assets/data/n2/grammar.json',
          'assets/data/n1/grammar.json',
          'assets/data/n5/vocabulary.json',
          'assets/data/n4/vocabulary.json',
          'assets/data/n3/vocabulary.json',
          'assets/data/n2/vocabulary.json',
          'assets/data/n1/vocabulary.json',
        ];
      }
    }
  }

  Future<List<String>> _levelsWithAsset(String fileName) async {
    await _ensureManifest();
    final assets = _assetsCache!;
    final pattern = RegExp('^assets/data/(n\\d+)/${RegExp.escape(fileName)}\$');
    final levels = assets
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
