import 'dart:math';

import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/learning/domain/entities/quiz_question.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';

class LessonQuestionGenerator {
  final Random _random;

  LessonQuestionGenerator({Random? random}) : _random = random ?? Random();

  List<QuizQuestion> generate({
    required List<KanjiCard> lessonKanji,
    required List<Vocabulary> lessonVocabulary,
    required List<GrammarPoint> lessonGrammar,
    required List<KanjiCard> allKanji,
    required List<Vocabulary> allVocabulary,
    List<GrammarPoint> allGrammar = const [],
  }) {
    final questions = <QuizQuestion>[];
    final allKanjiMeanings = _uniqueNonEmpty(allKanji.map((k) => k.meanings));
    final allKanjiReadings = _uniqueNonEmpty(
      allKanji.expand((k) => [k.onyomi, k.kunyomi]),
    );
    final allVocabMeanings = _uniqueNonEmpty(allVocabulary.map((v) => v.meaning));
    final allVocabReadings = _uniqueNonEmpty(allVocabulary.map((v) => v.reading));
    final allVocabWords = _uniqueNonEmpty(allVocabulary.map((v) => v.word));
    final grammarExplanations = _uniqueNonEmpty(
      allGrammar.map((g) => g.shortExplanation),
    );
    final grammarFormations = _uniqueNonEmpty(allGrammar.map((g) => g.formation));

    for (final grammar in lessonGrammar) {
      questions.add(
        QuizQuestion(
          id: grammar.id,
          type: QuizType.grammarStudy,
          prompt: grammar.title,
          answer: '',
          hint: grammar.shortExplanation,
          explanation: grammar.longExplanation,
          inputMode: QuizInputMode.study,
          payload: GrammarQuizPayload(grammar),
        ),
      );

      _addMultipleChoice(
        questions,
        id: grammar.id,
        type: QuizType.grammarMeaning,
        prompt: grammar.title,
        answer: grammar.shortExplanation,
        pool: grammarExplanations,
        hint: grammar.formation,
        explanation: grammar.longExplanation,
        payload: GrammarQuizPayload(grammar),
      );

      _addMultipleChoice(
        questions,
        id: grammar.id,
        type: QuizType.grammarFormation,
        prompt: grammar.shortExplanation.isNotEmpty
            ? grammar.shortExplanation
            : grammar.title,
        answer: grammar.formation,
        pool: grammarFormations,
        hint: grammar.title,
        explanation: grammar.longExplanation,
        payload: GrammarQuizPayload(grammar),
      );

      final example = grammar.examples.isNotEmpty ? grammar.examples.first : null;
      if (example != null) {
        _addMultipleChoice(
          questions,
          id: '${grammar.id}-usage',
          type: QuizType.grammarUsage,
          prompt: example.jp,
          answer: grammar.formation,
          pool: grammarFormations,
          hint: example.romaji,
          explanation: example.en,
          payload: GrammarQuizPayload(grammar),
        );
      }
    }

    final usedVocabIds = <String>{};
    for (final kanji in lessonKanji) {
      _addMultipleChoice(
        questions,
        id: kanji.id,
        type: QuizType.meaning,
        prompt: kanji.kanji,
        answer: kanji.meanings,
        pool: allKanjiMeanings,
        hint: _readingHint(kanji.onyomi, kanji.kunyomi),
        explanation: 'On: ${kanji.onyomi} | Kun: ${kanji.kunyomi}',
        payload: KanjiQuizPayload(kanji),
      );

      final readingAnswer = _primaryReading(kanji);
      _addMultipleChoice(
        questions,
        id: '${kanji.id}-reading',
        type: QuizType.kanjiReading,
        prompt: kanji.kanji,
        answer: readingAnswer,
        pool: allKanjiReadings,
        hint: kanji.meanings,
        explanation: 'Nghĩa: ${kanji.meanings}',
        payload: KanjiQuizPayload(kanji),
      );

      questions.add(
        QuizQuestion(
          id: '${kanji.id}-handwriting',
          type: QuizType.handwriting,
          prompt: kanji.meanings,
          answer: kanji.kanji,
          hint: _readingHint(kanji.onyomi, kanji.kunyomi),
          explanation: 'On: ${kanji.onyomi} | Kun: ${kanji.kunyomi}',
          inputMode: QuizInputMode.handwriting,
          payload: KanjiQuizPayload(kanji),
        ),
      );

      final relatedVocab = lessonVocabulary
          .where((vocab) => vocab.word.contains(kanji.kanji))
          .toList();
      for (final vocab in relatedVocab) {
        if (usedVocabIds.add(vocab.id)) {
          _addVocabQuestions(
            questions,
            vocab,
            allVocabMeanings,
            allVocabReadings,
            allVocabWords,
          );
        }
      }
    }

    final remainingVocab = lessonVocabulary
        .where((vocab) => !usedVocabIds.contains(vocab.id))
        .toList();
    for (final vocab in remainingVocab) {
      _addVocabQuestions(
        questions,
        vocab,
        allVocabMeanings,
        allVocabReadings,
        allVocabWords,
      );
    }

    questions.shuffle(_random);
    return questions;
  }

