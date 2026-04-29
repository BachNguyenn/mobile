import '../entities/grammar_point.dart';

abstract class GrammarRepository {
  Future<List<GrammarPoint>> getAllGrammarPoints();
  Future<List<GrammarPoint>> getGrammarPointsByLevel(int level);
  Future<GrammarPoint?> getGrammarPointById(String id);
  Future<void> saveGrammarPoints(List<GrammarPoint> points);
  Future<void> markAsLearned(String id, bool isLearned);
  Future<bool> submitReview({
    required String grammarId,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  });
  Future<List<GrammarPoint>> searchGrammar(String query, {int? jlptLevel});
}
