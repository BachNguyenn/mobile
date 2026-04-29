import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/domain/entities/zen_garden.dart';

class GardenPurchaseResult {
  final bool success;
  final ZenGarden garden;

  const GardenPurchaseResult({
    required this.success,
    required this.garden,
  });
}

class GardenRepository {
  final AppDatabase _db;

  GardenRepository(this._db);

  Future<ZenGarden> loadGarden() async {
    final row = await _db.select(_db.zenGardenTable).getSingleOrNull();
    if (row == null) return _createInitialGarden();

    final plants = (json.decode(row.plantsJson) as List)
        .map((item) => Plant.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    var water = row.water;
    var sunlight = row.sunlight;

    if (row.lastLogin != null) {
      final days = DateTime.now().difference(row.lastLogin!).inDays;
      if (days >= 1) {
        water = (water - (days * 10)).clamp(0, 999999).toInt();
        sunlight = (sunlight - (days * 10)).clamp(0, 999999).toInt();
        await (_db.update(_db.zenGardenTable)
              ..where((table) => table.id.equals(row.id)))
            .write(
          ZenGardenTableCompanion(
            water: Value(water),
            sunlight: Value(sunlight),
            lastLogin: Value(DateTime.now()),
          ),
        );
      }
    }

    return ZenGarden(
      water: water,
      sunlight: sunlight,
      exp: row.exp,
      plants: plants,
      lastLogin: row.lastLogin,
    );
  }

  Future<GardenPurchaseResult> buyPlant(
    ZenGarden garden,
    String type,
    double x,
    double y,
  ) async {
    final cost = _plantCost(type);
    if (garden.water < cost.water || garden.sunlight < cost.sun) {
      return GardenPurchaseResult(success: false, garden: garden);
    }

    final updatedGarden = garden.copyWith(
      water: garden.water - cost.water,
      sunlight: garden.sunlight - cost.sun,
      plants: [
        ...garden.plants,
        Plant(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          x: x,
          y: y,
        ),
      ],
    );
    await saveGarden(updatedGarden);
    return GardenPurchaseResult(success: true, garden: updatedGarden);
  }

  Future<ZenGarden> updatePlantPosition(
    ZenGarden garden,
    String id,
    double dx,
    double dy,
  ) async {
    final updatedGarden = garden.copyWith(
      plants: garden.plants.map((plant) {
        if (plant.id != id) return plant;
        return Plant(
          id: plant.id,
          type: plant.type,
          x: plant.x + dx,
          y: plant.y + dy,
        );
      }).toList(),
    );
    await saveGarden(updatedGarden);
    return updatedGarden;
  }

  Future<void> saveGarden(ZenGarden garden) async {
    await _db.update(_db.zenGardenTable).write(
          ZenGardenTableCompanion(
            water: Value(garden.water),
            sunlight: Value(garden.sunlight),
            exp: Value(garden.exp),
            plantsJson: Value(
              json.encode(garden.plants.map((plant) => plant.toJson()).toList()),
            ),
          ),
        );
  }

  Future<ZenGarden> _createInitialGarden() async {
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
    return ZenGarden(water: 100, sunlight: 100, lastLogin: now);
  }

  ({int water, int sun}) _plantCost(String type) {
    return switch (type) {
      'zen_bonsai' => (water: 50, sun: 50),
      'zen_sakura' => (water: 80, sun: 80),
      'zen_stone' => (water: 20, sun: 10),
      _ => (water: 30, sun: 30),
    };
  }
}
