import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/srs/fsrs_engine.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';

void main() {
  group('SrsService', () {
    late SrsService service;

    setUp(() {
      service = SrsService();
    });

    test(
      'Again resets reps, increases lapses, and schedules near-term review',
      () {
        final before = DateTime.now();
        final card = _kanjiCard(
          reps: 4,
          lapses: 1,
          state: 2,
          stability: 3.0,
          difficulty: 4.5,
        );

        final updated = service.calculateNext(card, 1);

        expect(updated.reps, 0);
        expect(updated.lapses, 2);
        expect(updated.state, 3);
        expect(updated.difficulty, greaterThan(card.difficulty));
        expect(updated.stability, lessThan(card.stability));
        expect(
          updated.nextReview.isAfter(before.add(const Duration(seconds: 30))),
          isTrue,
        );
        expect(
          updated.nextReview.isBefore(before.add(const Duration(minutes: 3))),
          isTrue,
        );
      },
    );

    test('Good increases stability and keeps/lowers difficulty', () {
      final before = DateTime.now();
      final card = _kanjiCard(
        reps: 2,
        lapses: 0,
        state: 2,
        stability: 2.0,
        difficulty: 6.0,
      );

      final updated = service.calculateNext(card, 3);

      expect(updated.reps, 3);
      expect(updated.lapses, 0);
      expect(updated.state, 2);
      expect(updated.stability, greaterThan(card.stability));
      expect(updated.difficulty, lessThanOrEqualTo(card.difficulty));
      expect(
        updated.nextReview.isAfter(before.add(const Duration(hours: 12))),
        isTrue,
      );
    });

    test(
      'Easy produces longer interval than Hard from same starting point',
      () {
        final baseline = _kanjiCard(
          reps: 3,
          lapses: 0,
          state: 2,
          stability: 4.0,
          difficulty: 5.0,
        );

        final hard = service.calculateNext(baseline, 2);
        final easy = service.calculateNext(baseline, 4);

        expect(easy.stability, greaterThan(hard.stability));
        expect(easy.nextReview.isAfter(hard.nextReview), isTrue);
      },
    );

    test('Vocabulary review updates stability and nextReview consistently', () {
      final vocab = _vocabulary(
        reps: 1,
        lapses: 0,
        state: 2,
        stability: 1.0,
        difficulty: 5.5,
      );

      final updated = service.calculateNext(vocab, 3);

      expect(updated.reps, 2);
      expect(updated.state, 2);
      expect(updated.stability, greaterThan(vocab.stability));
      expect(updated.nextReview.isAfter(DateTime.now()), isTrue);
    });
  });
}

KanjiCard _kanjiCard({
  required int reps,
  required int lapses,
  required int state,
  required double stability,
  required double difficulty,
}) {
  return KanjiCard(
    id: 'k1',
    kanji: '日',
    meanings: 'sun, day',
    onyomi: 'ニチ',
    kunyomi: 'ひ',
    nextReview: DateTime.now(),
    reps: reps,
    lapses: lapses,
    state: state,
    stability: stability,
    difficulty: difficulty,
  );
}

Vocabulary _vocabulary({
  required int reps,
  required int lapses,
  required int state,
  required double stability,
  required double difficulty,
}) {
  return Vocabulary(
    id: 'v1',
    word: '水',
    reading: 'みず',
    meaning: 'water',
    nextReview: DateTime.now(),
    reps: reps,
    lapses: lapses,
    state: state,
    stability: stability,
    difficulty: difficulty,
  );
}
