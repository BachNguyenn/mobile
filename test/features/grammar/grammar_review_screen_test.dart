import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_library_provider.dart';
import 'package:mobile/features/grammar/presentation/screens/grammar_review_screen.dart';

void main() {
  testWidgets('renders example, choices, and explanation after checking', (
    tester,
  ) async {
    final target = _grammar(
      id: 'g_te_mo_ii',
      title: 'te mo ii',
      meaning: 'asking for or giving permission',
      formation: 'Verb te-form + mo ii',
      example: 'Koko de shashin o totte mo ii desu.',
    );
    final allGrammar = [
      target,
      _grammar(id: 'g_must', meaning: 'must do something'),
      _grammar(id: 'g_exp', meaning: 'has done something before'),
      _grammar(id: 'g_while', meaning: 'doing two actions at once'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          grammarListProvider.overrideWith((ref) async => allGrammar),
          emitGrammarStudyEventProvider.overrideWith(
            (ref) => (id, rating) async {},
          ),
        ],
        child: MaterialApp(home: GrammarReviewScreen(items: [target])),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(grammarReviewExampleKey), findsOneWidget);
    expect(find.text(target.examples.first.jp), findsOneWidget);
    expect(find.text(target.shortExplanation), findsOneWidget);

    await tester.tap(
      find.byKey(grammarReviewOptionKey(target.shortExplanation)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    tester.widget<FilledButton>(find.byType(FilledButton)).onPressed!();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.byKey(grammarReviewAnswerPanelKey), findsOneWidget);
    expect(find.textContaining(target.formation), findsWidgets);
    expect(find.text(target.examples.first.en), findsOneWidget);
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
