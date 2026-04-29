import 'package:equatable/equatable.dart';
import 'package:mobile/core/srs/srs_item.dart';

class Vocabulary extends Equatable implements SrsItem {
  @override
  final String id;
  final String word;
  final String reading;
  final String meaning;
  final int jlptLevel;
  @override
  final double stability;
  @override
  final double difficulty;
  @override
  final DateTime? lastReview;
  @override
  final DateTime nextReview;
  @override
  final int reps;
  @override
  final int lapses;
  @override
  final int state;

  const Vocabulary({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
    this.jlptLevel = 5,
    this.stability = 0.0,
    this.difficulty = 0.0,
    this.lastReview,
    required this.nextReview,
    this.reps = 0,
    this.lapses = 0,
    this.state = 0,
  });

  Vocabulary copyWith({
    String? id,
    String? word,
    String? reading,
    String? meaning,
    int? jlptLevel,
    double? stability,
    double? difficulty,
    DateTime? lastReview,
    DateTime? nextReview,
    int? reps,
    int? lapses,
    int? state,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [
        id,
        word,
        reading,
        meaning,
        jlptLevel,
        stability,
        difficulty,
        lastReview,
        nextReview,
        reps,
        lapses,
        state,
      ];
}
