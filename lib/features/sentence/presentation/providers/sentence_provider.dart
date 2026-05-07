import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_repository_provider.dart';
import 'package:mobile/features/sentence/data/repositories/sentence_repository_impl.dart';
import 'package:mobile/features/sentence/domain/entities/sentence.dart';
import 'package:mobile/features/sentence/domain/repositories/sentence_repository.dart';

final sentenceRepositoryProvider = Provider<SentenceRepository>((ref) {
  return SentenceRepositoryImpl(ref.watch(grammarRepositoryProvider));
});

final sentenceSearchQueryProvider = StateProvider<String>((ref) => '');
final sentenceLevelFilterProvider = StateProvider<int?>((ref) => null);

final sentenceListProvider = FutureProvider<List<Sentence>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(sentenceRepositoryProvider);
  return repo.getAllSentences();
});

final dueSentencePracticeProvider = FutureProvider<List<Sentence>>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  final repo = ref.watch(sentenceRepositoryProvider);
  final level = ref.watch(sentenceLevelFilterProvider);
  final sentences = level == null
      ? await repo.getAllSentences()
      : await repo.getSentencesByLevel(level);
  return List<Sentence>.from(sentences)..shuffle();
});

final sentenceSearchResultsProvider =
    FutureProvider.family<List<Sentence>, String>((ref, query) async {
      await ref.watch(databaseInitializerProvider.future);
      final repo = ref.watch(sentenceRepositoryProvider);
      final level = ref.watch(sentenceLevelFilterProvider);
      return repo.searchSentences(query, jlptLevel: level);
    });
