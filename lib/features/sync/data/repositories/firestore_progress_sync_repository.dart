import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/domain/entities/learning_goal.dart';
import 'package:mobile/features/settings/domain/entities/app_settings.dart';
import 'package:mobile/features/settings/domain/entities/app_theme_mode.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/features/sync/domain/entities/progress_sync_summary.dart';
import 'package:mobile/features/sync/domain/repositories/progress_sync_repository.dart';

class FirestoreProgressSyncRepository implements ProgressSyncRepository {
  static const _schemaVersion = 1;

  final AppDatabase _db;
  final SettingsRepository _settingsRepository;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirestoreProgressSyncRepository(
    this._db,
    this._settingsRepository, {
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ProgressSyncSummary> loadCloudSummary() async {
    final user = _signedInUser();
    final snapshot = await _syncDoc(user.uid).get();
    final data = snapshot.data();
    if (data == null) return ProgressSyncSummary.empty;
    return _summaryFromSnapshot(data, hasCloudBackup: true);
  }

  @override
  Future<ProgressSyncResult> backupNow() async {
    final user = _signedInUser();
    final settings = await _settingsRepository.load();
    final snapshot = await _buildSnapshot(settings);
    await _syncDoc(user.uid).set(snapshot);
    final summary = _summaryFromSnapshot(snapshot, hasCloudBackup: true);
    return ProgressSyncResult(
      summary: summary,
      message: 'Đã sao lưu ${summary.totalSyncedItems} mục tiến độ.',
    );
  }

  @override
  Future<ProgressSyncResult> restoreFromCloud() async {
    final user = _signedInUser();
    final document = await _syncDoc(user.uid).get();
    final snapshot = document.data();
    if (snapshot == null) {
      return const ProgressSyncResult(
        summary: ProgressSyncSummary.empty,
        message: 'Chưa có bản sao lưu trên cloud.',
      );
    }

    await _restoreSnapshot(snapshot);
    final summary = _summaryFromSnapshot(snapshot, hasCloudBackup: true);
    return ProgressSyncResult(
      summary: summary,
      message: 'Đã khôi phục ${summary.totalSyncedItems} mục tiến độ.',
    );
  }

  User _signedInUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Bạn cần đăng nhập để đồng bộ tiến độ.');
    }
    return user;
  }

  DocumentReference<Map<String, dynamic>> _syncDoc(String uid) {
    return _firestore.collection('user_progress').doc(uid);
  }

  Future<Map<String, dynamic>> _buildSnapshot(AppSettings settings) async {
    final kanji = await _db.select(_db.kanjiCardTable).get();
    final vocabulary = await _db.select(_db.vocabularyTable).get();
    final grammar = await _db.select(_db.grammarTable).get();
    final garden = await _db.select(_db.zenGardenTable).getSingleOrNull();
    final lessons = await _db.select(_db.lessonTable).get();
    final studyLogs = await _db.select(_db.studyLogTable).get();

    return {
      'schemaVersion': _schemaVersion,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': _settingsToJson(settings),
      'kanjiSrs': kanji
          .where((item) => item.reps > 0 || item.lastReview != null)
          .map((item) {
            return _srsToJson(
              id: item.id,
              stability: item.stability,
              difficulty: item.difficulty,
              lastReview: item.lastReview,
              nextReview: item.nextReview,
              reps: item.reps,
              lapses: item.lapses,
              state: item.state,
            );
          })
          .toList(growable: false),
      'vocabularySrs': vocabulary
          .where((item) => item.reps > 0 || item.lastReview != null)
          .map((item) {
            return _srsToJson(
              id: item.id,
              stability: item.stability,
              difficulty: item.difficulty,
              lastReview: item.lastReview,
              nextReview: item.nextReview,
              reps: item.reps,
              lapses: item.lapses,
              state: item.state,
            );
          })
          .toList(growable: false),
      'grammarProgress': grammar
          .where((item) => item.isLearned)
          .map((item) => {'id': item.id, 'isLearned': item.isLearned})
          .toList(growable: false),
      'garden': garden == null
          ? null
          : {
              'water': garden.water,
              'sunlight': garden.sunlight,
              'exp': garden.exp,
              'plantsJson': garden.plantsJson,
              'lastLogin': _dateToJson(garden.lastLogin),
            },
      'completedLessons': lessons
          .where((lesson) => lesson.isCompleted)
          .map((lesson) => lesson.id)
          .toList(growable: false),
      'studyLogs': studyLogs
          .where((log) => log.count > 0)
          .map((log) {
            return {'date': _dateToJson(log.date), 'count': log.count};
          })
          .toList(growable: false),
    };
  }

