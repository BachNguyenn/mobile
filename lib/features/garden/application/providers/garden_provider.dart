import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/garden/domain/entities/zen_garden.dart';
import 'package:mobile/features/garden/domain/repositories/garden_repository.dart';
import 'package:mobile/features/review/application/providers/study_event_provider.dart';

final gardenRepositoryProvider = Provider<GardenRepository>((ref) {
  throw UnimplementedError('gardenRepositoryProvider must be overridden');
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
    final newGarden = await _repository.loadGarden();
    if (!mounted) return;
    state = newGarden;
  }

  void onStudyEvent(StudyEvent event) {
    if (!event.isSuccessful) return;
    loadGarden();
  }

  Future<bool> buyPlant(
    String type,
    double x,
    double y, {
    required int waterCost,
    required int sunCost,
  }) async {
    final result = await _repository.buyPlant(
      state,
      type,
      x,
      y,
      waterCost,
      sunCost,
    );
    state = result.garden;
    return result.success;
  }

  Future<void> updatePlantPosition(String id, double dx, double dy) async {
    state = await _repository.updatePlantPosition(state, id, dx, dy);
  }
}
