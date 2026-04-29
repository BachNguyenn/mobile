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

  DatabaseSeeder({
    required this.kanjiRepository,
    required this.grammarRepository,
    required this.vocabularyRepository,
  });

  Future<void> seedAll() async {
    await seedKanjiData();
    await seedGrammarData();
    await seedVocabData();
  }

  Future<void> seedKanjiData() async {
    final levels = ['n5', 'n4', 'n3', 'n2', 'n1'];
    
    for (final level in levels) {
      try {
        final ByteData bytes = await rootBundle.load('assets/data/$level/kanji.json');
        final String response = utf8.decode(bytes.buffer.asUint8List());
        final List<dynamic> data = json.decode(response);
        
        final List<KanjiCard> cards = data.map((json) {
          final char = json['character'] as String;
          return KanjiCard(
            id: '${level}_$char',
            kanji: char,
            meanings: (json['meanings'] as List).join(', '),
            onyomi: (json['on_reading'] as List).join(', '),
            kunyomi: (json['kun_reading'] as List).join(', '),
            jlptLevel: int.parse(level.replaceAll('n', '')),
            nextReview: DateTime.now(),
          );
        }).toList();
        
        await kanjiRepository.saveAllCards(cards);
      } catch (e) {
        debugPrint('Error seeding $level kanji: $e');
      }
    }
  }

  Future<void> seedGrammarData() async {
    final levels = ['n5', 'n4', 'n3'];
    
    for (final level in levels) {
      try {
        final ByteData bytes = await rootBundle.load('assets/data/$level/grammar.json');
        final String response = utf8.decode(bytes.buffer.asUint8List());
        final List<dynamic> data = json.decode(response);
        
        final List<GrammarPoint> points = data.map((json) {
          final title = json['title'] as String;
          return GrammarPoint(
            id: '${level}_$title',
            title: title,
            shortExplanation: json['short_explanation'] ?? '',
            longExplanation: json['long_explanation'] ?? '',
            formation: json['formation'] ?? '',
            jlptLevel: int.parse(level.replaceAll('n', '')),
            examples: (json['examples'] as List).map((e) => GrammarExample(
              jp: e['jp'] ?? '',
              romaji: e['romaji'] ?? '',
              en: e['en'] ?? '',
            )).toList(),
          );
        }).toList();
        
        await grammarRepository.saveGrammarPoints(points);
      } catch (e) {
        debugPrint('Error seeding $level grammar: $e');
      }
    }
  }

  Future<void> seedVocabData() async {
    final levels = ['n5', 'n4', 'n3', 'n2', 'n1'];
    
    for (final level in levels) {
      try {
        final ByteData bytes = await rootBundle.load('assets/data/$level/vocabulary.json');
        final String response = utf8.decode(bytes.buffer.asUint8List());
        final List<dynamic> data = json.decode(response);
        
        final List<Vocabulary> vocabList = data.map((json) {
          final word = json['word'] as String;
          return Vocabulary(
            id: '${level}_$word',
            word: word,
            reading: json['reading'] ?? '',
            meaning: json['meaning'] ?? '',
            jlptLevel: int.parse(level.replaceAll('n', '')),
            nextReview: DateTime.now(),
          );
        }).toList();
        
        await vocabularyRepository.saveVocabulary(vocabList);
      } catch (e) {
        debugPrint('Error seeding $level vocabulary: $e');
      }
    }
  }
}
