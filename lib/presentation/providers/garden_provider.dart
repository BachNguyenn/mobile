import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/zen_garden.dart';
import '../../data/datasources/app_database.dart';
import 'kanji_library_provider.dart';
import 'study_event_provider.dart';

final gardenProvider = StateNotifierProvider<GardenNotifier, ZenGarden>((ref) {
  final db = ref.watch(databaseProvider);
  final notifier = GardenNotifier(db);

  // ── Reactive cross-tab: listen study events ─────────────
  // Khi user học xong 1 thẻ ở tab Chữ Hán → Vườn Zen tự cập nhật
  ref.listen(studyEventStreamProvider, (prev, next) {
    next.whenData((event) {
      notifier._onStudyEvent(event);
    });
  });

  return notifier;
});

class GardenNotifier extends StateNotifier<ZenGarden> {
  final AppDatabase _db;

  GardenNotifier(this._db) : super(const ZenGarden()) {
    loadGarden();
  }

  Future<void> loadGarden() async {
    final row = await _db.select(_db.zenGardenTable).getSingleOrNull();
    if (row != null) {
      final plantsList = (json.decode(row.plantsJson) as List)
          .map((item) => Plant.fromJson(item))
          .toList();
      
      state = ZenGarden(
        water: row.water,
        sunlight: row.sunlight,
        exp: row.exp,
        plants: plantsList,
      );
    } else {
      // Initialize if empty
      await _db.into(_db.zenGardenTable).insert(
        ZenGardenTableCompanion.insert(
          water: const Value(10),
          sunlight: const Value(10),
          exp: const Value(0),
          plantsJson: const Value('[]'),
        ),
      );
      state = const ZenGarden(water: 10, sunlight: 10);
    }
  }

  /// Xử lý study event — tăng EXP và thêm plant khi đạt milestone
  void _onStudyEvent(StudyEvent event) {
    if (!event.isSuccessful) return;

    // +10 EXP cho mỗi thẻ nhớ thành công
    final newExp = state.exp + 10;

    // Milestone: cứ 100 EXP → tự động thêm 1 cây mới
    List<Plant> updatedPlants = [...state.plants];
    if (newExp ~/ 100 > state.exp ~/ 100) {
      final types = ['bonsai', 'flower', 'stone', 'bamboo'];
      final typeIndex = updatedPlants.length % types.length;
      updatedPlants.add(Plant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: types[typeIndex],
        x: (updatedPlants.length * 60.0) % 300 + 30,
        y: (updatedPlants.length * 45.0) % 200 + 80,
      ));
    }

    state = state.copyWith(
      exp: newExp,
      plants: updatedPlants,
    );

    _saveToDb();
  }

  Future<void> addPlant(String type, double x, double y) async {
    final newPlant = Plant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      x: x,
      y: y,
    );
    
    final updatedPlants = [...state.plants, newPlant];
    state = state.copyWith(plants: updatedPlants);
    
    await _saveToDb();
  }

  Future<void> _saveToDb() async {
    await _db.update(_db.zenGardenTable).write(
      ZenGardenTableCompanion(
        water: Value(state.water),
        sunlight: Value(state.sunlight),
        exp: Value(state.exp),
        plantsJson: Value(json.encode(state.plants.map((p) => p.toJson()).toList())),
      ),
    );
  }
}