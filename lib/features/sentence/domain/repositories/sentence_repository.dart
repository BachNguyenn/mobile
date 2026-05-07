import 'package:mobile/features/sentence/domain/entities/sentence.dart';

abstract class SentenceRepository {
  Future<List<Sentence>> getAllSentences();
  Future<List<Sentence>> getSentencesByLevel(int level);
  Future<List<Sentence>> searchSentences(String query, {int? jlptLevel});
}
