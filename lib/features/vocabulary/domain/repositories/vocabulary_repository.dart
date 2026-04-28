import '../entities/vocabulary.dart';

abstract class VocabularyRepository {
  Future<List<Vocabulary>> getAllVocabulary();
  Future<List<Vocabulary>> getVocabularyByLevel(int level);
  Future<Vocabulary?> getVocabularyById(String id);
  Future<void> saveVocabulary(List<Vocabulary> vocabList);
  Future<List<Vocabulary>> searchVocabulary(String query, {int? jlptLevel});
}