  Future<void> _restoreSnapshot(Map<String, dynamic> snapshot) async {
    await _db.transaction(() async {
      for (final item in _mapList(snapshot['kanjiSrs'])) {
        final id = item['id']?.toString();
        final nextReview = _dateFromJson(item['nextReview']);
        if (id == null || nextReview == null) continue;
        await (_db.update(
          _db.kanjiCardTable,
        )..where((table) => table.id.equals(id))).write(
          KanjiCardTableCompanion(
            stability: Value(_doubleFromJson(item['stability'])),
            difficulty: Value(_doubleFromJson(item['difficulty'])),
            lastReview: Value(_dateFromJson(item['lastReview'])),
            nextReview: Value(nextReview),
            reps: Value(_intFromJson(item['reps'])),
            lapses: Value(_intFromJson(item['lapses'])),
            state: Value(_intFromJson(item['state'])),
          ),
        );
      }

      for (final item in _mapList(snapshot['vocabularySrs'])) {
        final id = item['id']?.toString();
        final nextReview = _dateFromJson(item['nextReview']);
        if (id == null || nextReview == null) continue;
        await (_db.update(
          _db.vocabularyTable,
        )..where((table) => table.id.equals(id))).write(
          VocabularyTableCompanion(
            stability: Value(_doubleFromJson(item['stability'])),
            difficulty: Value(_doubleFromJson(item['difficulty'])),
            lastReview: Value(_dateFromJson(item['lastReview'])),
            nextReview: Value(nextReview),
            reps: Value(_intFromJson(item['reps'])),
            lapses: Value(_intFromJson(item['lapses'])),
            state: Value(_intFromJson(item['state'])),
          ),
        );
      }

      for (final item in _mapList(snapshot['grammarProgress'])) {
        final id = item['id']?.toString();
        if (id == null) continue;
        await (_db.update(
          _db.grammarTable,
        )..where((table) => table.id.equals(id))).write(
          GrammarTableCompanion(isLearned: Value(item['isLearned'] == true)),
        );
      }

      final garden = snapshot['garden'];
      if (garden is Map) {
        await _restoreGarden(Map<String, dynamic>.from(garden));
      }

      for (final lessonId in _stringList(snapshot['completedLessons'])) {
        await _db
            .into(_db.lessonTable)
            .insertOnConflictUpdate(
              LessonTableCompanion.insert(
                id: lessonId,
                isCompleted: const Value(true),
              ),
            );
      }

      for (final item in _mapList(snapshot['studyLogs'])) {
        final date = _dateFromJson(item['date']);
        if (date == null) continue;
        final normalized = DateTime(date.year, date.month, date.day);
        await _db
            .into(_db.studyLogTable)
            .insertOnConflictUpdate(
              StudyLogTableCompanion.insert(
                date: normalized,
                count: Value(_intFromJson(item['count'])),
              ),
            );
      }
    });

    final settingsJson = snapshot['settings'];
    if (settingsJson is Map) {
      await _settingsRepository.save(
        _settingsFromJson(Map<String, dynamic>.from(settingsJson)),
      );
    }
  }

  Future<void> _restoreGarden(Map<String, dynamic> garden) async {
    final existing = await _db.select(_db.zenGardenTable).getSingleOrNull();
    final companion = ZenGardenTableCompanion(
      water: Value(_intFromJson(garden['water'])),
      sunlight: Value(_intFromJson(garden['sunlight'])),
      exp: Value(_intFromJson(garden['exp'])),
      plantsJson: Value(garden['plantsJson']?.toString() ?? '[]'),
      lastLogin: Value(_dateFromJson(garden['lastLogin'])),
    );

    if (existing == null) {
      await _db.into(_db.zenGardenTable).insert(companion);
      return;
    }

    await (_db.update(
      _db.zenGardenTable,
    )..where((table) => table.id.equals(existing.id))).write(companion);
  }

