import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/zen_garden.dart';
import '../../core/providers/database_provider.dart';
import '../../data/datasources/app_database.dart';
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
      
      int water = row.water;
      int sunlight = row.sunlight;

      // Loss Aversion: -10 resources per day missed
      if (row.lastLogin != null) {
        final days = DateTime.now().difference(row.lastLogin!).inDays;
        if (days >= 1) {
          water = (water - (days * 10)).clamp(0, 999999);
          sunlight = (sunlight - (days * 10)).clamp(0, 999999);
          
          // Update DB with new values and current timestamp
          await (_db.update(_db.zenGardenTable)..where((t) => t.id.equals(row.id))).write(
            ZenGardenTableCompanion(
              water: Value(water),
              sunlight: Value(sunlight),
              lastLogin: Value(DateTime.now()),
            )
          );
        }
      }

      state = ZenGarden(
        water: water,
        sunlight: sunlight,
        exp: row.exp,
        plants: plantsList,
      );
    } else {
      // Initialize if empty
      final now = DateTime.now();
      await _db.into(_db.zenGardenTable).insert(
        ZenGardenTableCompanion.insert(
          water: const Value(100),
          sunlight: const Value(100),
          exp: const Value(0),
          plantsJson: const Value('[]'),
          lastLogin: Value(now),
        ),
      );
      state = ZenGarden(water: 100, sunlight: 100, lastLogin: now);
    }
  }

  /// Xử lý study event — chỉ cần load lại từ DB vì Transaction đã xử lý rồi
  void _onStudyEvent(StudyEvent event) {
    if (!event.isSuccessful) return;
    loadGarden();
  }

  /// Cửa hàng: Mua cây bằng tài nguyên
  Future<bool> buyPlant(String type, double x, double y) async {
    int waterCost = 0;
    int sunCost = 0;
    
    switch (type) {
      case 'zen_bonsai':
        waterCost = 50;
        sunCost = 50;
        break;
      case 'zen_sakura':
        waterCost = 80;
        sunCost = 80;
        break;
      case 'zen_stone':
        waterCost = 20;
        sunCost = 10;
        break;
      default:
        waterCost = 30;
        sunCost = 30;
    }
    
    if (state.water >= waterCost && state.sunlight >= sunCost) {
      final newWater = state.water - waterCost;
      final newSunlight = state.sunlight - sunCost;
      
      final newPlant = Plant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        x: x,
        y: y,
      );
      
      state = state.copyWith(
        water: newWater,
        sunlight: newSunlight,
        plants: [...state.plants, newPlant],
      );
      
      await _saveToDb();
      return true;
    }
    return false; // Not enough resources
  }

  // Cập nhật vị trí cây khi kéo thả
  Future<void> updatePlantPosition(String id, double dx, double dy) async {
    final updatedPlants = state.plants.map((p) {
      if (p.id == id) {
        return Plant(id: p.id, type: p.type, x: p.x + dx, y: p.y + dy);
      }
      return p;
    }).toList();
    
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