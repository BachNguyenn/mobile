import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/domain/entities/zen_garden.dart';
import 'package:mobile/features/garden/data/repositories/garden_repository.dart';
import 'package:mobile/features/review/presentation/providers/study_event_provider.dart';

final gardenRepositoryProvider = Provider<GardenRepository>((ref) {
  return GardenRepository(ref.watch(databaseProvider));
});

final gardenProvider = StateNotifierProvider<GardenNotifier, ZenGarden>((ref) {
  final notifier = GardenNotifier(ref.watch(gardenRepositoryProvider));

  ref.listen(studyEventStreamProvider, (prev, next) {
    next.whenData(notifier.onStudyEvent);
  });

  return notifier;
});

class GardenNotifier extends StateNotifier<ZenGarden> {
  final GardenRepository _repository;

  GardenNotifier(this._repository) : super(const ZenGarden()) {
    loadGarden();
  }

  Future<void> loadGarden() async {
    state = await _repository.loadGarden();
  }

  void onStudyEvent(StudyEvent event) {
    if (!event.isSuccessful) return;
    loadGarden();
  }

  Future<bool> buyPlant(String type, double x, double y) async {
    final result = await _repository.buyPlant(state, type, x, y);
    state = result.garden;
    return result.success;
  }

  Future<void> updatePlantPosition(String id, double dx, double dy) async {
    state = await _repository.updatePlantPosition(state, id, dx, dy);
  }
}