  Map<String, dynamic> _srsToJson({
    required String id,
    required double stability,
    required double difficulty,
    required DateTime? lastReview,
    required DateTime nextReview,
    required int reps,
    required int lapses,
    required int state,
  }) {
    return {
      'id': id,
      'stability': stability,
      'difficulty': difficulty,
      'lastReview': _dateToJson(lastReview),
      'nextReview': _dateToJson(nextReview),
      'reps': reps,
      'lapses': lapses,
      'state': state,
    };
  }

  Map<String, dynamic> _settingsToJson(AppSettings settings) {
    return {
      'dailyReminderEnabled': settings.dailyReminderEnabled,
      'reminderHour': settings.reminderHour,
      'reminderMinute': settings.reminderMinute,
      'defaultLearningCategory': settings.defaultLearningCategory.name,
      'hapticsEnabled': settings.hapticsEnabled,
      'themeMode': settings.themeMode.name,
      'appLanguage': settings.appLanguage,
      'fontScale': settings.fontScale,
      'learningGoal': settings.learningGoal.name,
      'currentJlptLevel': settings.currentJlptLevel,
    };
  }

  AppSettings _settingsFromJson(Map<String, dynamic> json) {
    return AppSettings(
      dailyReminderEnabled:
          json['dailyReminderEnabled'] as bool? ??
          AppSettings.defaults.dailyReminderEnabled,
      reminderHour: _intFromJson(
        json['reminderHour'],
        AppSettings.defaults.reminderHour,
      ),
      reminderMinute: _intFromJson(
        json['reminderMinute'],
        AppSettings.defaults.reminderMinute,
      ),
      defaultLearningCategory: LearningCategory.values.firstWhere(
        (category) => category.name == json['defaultLearningCategory'],
        orElse: () => AppSettings.defaults.defaultLearningCategory,
      ),
      hapticsEnabled:
          json['hapticsEnabled'] as bool? ??
          AppSettings.defaults.hapticsEnabled,
      themeMode: AppThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => AppSettings.defaults.themeMode,
      ),
      appLanguage:
          json['appLanguage']?.toString() ?? AppSettings.defaults.appLanguage,
      fontScale:
          (json['fontScale'] as num?)?.toDouble() ??
          AppSettings.defaults.fontScale,
      learningGoal: LearningGoal.values.firstWhere(
        (goal) => goal.name == json['learningGoal'],
        orElse: () => AppSettings.defaults.learningGoal,
      ),
      currentJlptLevel: _intFromJson(
        json['currentJlptLevel'],
        AppSettings.defaults.currentJlptLevel,
      ).clamp(1, 5).toInt(),
    );
  }

  ProgressSyncSummary _summaryFromSnapshot(
    Map<String, dynamic> snapshot, {
    required bool hasCloudBackup,
  }) {
    return ProgressSyncSummary(
      hasCloudBackup: hasCloudBackup,
      cloudUpdatedAt: _dateFromJson(snapshot['updatedAt']),
      kanjiCount: _mapList(snapshot['kanjiSrs']).length,
      vocabularyCount: _mapList(snapshot['vocabularySrs']).length,
      grammarCount: _mapList(snapshot['grammarProgress']).length,
      completedLessonCount: _stringList(snapshot['completedLessons']).length,
      studyLogCount: _mapList(snapshot['studyLogs']).length,
      settingsIncluded: snapshot['settings'] is Map,
    );
  }

  List<Map<String, dynamic>> _mapList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList(growable: false);
  }

  String? _dateToJson(DateTime? value) {
    return value?.toUtc().toIso8601String();
  }

  DateTime? _dateFromJson(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value)?.toLocal();
    return null;
  }

  int _intFromJson(Object? value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _doubleFromJson(Object? value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
