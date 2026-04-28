import '../../features/kanji/domain/entities/kanji_card.dart';

class SrsService {
  /// Simple SRS calculation based on rating (1: Again, 2: Hard, 3: Good, 4: Easy)
  /// Returns a copy of the card with updated SRS fields.
  KanjiCard calculateNextReview(KanjiCard card, int rating) {
    final now = DateTime.now();
    int newReps = card.reps;
    int newLapses = card.lapses;
    int newState = card.state;
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

    return card.copyWith(
      reps: newReps,
      lapses: newLapses,
      state: newState,
      lastReview: now,
      nextReview: newNextReview,
    );
  }
}
