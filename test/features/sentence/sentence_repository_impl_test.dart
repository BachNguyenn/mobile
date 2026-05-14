import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:mobile/features/learning/domain/services/quiz_answer_normalizer.dart';
import 'package:mobile/features/sentence/data/repositories/sentence_repository_impl.dart';

void main() {
  group('SentenceRepositoryImpl', () {
    test('derives stable sentences from grammar examples', () async {
      final repository = SentenceRepositoryImpl(
        _FakeGrammarRepository([
          const GrammarPoint(
            id: 'n5_desu',
            title: 'です',
            shortExplanation: 'to be',
            longExplanation: '',
            formation: 'N + です',
            jlptLevel: 5,
            examples: [
              GrammarExample(
                jp: '私は学生です。',
                romaji: 'watashi wa gakusei desu.',
                en: 'I am a student.',
              ),
            ],
          ),
        ]),
      );

      final sentences = await repository.getAllSentences();

      expect(sentences, hasLength(1));
      expect(sentences.single.id, 'sentence_n5_desu_0');
      expect(sentences.single.text, '私は学生です。');
      expect(sentences.single.reading, 'watashi wa gakusei desu.');
      expect(sentences.single.meaning, 'I am a student.');
      expect(sentences.single.jlptLevel, 5);
      expect(sentences.single.sourceGrammarId, 'n5_desu');
      expect(sentences.single.sourceGrammarTitle, 'です');
    });

    test('skips empty examples', () async {
      final repository = SentenceRepositoryImpl(
        _FakeGrammarRepository([
          const GrammarPoint(
            id: 'n5_empty',
            title: 'empty',
            shortExplanation: '',
            longExplanation: '',
            formation: '',
            examples: [
              GrammarExample(jp: '', romaji: '', en: 'No Japanese.'),
              GrammarExample(jp: '水です。', romaji: 'mizu desu.', en: ''),
            ],
          ),
        ]),
      );

      expect(await repository.getAllSentences(), isEmpty);
    });

    test('searches text, reading, meaning, and grammar title', () async {
      final repository = SentenceRepositoryImpl(
        _FakeGrammarRepository([
          const GrammarPoint(
            id: 'n5_water',
            title: '水 grammar',
            shortExplanation: '',
            longExplanation: '',
            formation: '',
            jlptLevel: 5,
            examples: [
              GrammarExample(
                jp: '水を飲みます。',
                romaji: 'mizu o nomimasu.',
                en: 'I drink water.',
              ),
            ],
          ),
        ]),
      );

      expect(await repository.searchSentences('水'), hasLength(1));
      expect(await repository.searchSentences('nomimasu'), hasLength(1));
      expect(await repository.searchSentences('drink'), hasLength(1));
      expect(await repository.searchSentences('water'), hasLength(1));
      expect(await repository.searchSentences('missing'), isEmpty);
      expect(await repository.searchSentences('drink', jlptLevel: 4), isEmpty);
    });
  });

  group('QuizAnswerNormalizer', () {
    test('accepts exact Japanese answers', () {
      expect(QuizAnswerNormalizer.isCorrect('私は学生です。', '私は学生です。'), isTrue);
    });

    test('tolerates leading trailing and repeated whitespace', () {
      expect(
        QuizAnswerNormalizer.isCorrect('  mizu   desu  ', 'mizu desu'),
        isTrue,
      );
      expect(QuizAnswerNormalizer.isCorrect('mizu　desu', 'mizu desu'), isTrue);
    });

    test('rejects wrong kana or kanji', () {
      expect(QuizAnswerNormalizer.isCorrect('水です。', '火です。'), isFalse);
    });
  });
}

class _FakeGrammarRepository implements GrammarRepository {
  final List<GrammarPoint> points;

  _FakeGrammarRepository(this.points);

  @override
  Future<List<GrammarPoint>> getAllGrammarPoints() async => points;

  @override
  Future<GrammarPoint?> getGrammarPointById(String id) async {
    return points.where((point) => point.id == id).firstOrNull;
  }

  @override
  Future<List<GrammarPoint>> getGrammarPointsByLevel(int level) async {
    return points.where((point) => point.jlptLevel == level).toList();
  }

  @override
  Future<int> countGrammarPoints({int? jlptLevel}) async {
    return jlptLevel == null
        ? points.length
        : points.where((point) => point.jlptLevel == jlptLevel).length;
  }

  @override
  Future<int> countLearnedGrammar({int? jlptLevel}) async {
    return points
        .where(
          (point) =>
              point.isLearned &&
              (jlptLevel == null || point.jlptLevel == jlptLevel),
        )
        .length;
  }

  @override
  Future<int> countDueGrammar({int? jlptLevel}) async {
    final total = await countGrammarPoints(jlptLevel: jlptLevel);
    final learned = await countLearnedGrammar(jlptLevel: jlptLevel);
    return total - learned;
  }

  @override
  Future<void> markAsLearned(String id, bool isLearned) async {}

  @override
  Future<void> saveGrammarPoints(List<GrammarPoint> points) async {}

  @override
  Future<List<GrammarPoint>> searchGrammar(
    String query, {
    int? jlptLevel,
  }) async {
    return points;
  }

  @override
  Future<bool> submitReview({
    required String grammarId,
    required int rating,
    required int durationMs,
    required int expGain,
    required int waterGain,
    required int sunGain,
  }) async {
    return true;
  }
}
