import '../entities/vocabulary.dart';
import '../../../../core/srs/srs_item.dart';

abstract class VocabularyRepository {
  Future<List<Vocabulary>> getAllVocabulary();
  Future<List<Vocabulary>> getDueVocabulary(DateTime now, {int? jlptLevel, int? limit});
  Future<List<Vocabulary>> getVocabularyByLevel(int level);
  Future<Vocabulary?> getVocabularyById(String id);
  Future<void> saveVocabulary(List<Vocabulary> vocabList);
  Future<List<Vocabulary>> searchVocabulary(String query, {int? jlptLevel});
  Future<bool> submitReview({
    required SrsItem updatedItem,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  });
}
