import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/analytics/application/providers/analytics_provider.dart';
import 'package:mobile/features/grammar/application/providers/grammar_library_provider.dart';
import 'package:mobile/features/home/application/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/home/application/providers/home_progress_provider.dart';
import 'package:mobile/features/kanji/application/providers/kanji_library_provider.dart';
import 'package:mobile/features/learning/application/providers/learning_path_provider.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/features/sync/domain/entities/progress_sync_summary.dart';
import 'package:mobile/features/sync/domain/repositories/progress_sync_repository.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_library_provider.dart';

final progressSyncRepositoryProvider = Provider<ProgressSyncRepository>((ref) {
  throw UnimplementedError('progressSyncRepositoryProvider must be overridden');
});

final progressSyncControllerProvider =
    StateNotifierProvider<
      ProgressSyncController,
      AsyncValue<ProgressSyncSummary>
    >((ref) => ProgressSyncController(ref));

class ProgressSyncController
    extends StateNotifier<AsyncValue<ProgressSyncSummary>> {
  final Ref _ref;

  ProgressSyncController(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  ProgressSyncRepository get _repository =>
      _ref.read(progressSyncRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.loadCloudSummary());
  }

  Future<ProgressSyncResult> backupNow() async {
    state = const AsyncValue.loading();
    final result = await _repository.backupNow();
    state = AsyncValue.data(result.summary);
    return result;
  }

  Future<ProgressSyncResult> restoreFromCloud() async {
    state = const AsyncValue.loading();
    final result = await _repository.restoreFromCloud();
    state = AsyncValue.data(result.summary);
    _invalidateProgressProviders();
    return result;
  }

  void _invalidateProgressProviders() {
    _ref.invalidate(analyticsProvider);
    _ref.invalidate(dailyStudyPlanProvider);
    _ref.invalidate(grammarListProvider);
    _ref.invalidate(grammarProgressProvider);
    _ref.invalidate(dueGrammarProvider);
    _ref.invalidate(totalDueGrammarCountProvider);
    _ref.invalidate(homeProgressProvider);
    _ref.invalidate(kanjiListProvider);
    _ref.invalidate(kanjiProgressProvider);
    _ref.invalidate(dueKanjiCardsProvider);
    _ref.invalidate(totalDueCountProvider);
    _ref.invalidate(learningPathProvider);
    _ref.invalidate(settingsProvider);
    _ref.invalidate(vocabularyListProvider);
    _ref.invalidate(vocabularyProgressProvider);
    _ref.invalidate(dueVocabularyProvider);
    _ref.invalidate(totalDueVocabularyCountProvider);
  }
}
