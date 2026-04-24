import '../entities/kanji_card.dart';

abstract class KanjiRepository {
  Future<List<KanjiCard>> getAllCards();
  Future<List<KanjiCard>> getDueCards(DateTime now);
  Future<void> saveCard(KanjiCard card);
  Future<void> saveAllCards(List<KanjiCard> cards);
  Future<List<KanjiCard>> searchKanji(String query, {int? jlptLevel});
}