import 'package:equatable/equatable.dart';
import 'srs_item.dart';

class KanjiCard extends Equatable implements SrsItem {
  @override
  final String id;
  final String kanji;
  final String meanings;
  final String onyomi;
  final String kunyomi;
  final String? strokeData;
  final int jlptLevel;
  
  // SRS data
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
  final int state; // 0: New, 1: Learning, 2: Review, 3: Relearning

  const KanjiCard({
    required this.id,
    required this.kanji,
    required this.meanings,
    required this.onyomi,
    required this.kunyomi,
    this.strokeData,
    this.jlptLevel = 5,
    this.stability = 0.0,
    this.difficulty = 0.0,
    this.lastReview,
    required this.nextReview,
    this.reps = 0,
    this.lapses = 0,
    this.state = 0,
  });

  @override
  List<Object?> get props => [
    id, kanji, meanings, onyomi, kunyomi, strokeData, jlptLevel,
    stability, difficulty, lastReview, nextReview, reps, lapses, state
  ];

  KanjiCard copyWith({
    String? id,
    String? kanji,
    String? meanings,
    String? onyomi,
    String? kunyomi,
    String? strokeData,
    int? jlptLevel,
    double? stability,
    double? difficulty,
    DateTime? lastReview,
    DateTime? nextReview,
    int? reps,
    int? lapses,
    int? state,
  }) {
    return KanjiCard(
      id: id ?? this.id,
      kanji: kanji ?? this.kanji,
      meanings: meanings ?? this.meanings,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      strokeData: strokeData ?? this.strokeData,
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
}
