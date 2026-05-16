import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/sentence/domain/entities/sentence.dart';
import 'package:mobile/features/sentence/presentation/providers/sentence_provider.dart';
import 'package:mobile/features/sentence/presentation/screens/sentence_practice_screen.dart';

void main() {
  const sentence = Sentence(
    id: 'sentence_n5_desu_0',
    text: '私は学生です。',
    reading: 'watashi wa gakusei desu.',
    meaning: 'I am a student.',
    jlptLevel: 5,
    sourceGrammarId: 'n5_desu',
    sourceGrammarTitle: 'です',
  );

  testWidgets('renders prompt, choices, and TTS button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dueSentencePracticeProvider.overrideWith(
            (ref) async => const [
              sentence,
              Sentence(
                id: 'sentence_n5_water_0',
                text: '水を飲みます。',
                reading: 'mizu o nomimasu.',
                meaning: 'I drink water.',
                jlptLevel: 5,
                sourceGrammarId: 'n5_water',
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: SentencePracticeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('私は学生です。'), findsOneWidget);
    expect(find.text('I am a student.'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });

  testWidgets('typing mode enables check after input and shows feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dueSentencePracticeProvider.overrideWith(
            (ref) async => const [sentence],
          ),
        ],
        child: const MaterialApp(home: SentencePracticeScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(sentenceModeTypingKey));
    await tester.pumpAndSettle();

    final checkButton = find.byKey(sentenceCheckButtonKey);
    final filledCheckButton = find.descendant(
      of: checkButton,
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(filledCheckButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '私は学生です。');
    await tester.pump();

    expect(tester.widget<FilledButton>(filledCheckButton).onPressed, isNotNull);
    await tester.tap(checkButton);
    await tester.pumpAndSettle();

    expect(find.byKey(sentenceCorrectFeedbackKey), findsOneWidget);
  });

  testWidgets('shows learning summary and progressive hint', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dueSentencePracticeProvider.overrideWith(
            (ref) async => const [sentence],
          ),
        ],
        child: const MaterialApp(home: SentencePracticeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(sentenceSessionSummaryKey), findsOneWidget);
    expect(find.byKey(sentenceHintButtonKey), findsOneWidget);

    await tester.tap(find.byKey(sentenceHintButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('watashi wa gakusei desu.'), findsWidgets);
  });
}
