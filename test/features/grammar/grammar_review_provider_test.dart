import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/grammar/application/providers/grammar_library_provider.dart';
import 'package:mobile/features/grammar/application/providers/grammar_review_provider.dart';

void main() {
  group('GrammarReviewQuestionGenerator', () {
    test('includes the correct answer with unique options capped at four', () {
      final target = _grammar(
        id: 'g_te_mo_ii',
        title: 'te mo ii',
        meaning: 'asking for or giving permission',
        formation: 'Verb te-form + mo ii',
        example: 'Koko de shashin o totte mo ii desu.',
      );

      final questions = const GrammarReviewQuestionGenerator().generate(
        items: [target],
        allGrammar: [
          target,
          _grammar(id: 'g_must', meaning: 'must do something'),
          _grammar(id: 'g_exp', meaning: 'has done something before'),
          _grammar(id: 'g_while', meaning: 'doing two actions at once'),
          _grammar(id: 'g_only', meaning: 'only or just'),
        ],
      );

      expect(questions, hasLength(1));
      expect(questions.single.answer, target.shortExplanation);
      expect(questions.single.options, contains(target.shortExplanation));
      expect(questions.single.options.toSet(), hasLength(4));
      expect(questions.single.options, hasLength(4));
      expect(questions.single.prompt, contains(target.title));
      expect(questions.single.example?.jp, target.examples.first.jp);
    });

    test('falls back when example or short explanation is missing', () {
      const target = GrammarPoint(
        id: 'g_fallback',
        title: 'fallback pattern',
        shortExplanation: '',
        longExplanation: '',
        formation: 'Noun + dake',
        examples: [],
      );

      final questions = const GrammarReviewQuestionGenerator().generate(
        items: const [target],
        allGrammar: const [target],
      );

      expect(questions.single.answer, target.formation);
      expect(questions.single.example, isNull);
      expect(questions.single.hint, contains(target.formation));
      expect(questions.single.prompt, contains('cấu trúc'));
    });
  });

  test('controller submits a grammar rating only once', () async {
    var calls = 0;
    final target = _grammar(id: 'g_once', meaning: 'single submit target');
    final deck = GrammarReviewDeck(items: [target], allGrammar: [target]);
    final container = ProviderContainer(
      overrides: [
        emitGrammarStudyEventProvider.overrideWith(
          (ref) => (id, rating) async {
            calls++;
          },
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = grammarReviewControllerProvider(deck);
    final controller = container.read(provider.notifier);
    final answer = container.read(provider).currentQuestion!.answer;

    controller.selectAnswer(answer);
    controller.checkAnswer();
    await controller.rateCurrent(3);
    await controller.rateCurrent(3);

    expect(calls, 1);
    expect(container.read(provider).isFinished, isTrue);
  });
}

GrammarPoint _grammar({
  required String id,
  String title = 'pattern',
  String meaning = 'sample meaning',
  String formation = 'sample formation',
  String example = 'sample example',
}) {
  return GrammarPoint(
    id: id,
    title: title,
    shortExplanation: meaning,
    longExplanation: 'Long explanation for $title.',
    formation: formation,
    examples: [
      GrammarExample(jp: example, romaji: 'romaji', en: 'Example meaning.'),
    ],
  );
}
