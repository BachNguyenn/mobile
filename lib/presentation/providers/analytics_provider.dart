import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_database.dart';
import 'kanji_library_provider.dart';

final analyticsProvider = Provider<AnalyticsService>((ref) {
  final db = ref.watch(databaseProvider);
  return AnalyticsService(db);
});

class AnalyticsService {
  final AppDatabase _db;
  AnalyticsService(this._db);

  Future<Map<String, int>> getGlobalStats() async {
    final allCards = await _db.select(_db.kanjiCardTable).get();
    
    int learned = allCards.where((c) => c.reps > 0).length;
    int reviewing = allCards.where((c) => c.reps > 0 && c.nextReview.isAfter(DateTime.now())).length;
    int total = allCards.length;

    return {
      'learned': learned,
      'reviewing': reviewing,
      'total': total,
    };
  }

  Future<List<double>> getWeeklyProgress() async {
    // Mock data for now
    return [0.4, 0.7, 0.3, 0.9, 0.5, 0.2, 0.8];
  }
}