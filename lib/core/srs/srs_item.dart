abstract class SrsItem {
  String get id;
  double get stability;
  double get difficulty;
  DateTime? get lastReview;
  DateTime get nextReview;
  int get reps;
  int get lapses;
  int get state; // 0: New, 1: Learning, 2: Review, 3: Relearning
}
