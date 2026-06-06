import 'package:flutter_riverpod/misc.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/features/analytics/application/providers/analytics_provider.dart';
import 'package:mobile/features/analytics/data/repositories/analytics_repository.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/garden/application/providers/garden_provider.dart';
import 'package:mobile/features/garden/data/repositories/garden_repository.dart';
import 'package:mobile/features/grammar/application/providers/grammar_repository_provider.dart';
import 'package:mobile/features/grammar/data/repositories/grammar_repository_impl.dart';
import 'package:mobile/features/home/application/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/home/application/providers/home_progress_provider.dart';
import 'package:mobile/features/home/data/repositories/drift_home_progress_repository.dart';
import 'package:mobile/features/home/data/repositories/drift_study_insight_repository.dart';
import 'package:mobile/features/kanji/application/providers/kanji_repository_provider.dart';
import 'package:mobile/features/kanji/data/repositories/kanji_repository_impl.dart';
import 'package:mobile/features/learning/application/providers/learning_path_provider.dart';
import 'package:mobile/features/learning/data/repositories/learning_path_repository.dart';
import 'package:mobile/features/sentence/application/providers/sentence_provider.dart';
import 'package:mobile/features/sentence/data/repositories/sentence_repository_impl.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/features/settings/data/repositories/shared_preferences_settings_repository.dart';
import 'package:mobile/features/settings/domain/entities/app_settings.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_repository_provider.dart';
import 'package:mobile/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';

/// Application composition root.
///
/// Feature providers expose repository contracts; this file connects those
/// contracts to concrete data sources in one place so screens and controllers
/// stay independent from Drift, Firebase, SharedPreferences, and asset loaders.
List<Override> get appRepositoryOverrides {
  return [
    analyticsRepositoryProvider.overrideWith(
      (ref) => DriftAnalyticsRepository(ref.watch(databaseProvider)),
    ),
    authRepositoryProvider.overrideWith((ref) => AuthRepositoryImpl()),
    gardenRepositoryProvider.overrideWith(
      (ref) => DriftGardenRepository(ref.watch(databaseProvider)),
    ),
    grammarRepositoryProvider.overrideWith(
      (ref) => GrammarRepositoryImpl(ref.watch(databaseProvider)),
    ),
    homeProgressRepositoryProvider.overrideWith(
      (ref) => DriftHomeProgressRepository(ref.watch(databaseProvider)),
    ),
    kanjiRepositoryProvider.overrideWith(
      (ref) => KanjiRepositoryImpl(ref.watch(databaseProvider)),
    ),
    learningPathRepositoryProvider.overrideWith(
      (ref) => AssetLearningPathRepository(
        ref.watch(databaseProvider),
        loadPathData: AssetLearningPathRepository.loadPathDataFromAssets,
      ),
    ),
    sentenceRepositoryProvider.overrideWith(
      (ref) => SentenceRepositoryImpl(ref.watch(grammarRepositoryProvider)),
    ),
    settingsRepositoryProvider.overrideWithValue(
      SharedPreferencesSettingsRepository(),
    ),
    studyInsightRepositoryProvider.overrideWith(
      (ref) => DriftStudyInsightRepository(ref.watch(databaseProvider)),
    ),
    vocabularyRepositoryProvider.overrideWith(
      (ref) => VocabularyRepositoryImpl(ref.watch(databaseProvider)),
    ),
  ];
}

Future<AppSettings> loadPersistedSettings() {
  return SharedPreferencesSettingsRepository().load();
}
