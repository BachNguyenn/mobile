import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../../data/repositories/grammar_repository_impl.dart';

final grammarRepositoryProvider = Provider<GrammarRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GrammarRepositoryImpl(db);
});
