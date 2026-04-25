import '../entities/kanji_card.dart';
import '../entities/srs_item.dart';

abstract class KanjiRepository {
  Future<List<KanjiCard>> getAllCards();
  Future<List<KanjiCard>> getDueCards(DateTime now, {int? jlptLevel, int? limit});
  Future<KanjiCard?> getCardById(String id);
  Future<void> saveCard(KanjiCard card);
  Future<void> saveAllCards(List<KanjiCard> cards);
  Future<List<KanjiCard>> searchKanji(String query, {int? jlptLevel});
  Future<bool> submitReview({
    required SrsItem updatedItem,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  });

  Future<KanjiCard?> getCardByKanji(String kanji);
}