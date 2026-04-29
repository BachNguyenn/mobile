import '../../features/kanji/domain/entities/kanji_card.dart';
import '../../features/vocabulary/domain/entities/vocabulary.dart';

class SrsService {
  /// Simple SRS calculation based on rating (1: Again, 2: Hard, 3: Good, 4: Easy)
  /// Returns a copy of the card with updated SRS fields.
  KanjiCard calculateNextReview(KanjiCard card, int rating) {
    final values = _calculateValues(
      reps: card.reps,
      lapses: card.lapses,
      state: card.state,
      rating: rating,
    );

    return card.copyWith(
      reps: values.reps,
      lapses: values.lapses,
      state: values.state,
      lastReview: values.lastReview,
      nextReview: values.nextReview,
    );
  }

  Vocabulary calculateNextVocabularyReview(Vocabulary vocabulary, int rating) {
    final values = _calculateValues(
      reps: vocabulary.reps,
      lapses: vocabulary.lapses,
      state: vocabulary.state,
      rating: rating,
    );

    return vocabulary.copyWith(
      reps: values.reps,
      lapses: values.lapses,
      state: values.state,
      lastReview: values.lastReview,
      nextReview: values.nextReview,
    );
  }

  _SrsValues _calculateValues({
    required int reps,
    required int lapses,
    required int state,
    required int rating,
  }) {
    final now = DateTime.now();
    int newReps = reps;
    int newLapses = lapses;
    int newState = state;
    DateTime newNextReview = now;

    if (rating == 1) { // Again
      newLapses++;
      newReps = 0;
      newState = 3; // Relearning
      newNextReview = now.add(const Duration(minutes: 1));
    } else {
      newReps++;
      newState = 2; // Review
      if (rating == 2) { // Hard
        newNextReview = now.add(Duration(days: (newReps * 0.5).round().clamp(1, 365)));
      } else if (rating == 3) { // Good
        newNextReview = now.add(Duration(days: newReps));
      } else if (rating == 4) { // Easy
        newNextReview = now.add(Duration(days: newReps * 2));
      }
    }

    return _SrsValues(
      reps: newReps,
      lapses: newLapses,
      state: newState,
      lastReview: now,
      nextReview: newNextReview,
    );
  }
}

class _SrsValues {
  final DateTime lastReview;
  final DateTime nextReview;
  final int reps;
  final int lapses;
  final int state;

  const _SrsValues({
    required this.lastReview,
    required this.nextReview,
    required this.reps,
    required this.lapses,
    required this.state,
  });
}
