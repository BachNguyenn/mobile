import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../../data/repositories/kanji_repository_impl.dart';

final kanjiRepositoryProvider = Provider<KanjiRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return KanjiRepositoryImpl(db);
});
