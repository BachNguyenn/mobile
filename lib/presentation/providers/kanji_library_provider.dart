import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kanji_card.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../../data/repositories/kanji_repository_impl.dart';
import '../../data/datasources/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final kanjiRepositoryProvider = Provider<KanjiRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return KanjiRepositoryImpl(db);
});

final kanjiListProvider = FutureProvider<List<KanjiCard>>((ref) async {
  final repo = ref.watch(kanjiRepositoryProvider);
  return repo.getAllCards();
});

final kanjiSearchQueryProvider = StateProvider<String>((ref) => '');
final kanjiJlptFilterProvider = StateProvider<int?>((ref) => null);

final kanjiSearchResultsProvider = FutureProvider<List<KanjiCard>>((ref) async {
  final repo = ref.watch(kanjiRepositoryProvider);
  final query = ref.watch(kanjiSearchQueryProvider);
  final jlptLevel = ref.watch(kanjiJlptFilterProvider);
  
  return repo.searchKanji(query, jlptLevel: jlptLevel);
});