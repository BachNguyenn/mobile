import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_database.dart';
import 'package:drift/drift.dart';

/// Sự kiện học tập — được emit mỗi khi user hoàn thành 1 thẻ ôn tập
///
/// Đây là trung tâm reactive: tất cả provider khác (garden, analytics,
/// progress) listen stream này để tự cập nhật UI mà không cần reload.
class StudyEvent {
  final String cardId;

  /// Loại nội dung: 'kanji', 'vocabulary', 'grammar'
  final String type;

  final DateTime timestamp;

  /// FSRS quality rating: 1 = Again, 2 = Hard, 3 = Good, 4 = Easy
  final int qualityRating;

  const StudyEvent({
    required this.cardId,
    required this.type,
    required this.timestamp,
    required this.qualityRating,
  });

  /// Rating >= 3 nghĩa là user nhớ được thẻ này
  bool get isSuccessful => qualityRating >= 3;
}

/// Controller quản lý StreamController cho study events
///
/// Sử dụng broadcast stream để nhiều listener cùng nhận event.
class StudyEventController {
  final _controller = StreamController<StudyEvent>.broadcast();

  Stream<StudyEvent> get stream => _controller.stream;

  /// Emit 1 study event — gọi từ review screen hoặc kanji detail
  void addEvent(StudyEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

/// Provider singleton cho StudyEventController
///
/// Tất cả các provider khác sẽ ref.watch(studyEventStreamProvider)
/// để lắng nghe sự kiện học tập mới.
final studyEventControllerProvider = Provider<StudyEventController>((ref) {
  final controller = StudyEventController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Stream provider cho study events
///
/// Các provider khác listen stream này:
/// ```dart
/// ref.listen(studyEventStreamProvider, (prev, next) {
///   next.whenData((event) => _handleEvent(event));
/// });
/// ```
final studyEventStreamProvider = StreamProvider<StudyEvent>((ref) {
  return ref.watch(studyEventControllerProvider).stream;
});

/// Provider đếm tổng số thẻ đã học trong session hiện tại
final sessionStudyCountProvider = StateProvider<int>((ref) => 0);

/// Provider xử lý việc lưu StudyEvent vào Database
/// 
/// Provider này cần được watch ở một nơi nào đó (ví dụ: main hoặc home)
/// để đảm bảo nó luôn lắng nghe và lưu dữ liệu.
final studyEventPersisterProvider = Provider<void>((ref) {
  final db = ref.watch(databaseProvider);
  
  ref.listen(studyEventStreamProvider, (prev, next) async {
    final event = next.value;
    if (event == null) return;

    // 1. Cập nhật session count
    ref.read(sessionStudyCountProvider.notifier).state++;

    // 2. Lưu vào StudyLogTable (thống kê theo ngày)
    final date = DateTime(event.timestamp.year, event.timestamp.month, event.timestamp.day);
    
    try {
      final existing = await (db.select(db.studyLogTable)..where((t) => t.date.equals(date))).getSingleOrNull();
      
      if (existing == null) {
        await db.into(db.studyLogTable).insert(StudyLogTableCompanion.insert(
          date: date,
          count: const Value(1),
        ));
      } else {
        await (db.update(db.studyLogTable)..where((t) => t.date.equals(date))).write(
          StudyLogTableCompanion(count: Value(existing.count + 1)),
        );
      }
    } catch (e) {
      // Log error if needed
    }
  });
});
