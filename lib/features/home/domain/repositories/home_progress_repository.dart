import 'package:mobile/core/models/progress_models.dart';

abstract class HomeProgressRepository {
  Future<HomeProgress> loadProgress();
}
