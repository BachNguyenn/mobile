import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../../data/repositories/vocabulary_repository_impl.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return VocabularyRepositoryImpl(db);
});
