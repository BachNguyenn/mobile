import 'dart:math' as math;

import '../../features/kanji/domain/entities/kanji_card.dart';
import '../../features/vocabulary/domain/entities/vocabulary.dart';

class SrsService {
  static const double _defaultDifficulty = 5.0;
  static const double _defaultStability = 0.2; // days
  static const double _targetRetention = 0.9;
  static const FsrsParameters _params = FsrsParameters.defaultSet();

  /// FSRS-lite calculation based on rating (1: Again, 2: Hard, 3: Good, 4: Easy)
  /// Updates stability/difficulty and schedules next review from those values.
  KanjiCard calculateNextReview(KanjiCard card, int rating) {
    final values = _calculateValues(
      stability: card.stability,
      difficulty: card.difficulty,
      reps: card.reps,
      lapses: card.lapses,
      state: card.state,
      rating: rating,
    );

    return card.copyWith(
      stability: values.stability,
      difficulty: values.difficulty,
      reps: values.reps,
      lapses: values.lapses,
      state: values.state,
      lastReview: values.lastReview,
      nextReview: values.nextReview,
    );
  }

  Vocabulary calculateNextVocabularyReview(Vocabulary vocabulary, int rating) {
    final values = _calculateValues(
      stability: vocabulary.stability,
      difficulty: vocabulary.difficulty,
      reps: vocabulary.reps,
      lapses: vocabulary.lapses,
      state: vocabulary.state,
      rating: rating,
    );

    return vocabulary.copyWith(
      stability: values.stability,
      difficulty: values.difficulty,
      reps: values.reps,
      lapses: values.lapses,
      state: values.state,
      lastReview: values.lastReview,
      nextReview: values.nextReview,
    );
  }

  _SrsValues _calculateValues({
    required double stability,
    required double difficulty,
    required int reps,
    required int lapses,
    required int state,
    required int rating,
  }) {
    final now = DateTime.now();
    final normalizedRating = rating.clamp(1, 4);
    final currentDifficulty = difficulty > 0 ? difficulty : _defaultDifficulty;
    final currentStability = stability > 0 ? stability : _defaultStability;
    final elapsedDays = _elapsedDays(now, state, reps, lapses, currentStability);
    final retrievability = _retrievability(elapsedDays, currentStability);

    int newReps = reps;
    int newLapses = lapses;
    int newState = state;
    double newDifficulty = currentDifficulty;
    double newStability = currentStability;
    DateTime newNextReview = now;

    if (normalizedRating == 1) {
      // Failed recall: lower stability sharply and increase difficulty.
      newLapses++;
      newReps = 0;
      newState = 3;
      newDifficulty = (currentDifficulty + _params.failedDifficultyPenalty)
          .clamp(1.0, 10.0);
      newStability =
          (currentStability * _params.failedStabilityMultiplier).clamp(0.02, 3650.0);
      newNextReview = now.add(const Duration(minutes: 1));
    } else {
      newReps++;
      newState = 2;
      newDifficulty = _nextDifficulty(currentDifficulty, normalizedRating, retrievability);
      newStability = _nextStability(
        currentStability: currentStability,
        nextDifficulty: newDifficulty,
        rating: normalizedRating,
        retrievability: retrievability,
      );
      final interval = _stabilityToInterval(newStability, normalizedRating);
      newNextReview = now.add(interval);
    }

    return _SrsValues(
      stability: newStability,
      difficulty: newDifficulty,
      reps: newReps,
      lapses: newLapses,
      state: newState,
      lastReview: now,
      nextReview: newNextReview,
    );
  }

  double _nextDifficulty(
    double currentDifficulty,
    int rating,
    double retrievability,
  ) {
    // Hard answers increase difficulty slightly, Easy reduces more aggressively.
    final deltaByRating = <int, double>{
      2: _params.hardDifficultyDelta,
      3: _params.goodDifficultyDelta,
      4: _params.easyDifficultyDelta,
    };
    final baseDelta = deltaByRating[rating] ?? 0.0;
    final retrievalPenalty = (1 - retrievability) * _params.lowRetrievabilityDifficultyBoost;
    final delta = baseDelta + retrievalPenalty;
    return (currentDifficulty + delta).clamp(1.0, 10.0);
  }

