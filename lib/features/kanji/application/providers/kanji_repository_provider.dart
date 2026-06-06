import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/kanji_repository.dart';

final kanjiRepositoryProvider = Provider<KanjiRepository>((ref) {
  throw UnimplementedError('kanjiRepositoryProvider must be overridden');
});
