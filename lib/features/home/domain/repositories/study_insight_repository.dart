import 'package:mobile/features/learning/domain/entities/learning_category.dart';

abstract class StudyInsightRepository {
  Future<LearningCategory?> findWeakestStudyArea();
}
