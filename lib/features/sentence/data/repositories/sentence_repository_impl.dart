import 'package:mobile/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:mobile/features/sentence/domain/entities/sentence.dart';
import 'package:mobile/features/sentence/domain/repositories/sentence_repository.dart';

class SentenceRepositoryImpl implements SentenceRepository {
  final GrammarRepository _grammarRepository;

  SentenceRepositoryImpl(this._grammarRepository);

  @override
  Future<List<Sentence>> getAllSentences() async {
    final grammarPoints = await _grammarRepository.getAllGrammarPoints();
    final sentences = <Sentence>[];

    for (final grammar in grammarPoints) {
      for (var index = 0; index < grammar.examples.length; index++) {
        final example = grammar.examples[index];
        if (example.jp.trim().isEmpty || example.en.trim().isEmpty) continue;
        sentences.add(
          Sentence(
            id: 'sentence_${grammar.id}_$index',
            text: example.jp.trim(),
            reading: example.romaji.trim(),
            meaning: example.en.trim(),
            jlptLevel: grammar.jlptLevel,
            sourceGrammarId: grammar.id,
            sourceGrammarTitle: grammar.title,
          ),
        );
      }
    }

    return sentences;
  }

  @override
  Future<List<Sentence>> getSentencesByLevel(int level) async {
    final sentences = await getAllSentences();
    return sentences.where((sentence) => sentence.jlptLevel == level).toList();
  }

  @override
  Future<List<Sentence>> searchSentences(String query, {int? jlptLevel}) async {
    final normalized = query.trim().toLowerCase();
    final sentences = await getAllSentences();

    return sentences.where((sentence) {
      if (jlptLevel != null && sentence.jlptLevel != jlptLevel) return false;
      if (normalized.isEmpty) return true;

      return sentence.text.toLowerCase().contains(normalized) ||
          sentence.reading.toLowerCase().contains(normalized) ||
          sentence.meaning.toLowerCase().contains(normalized) ||
          (sentence.sourceGrammarTitle?.toLowerCase().contains(normalized) ??
              false);
    }).toList();
  }
}
