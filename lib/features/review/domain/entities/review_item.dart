import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';

enum ReviewItemType { kanji, vocabulary, grammar }

class ReviewItem {
  final String id;
  final ReviewItemType type;
  final String prompt;
  final String answer;
  final String? subtitle;
  final List<String> choices;
  final int jlptLevel;
  final KanjiCard? kanji;
  final Vocabulary? vocabulary;
  final GrammarPoint? grammar;

  const ReviewItem({
    required this.id,
    required this.type,
    required this.prompt,
    required this.answer,
    this.subtitle,
    this.choices = const [],
    required this.jlptLevel,
    this.kanji,
    this.vocabulary,
    this.grammar,
  });

  factory ReviewItem.fromKanji(KanjiCard card) {
    return ReviewItem(
      id: card.id,
      type: ReviewItemType.kanji,
      prompt: card.meanings,
      answer: card.kanji,
      subtitle: '${card.onyomi} / ${card.kunyomi}',
      jlptLevel: card.jlptLevel,
      kanji: card,
    );
  }

  factory ReviewItem.fromVocabulary(
    Vocabulary vocabulary, {
    List<String> choices = const [],
  }) {
    return ReviewItem(
      id: vocabulary.id,
      type: ReviewItemType.vocabulary,
      prompt: vocabulary.word,
      answer: vocabulary.meaning,
      subtitle: vocabulary.reading,
      choices: choices,
      jlptLevel: vocabulary.jlptLevel,
      vocabulary: vocabulary,
    );
  }

  factory ReviewItem.fromGrammar(GrammarPoint grammar) {
    final firstExample = grammar.examples.isNotEmpty ? grammar.examples.first.jp : null;
    return ReviewItem(
      id: grammar.id,
      type: ReviewItemType.grammar,
      prompt: grammar.title,
      answer: grammar.shortExplanation.isNotEmpty
          ? grammar.shortExplanation
          : grammar.longExplanation,
      subtitle: firstExample ?? grammar.formation,
      jlptLevel: grammar.jlptLevel,
      grammar: grammar,
    );
  }

  bool get usesHandwriting => type == ReviewItemType.kanji;
}