  double _nextStability({
    required double currentStability,
    required double nextDifficulty,
    required int rating,
    required double retrievability,
  }) {
    // Lower difficulty and higher retrievability allow faster growth.
    final ease = ((11.0 - nextDifficulty) / 10.0).clamp(0.1, 1.0);
    final growthByRating = <int, double>{
      2: _params.hardGrowth,
      3: _params.goodGrowth,
      4: _params.easyGrowth,
    };
    final growth = growthByRating[rating] ?? 0.0;
    final retentionFactor = (0.6 + (retrievability * 0.4)).clamp(0.4, 1.0);
    final next = currentStability * (1 + growth * ease * retentionFactor);
    return next.clamp(0.02, 3650.0);
  }

  Duration _stabilityToInterval(double stability, int rating) {
    // FSRS-style interval from stability and desired retention.
    final fsrsDays = stability * math.log(_targetRetention) / math.log(0.9);
    final baseDays = math.max(1, fsrsDays.round());
    final multiplierByRating = <int, double>{
      2: _params.hardIntervalMultiplier,
      3: _params.goodIntervalMultiplier,
      4: _params.easyIntervalMultiplier,
    };
    final multiplied = (baseDays * (multiplierByRating[rating] ?? 1.0)).round();
    final intervalDays = multiplied.clamp(1, 3650);
    return Duration(days: intervalDays);
  }

  double _retrievability(double elapsedDays, double stability) {
    if (stability <= 0) return 0.0;
    return math.exp(math.log(0.9) * elapsedDays / stability).clamp(0.0, 1.0);
  }

  double _elapsedDays(
    DateTime now,
    int state,
    int reps,
    int lapses,
    double fallbackStability,
  ) {
    // We don't persist exact previous interval yet, so estimate from review state.
    if (state == 0 || reps == 0) return 0.0;
    final rough = math.max(0.1, fallbackStability * (1 + lapses * 0.05));
    return rough;
  }
}

class FsrsParameters {
  final double hardDifficultyDelta;
  final double goodDifficultyDelta;
  final double easyDifficultyDelta;
  final double failedDifficultyPenalty;
  final double failedStabilityMultiplier;
  final double lowRetrievabilityDifficultyBoost;
  final double hardGrowth;
  final double goodGrowth;
  final double easyGrowth;
  final double hardIntervalMultiplier;
  final double goodIntervalMultiplier;
  final double easyIntervalMultiplier;

  const FsrsParameters({
    required this.hardDifficultyDelta,
    required this.goodDifficultyDelta,
    required this.easyDifficultyDelta,
    required this.failedDifficultyPenalty,
    required this.failedStabilityMultiplier,
    required this.lowRetrievabilityDifficultyBoost,
    required this.hardGrowth,
    required this.goodGrowth,
    required this.easyGrowth,
    required this.hardIntervalMultiplier,
    required this.goodIntervalMultiplier,
    required this.easyIntervalMultiplier,
  });

  const FsrsParameters.defaultSet()
      : hardDifficultyDelta = 0.2,
        goodDifficultyDelta = -0.1,
        easyDifficultyDelta = -0.3,
        failedDifficultyPenalty = 0.4,
        failedStabilityMultiplier = 0.45,
        lowRetrievabilityDifficultyBoost = 0.2,
        hardGrowth = 0.22,
        goodGrowth = 0.55,
        easyGrowth = 0.95,
        hardIntervalMultiplier = 0.8,
        goodIntervalMultiplier = 1.0,
        easyIntervalMultiplier = 1.3;
}

class _SrsValues {
  final DateTime lastReview;
  final DateTime nextReview;
  final double stability;
  final double difficulty;
  final int reps;
  final int lapses;
  final int state;

  const _SrsValues({
    required this.lastReview,
    required this.nextReview,
    required this.stability,
    required this.difficulty,
    required this.reps,
    required this.lapses,
    required this.state,
  });
}
