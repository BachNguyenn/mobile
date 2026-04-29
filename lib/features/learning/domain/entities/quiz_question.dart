import 'package:flutter/material.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';

enum QuizType {
  meaning,
  kanji,
  handwriting,
  kanjiReading,
  vocabMeaning,
  vocabReading,
  vocabReverse,
  grammarStudy,
  grammarMeaning,
  grammarFormation,
  grammarUsage,
}

enum QuizInputMode { multipleChoice, handwriting, study }

sealed class QuizPayload {
  const QuizPayload();
}

class KanjiQuizPayload extends QuizPayload {
  final KanjiCard card;

  const KanjiQuizPayload(this.card);
}

class VocabularyQuizPayload extends QuizPayload {
  final Vocabulary vocabulary;

  const VocabularyQuizPayload(this.vocabulary);
}

class GrammarQuizPayload extends QuizPayload {
  final GrammarPoint grammarPoint;

  const GrammarQuizPayload(this.grammarPoint);
}

@immutable
class QuizQuestion {
  final String id;
  final QuizType type;
  final String prompt;
  final String answer;
  final List<String> options;
  final String? hint;
  final String? explanation;
  final QuizInputMode inputMode;
  final QuizPayload? payload;

  const QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.answer,
    this.options = const [],
    this.hint,
    this.explanation,
    this.inputMode = QuizInputMode.multipleChoice,
    this.payload,
  });
}
