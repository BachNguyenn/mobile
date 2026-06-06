import 'package:mobile/features/garden/domain/entities/zen_garden.dart';

class GardenPurchaseResult {
  final bool success;
  final ZenGarden garden;

  const GardenPurchaseResult({required this.success, required this.garden});
}

abstract class GardenRepository {
  Future<ZenGarden> loadGarden();
  Future<GardenPurchaseResult> buyPlant(
    ZenGarden garden,
    String type,
    double x,
    double y,
    int waterCost,
    int sunCost,
  );
  Future<ZenGarden> updatePlantPosition(
    ZenGarden garden,
    String id,
    double dx,
    double dy,
  );
  Future<void> saveGarden(ZenGarden garden);
  Future<int> getTodayStudyCount();
  Future<int> getTodayMaxCorrectStreak();
}
