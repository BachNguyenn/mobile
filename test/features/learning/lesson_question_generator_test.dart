import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/learning/domain/entities/quiz_question.dart';
import 'package:mobile/features/learning/domain/services/lesson_question_generator.dart';

void main() {
  group('LessonQuestionGenerator grammar flow', () {
    test('teaches a grammar point before asking meaning and usage questions', () {
      final target = _grammar(
        id: 'g1',
        title: '〜てもいい',
        meaning: 'Xin phép hoặc cho phép làm gì đó.',
        formation: 'Verb te-form + もいい',
        example: 'ここで写真を撮ってもいいです。',
      );
      final questions = LessonQuestionGenerator().generate(
        lessonKanji: const [],
        lessonVocabulary: const [],
        lessonGrammar: [target],
        allKanji: const [],
        allVocabulary: const [],
        allGrammar: [
          target,
          _grammar(
            id: 'g2',
            title: '〜なければならない',
            meaning: 'Phải làm gì đó.',
            formation: 'Verb nai-stem + なければならない',
            example: '宿題をしなければなりません。',
          ),
          _grammar(
            id: 'g3',
            title: '〜たことがある',
            meaning: 'Có kinh nghiệm từng làm gì đó.',
            formation: 'Verb ta-form + ことがある',
            example: '日本へ行ったことがあります。',
          ),
          _grammar(
            id: 'g4',
            title: '〜ながら',
            meaning: 'Vừa làm việc này vừa làm việc khác.',
            formation: 'Verb masu-stem + ながら',
            example: '音楽を聞きながら勉強します。',
          ),
        ],
      );

      expect(questions[0].type, QuizType.grammarStudy);
      expect(questions[0].isScored, isFalse);

      final meaning = questions.firstWhere(
        (question) => question.type == QuizType.grammarMeaning,
      );
      expect(meaning.prompt, contains('dùng để diễn tả ý nào'));
      expect(meaning.answer, target.shortExplanation);

      final usage = questions.firstWhere(
        (question) => question.type == QuizType.grammarUsage,
      );
      expect(usage.prompt, contains(target.examples.first.jp));
      expect(usage.answer, target.shortExplanation);
      expect(usage.explanation, contains('Ý chính'));
    });
  });
}

GrammarPoint _grammar({
  required String id,
  required String title,
  required String meaning,
  required String formation,
  required String example,
}) {
  return GrammarPoint(
    id: id,
    title: title,
    shortExplanation: meaning,
    longExplanation: 'Giải thích chi tiết cho $title.',
    formation: formation,
    examples: [
      GrammarExample(jp: example, romaji: '', en: 'Example translation.'),
    ],
  );
}