  void _addVocabQuestions(
    List<QuizQuestion> questions,
    Vocabulary vocab,
    List<String> allVocabMeanings,
    List<String> allReadings,
    List<String> allWords,
  ) {
    _addMultipleChoice(
      questions,
      id: vocab.id,
      type: QuizType.vocabMeaning,
      prompt: vocab.word,
      answer: vocab.meaning,
      pool: allVocabMeanings,
      hint: vocab.reading,
      explanation: 'Cách đọc: ${vocab.reading}',
      payload: VocabularyQuizPayload(vocab),
    );

    if (vocab.reading.isNotEmpty && vocab.reading != vocab.word) {
      _addMultipleChoice(
        questions,
        id: '${vocab.id}-reading',
        type: QuizType.vocabReading,
        prompt: vocab.word,
        answer: vocab.reading,
        pool: allReadings,
        hint: vocab.meaning,
        explanation: 'Nghĩa: ${vocab.meaning}',
        payload: VocabularyQuizPayload(vocab),
      );
    }

    _addMultipleChoice(
      questions,
      id: '${vocab.id}-reverse',
      type: QuizType.vocabReverse,
      prompt: vocab.meaning,
      answer: vocab.word,
      pool: allWords,
      hint: vocab.reading,
      explanation: 'Cách đọc: ${vocab.reading}',
      payload: VocabularyQuizPayload(vocab),
    );
  }

  void _addMultipleChoice(
    List<QuizQuestion> questions, {
    required String id,
    required QuizType type,
    required String prompt,
    required String answer,
    required List<String> pool,
    required QuizPayload payload,
    String? hint,
    String? explanation,
  }) {
    if (prompt.isEmpty || answer.isEmpty) return;

    final options = _buildOptions(answer, pool);
    if (options == null) return;

    questions.add(
      QuizQuestion(
        id: id,
        type: type,
        prompt: prompt,
        answer: answer,
        options: options,
        hint: hint,
        explanation: explanation,
        inputMode: QuizInputMode.multipleChoice,
        payload: payload,
      ),
    );
  }

  List<String>? _buildOptions(String correct, List<String> all) {
    final distractors = _getDistractors(correct, all);
    if (distractors.isEmpty) return null;

    return ([...distractors, correct]..shuffle(_random));
  }

  List<String> _getDistractors(String correct, List<String> all) {
    final candidates = all
        .where((item) => item.isNotEmpty && item != correct)
        .toSet()
        .toList();
    if (candidates.isEmpty) return const [];

    candidates.shuffle(_random);
    return candidates.take(3).toList();
  }

  List<String> _uniqueNonEmpty(Iterable<String> values) =>
      values.where((value) => value.trim().isNotEmpty).toSet().toList();

  String _primaryReading(KanjiCard kanji) {
    if (kanji.onyomi.isNotEmpty) return kanji.onyomi;
    if (kanji.kunyomi.isNotEmpty) return kanji.kunyomi;
    return '';
  }

  String _readingHint(String onyomi, String kunyomi) {
    final parts = <String>[
      if (onyomi.isNotEmpty) 'On: $onyomi',
      if (kunyomi.isNotEmpty) 'Kun: $kunyomi',
    ];
    return parts.join(' | ');
  }
}
